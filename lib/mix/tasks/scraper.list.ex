defmodule Mix.Tasks.Scraper.List do
  use Mix.Task

  @shortdoc "List stored research papers"

  @moduledoc """
  Lists all stored research papers.

  Usage:
    mix scraper.list
  """

  def run(_args) do
    Mix.Task.run("app.start")

    papers = ResearchScraper.Storage.all()

    if papers == [] do
      IO.puts("No papers stored.")
    else
      Enum.with_index(papers, 1)
      |> Enum.each(fn {paper, idx} ->
        IO.puts("""
        [#{idx}] #{paper.title}
            Authors: #{Enum.join(paper.authors, ", ")}
            Published: #{paper.published}
        """)
      end)
    end
  end
end
