defmodule ResearchScraper.Fetcher.Worker do
  @moduledoc """
  Performs a single HTTP fetch operation with retry and backoff.

  This worker enforces rate limiting, retries transient failures,
  and isolates errors from the rest of the system.
  """

  use GenServer

  @max_retries 3
  @base_backoff_ms 200

  ## Public API

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{})
  end

  @doc """
  Fetches the given URL with retry and exponential backoff.
  """
  def fetch(pid, url) do
    GenServer.call(pid, {:fetch, url}, 20_000)
  end

  ## GenServer callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:fetch, url}, _from, state) do
    case ResearchScraper.RateLimiter.request_permission() do
      :ok ->
        result = fetch_with_retry(url, 1)
        {:reply, result, state}

      :error ->
        {:reply, {:error, :rate_limited}, state}
    end
  end

  ## Retry logic

  defp fetch_with_retry(url, attempt) when attempt <= @max_retries do
    case do_fetch(url) do
      {:ok, %{status: status} = response} ->
        cond do
          status in 200..299 ->
            {:ok, response}

          retryable_status?(status) ->
            backoff(attempt)
            fetch_with_retry(url, attempt + 1)

          true ->
            {:error, {:http_error, status}}
        end
      {:error, _reason} ->
        backoff(attempt)
        fetch_with_retry(url, attempt + 1)
    end
  end

  defp fetch_with_retry(_url, _attempt) do
    {:error, :max_retries_exceeded}
  end

  ## HTTP

  defp do_fetch(url) do
    request =
      Finch.build(
        :get,
        url,
        [
          {"user-agent", "ResearchScraper/1.0 (contact: your_email@example.com)"},
          {"accept", "application/atom+xml"}
        ]
      )

    case Finch.request(
           request,
           ResearchScraperFinch,
           receive_timeout: 30_000
         ) do
      {:ok, %Finch.Response{status: status, body: body}} ->
        {:ok, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end


  ## Helpers

  defp retryable_status?(status) do
    status == 429 or status in 500..599
  end

  defp backoff(attempt) do
    jitter = :rand.uniform(100)
    delay = trunc(@base_backoff_ms * :math.pow(2, attempt - 1)) + jitter
    Process.sleep(delay)
  end
end
