defmodule ResearchScraper.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Core infrastructure (to be enabled incrementally)
      # ResearchScraper.RateLimiter,
      # ResearchScraper.Scheduler,
      # ResearchScraper.Storage,

      # Fetcher supervisor will be added here
    ]

    opts = [strategy: :one_for_one, name: ResearchScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
