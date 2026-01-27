defmodule Mix.Tasks.Scraper.Clear do
  use Mix.Task

  @shortdoc "Clear stored research papers"

  @moduledoc """
  Clears all stored research papers.

  Usage:
    mix scraper.clear
  """

  def run(_args) do
    Mix.Task.run("app.start")

    ResearchScraper.Storage.clear()
    IO.puts("Storage cleared.")
  end
end
