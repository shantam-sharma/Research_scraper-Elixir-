defmodule Mix.Tasks.Scraper.Fetch do
  use Mix.Task

  @shortdoc "Trigger one research paper fetch cycle"

  @moduledoc """
  Triggers the scheduler to fetch the next batch of research papers.

  Usage:
    mix scraper.fetch
  """

  def run(_args) do
    Mix.Task.run("app.start")

    query = "cat:cs.AI"
    url = "https://export.arxiv.org/api/query?search_query=#{query}&max_results=1"

    {:ok, worker} = ResearchScraper.Fetcher.start_worker()

    case ResearchScraper.Fetcher.Worker.fetch(worker, url) do
      {:ok, %{status: 200, body: xml}} ->
        papers = ResearchScraper.Parser.ArxivParser.parse(xml)
        Enum.each(papers, &ResearchScraper.Storage.insert/1)

        IO.puts("Fetched #{length(papers)} papers.")

      other ->
        IO.puts("Fetch failed: #{inspect(other)}")
    end
  end
end
