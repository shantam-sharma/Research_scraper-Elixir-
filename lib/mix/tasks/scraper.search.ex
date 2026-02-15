defmodule Mix.Tasks.Scraper.Search do
  use Mix.Task

  @shortdoc "Search arXiv by topic"

  @moduledoc """
  Searches arXiv for a topic and stores results.

  Usage:
    mix scraper.search "transformers"
    mix scraper.search "reinforcement learning" 10
  """

  def run(args) do
    Mix.Task.run("app.start")

    case args do
      [topic] ->
        run_search(topic, 5)

      [topic, limit_str] ->
        case Integer.parse(limit_str) do
          {limit, ""} when limit > 0 ->
            run_search(topic, limit)

          _ ->
            IO.puts("Limit must be a positive integer")
        end

      _ ->
        IO.puts("""
        Usage:
          mix scraper.search "topic"
          mix scraper.search "topic" 10
        """)
    end
  end

  defp run_search(topic, limit) do
    IO.puts("Searching arXiv for: #{topic}")
    IO.puts("Fetching #{limit} results...\n")

    case ResearchScraper.search(topic, limit) do
      {:ok, papers} ->
        # Clear previous search results (recommended for CLI mode)
        ResearchScraper.Storage.clear()

        # Persist results to DB
        Enum.each(papers, fn paper ->
          ResearchScraper.Storage.insert(%{
            arxiv_id: paper.id,
            title: paper.title,
            authors: Enum.join(paper.authors, ", "),
            published: paper.published,
            pdf_url: paper.pdf_url
          })
        end)

        print_results(papers)

      {:error, reason} ->
        IO.puts("Search failed: #{inspect(reason)}")
    end
  end


  defp print_results(papers) do
    if Enum.empty?(papers) do
      IO.puts("No results found.")
    else
      Enum.with_index(papers, 1)
      |> Enum.each(fn {paper, i} ->
        IO.puts("[#{i}] #{paper.title}")
        IO.puts("    Authors: #{Enum.join(paper.authors, ", ")}")
        IO.puts("    Published: #{paper.published}")
        IO.puts("")
      end)
    end
  end
end
