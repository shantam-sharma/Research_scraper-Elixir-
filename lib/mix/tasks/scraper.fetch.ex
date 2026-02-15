defmodule Mix.Tasks.Scraper.Fetch do
  use Mix.Task

  @shortdoc "Trigger one research paper fetch cycle"

  @moduledoc """
  Fetches one batch of research papers and stores them in the database.

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

        Enum.each(papers, fn paper ->
          ResearchScraper.Storage.insert(%{
            arxiv_id: paper.id,
            title: paper.title,
            authors: Enum.join(paper.authors, ", "),
            published: paper.published,
            pdf_url: paper.pdf_url
          })
        end)

        IO.puts("Fetched #{length(papers)} papers.")

      other ->
        IO.puts("Fetch failed: #{inspect(other)}")
    end
  end
end
