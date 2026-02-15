import Config

# App-level config
config :research_scraper,
  ecto_repos: [ResearchScraper.Repo],
  scheduler_interval_ms: 60_000

# Repo config
config :research_scraper, ResearchScraper.Repo,
  database: "research_scraper.db",
  pool_size: 5,
  journal_mode: :wal
