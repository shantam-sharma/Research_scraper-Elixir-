defmodule Mix.Tasks.Scraper.List do
  use Mix.Task

  @shortdoc "List stored research papers"

  def run(_args) do
    Mix.Task.run("app.start")

    papers = ResearchScraper.Storage.all()

    if papers == [] do
      IO.puts("No papers stored.")
    else
      Enum.with_index(papers, 1)
      |> Enum.each(fn {paper, index} ->
        IO.puts("""
        [#{index}] #{paper.title}
            Authors: #{paper.authors}
            Published: #{paper.published}
        """)
      end)
    end
  end
end
