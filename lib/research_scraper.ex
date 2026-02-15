defmodule ResearchScraper do
  @moduledoc """
  Core high-level API for research search and ingestion.
  """

  alias ResearchScraper.Fetcher
  alias ResearchScraper.Fetcher.Worker
  alias ResearchScraper.Parser.ArxivParser
  alias ResearchScraper.Storage

  @default_limit 5

  def search(topic, limit \\ @default_limit) when is_binary(topic) do
    query = build_query(topic, limit)

    {:ok, worker} = Fetcher.start_worker()

    case Worker.fetch(worker, query) do
      {:ok, %{status: 200, body: xml}} ->
        papers = ArxivParser.parse(xml)

        Enum.each(papers, &Storage.insert/1)

        {:ok, papers}

      other ->
        {:error, other}
    end
  end

  defp build_query(topic, limit) do
    encoded =
      URI.encode(topic)

    "https://export.arxiv.org/api/query?search_query=all:#{encoded}&max_results=#{limit}"
  end
end
