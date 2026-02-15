defmodule ResearchScraper.Repo do
  use Ecto.Repo,
    otp_app: :research_scraper,
    adapter: Ecto.Adapters.SQLite3
end
