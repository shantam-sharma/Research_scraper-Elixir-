defmodule ResearchScraper.PDFFetcher.Worker do
  @moduledoc """
  Downloads a single PDF with retry and exponential backoff.

  This worker is isolated from metadata fetching and is responsible
  only for retrieving and writing PDF files to disk.
  """

  use GenServer

  @max_retries 3
  @base_backoff_ms 300

  ## Public API

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{})
  end

  @doc """
  Downloads a PDF from `pdf_url` and writes it to `path`.

  Returns:
    {:ok, path} | {:error, reason}
  """
  def download(pid, pdf_url, path) do
    GenServer.call(pid, {:download, pdf_url, path}, 30_000)
  end

  ## GenServer callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:download, pdf_url, path}, _from, state) do
    case ResearchScraper.RateLimiter.request_permission() do
      :ok ->
        result = download_with_retry(pdf_url, path, 1)
        {:reply, result, state}

      :error ->
        {:reply, {:error, :rate_limited}, state}
    end
  end

  ## Retry logic

  defp download_with_retry(pdf_url, path, attempt)
       when attempt <= @max_retries do
    case do_download(pdf_url) do
      {:ok, binary} ->
        File.mkdir_p!(Path.dirname(path))
        File.write!(path, binary)
        {:ok, path}

      {:error, _reason} ->
        backoff(attempt)
        download_with_retry(pdf_url, path, attempt + 1)
    end
  end

  defp download_with_retry(_pdf_url, _path, _attempt) do
    {:error, :max_retries_exceeded}
  end

  ## HTTP

  defp do_download(pdf_url) do
    request = Finch.build(:get, pdf_url)

    case Finch.request(request, ResearchScraperFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Finch.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  ## Helpers

  defp backoff(attempt) do
    jitter = :rand.uniform(100)
    delay = trunc(@base_backoff_ms * :math.pow(2, attempt - 1)) + jitter
    Process.sleep(delay)
  end
end
