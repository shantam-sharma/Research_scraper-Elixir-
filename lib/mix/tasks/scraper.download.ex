defmodule Mix.Tasks.Scraper.Download do
  use Mix.Task

  @shortdoc "Download a paper PDF by index"

  def run([index_str]) do
    Mix.Task.run("app.start")

    with {index, ""} <- Integer.parse(index_str),
         true <- index > 0,
         paper when not is_nil(paper) <- Enum.at(ResearchScraper.Storage.all(), index - 1) do

      path =
        "data/pdfs/" <>
          Path.basename(paper.pdf_url)

      IO.puts("Downloading...")
      IO.puts("Title: #{paper.title}")
      IO.puts("URL:   #{paper.pdf_url}")

      case ResearchScraper.PDFFetcher.Worker.download(paper.pdf_url, path) do
        {:ok, _} ->
          IO.puts("Download complete")
        {:error, reason} ->
          IO.puts("Download failed: #{inspect(reason)}")
      end
    else
      _ ->
        IO.puts("Invalid index")
    end
  end

  def run(_) do
    IO.puts("Usage: mix scraper.download <index>")
  end
end
