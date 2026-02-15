defmodule ResearchScraper.PDFFetcher.Worker do
  @max_retries 3
  @base_backoff_ms 300

  def download(pdf_url, path) do
    case download_with_retry(pdf_url, 1) do
      {:ok, body} ->
        File.mkdir_p!(Path.dirname(path))
        File.write!(path, body)
        {:ok, path}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # -----------------------
  # Retry Layer
  # -----------------------

  defp download_with_retry(pdf_url, attempt)
       when attempt <= @max_retries do
    case do_request(pdf_url, 3) do
      {:ok, body} ->
        {:ok, body}

      {:error, {:http_error, status}} when status in [403, 404] ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        if attempt == @max_retries do
          IO.inspect(reason, label: "FINAL PDF download error")
        end

        backoff(attempt)
        download_with_retry(pdf_url, attempt + 1)
    end
  end

  defp download_with_retry(_pdf_url, _attempt) do
    {:error, :max_retries_exceeded}
  end

  # -----------------------
  # HTTP + Redirect Layer
  # -----------------------

  defp do_request(_url, 0) do
    {:error, :too_many_redirects}
  end

  defp do_request(url, redirects_left) do
    request = Finch.build(:get, url)

    case Finch.request(request, ResearchScraperFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Finch.Response{status: status, headers: headers}}
      when status in [301, 302, 303, 307, 308] ->
        case Enum.find(headers, fn {k, _} ->
               String.downcase(k) == "location"
             end) do
          {_, new_url} ->
            resolved =
              if String.starts_with?(new_url, "http") do
                new_url
              else
                "https://arxiv.org" <> new_url
              end

            do_request(resolved, redirects_left - 1)

          nil ->
            {:error, :redirect_without_location}
        end

      {:ok, %Finch.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # -----------------------
  # Backoff
  # -----------------------

  defp backoff(attempt) do
    jitter = :rand.uniform(100)
    delay =
      trunc(@base_backoff_ms * :math.pow(2, attempt - 1)) + jitter

    Process.sleep(delay)
  end
end
