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

    IO.puts("Triggering fetch cycle...")
    ResearchScraper.Scheduler.fetch_next()
    IO.puts("Done.")
  end
end
