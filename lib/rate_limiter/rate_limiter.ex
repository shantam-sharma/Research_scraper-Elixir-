defmodule ResearchScraper.RateLimiter do
  @moduledoc """
  Controls request rate across fetcher workers.

  This module will be implemented as a GenServer that enforces
  request quotas per time window.
  """
end
