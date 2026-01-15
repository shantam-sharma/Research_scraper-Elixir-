defmodule ResearchScraper.Fetcher.Worker do
  @moduledoc """
  Performs a single HTTP fetch operation.

  This module will later be implemented as a GenServer
  or simple task-based worker.
  """
  use GenServer

  ## Public API

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{})
  end

  @doc """
  Fetches the given URL if permitted by the rate limiter.
  """

  def fetch(pid, url) do
    GenServer.call(pid, {:fetch, url}, 10_000)
  end

  ## GenServer Callbacks
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:fetch, url}, _from, state) do
    case ResearchScraper.RateLimiter.request_permission() do
      :ok ->
        response = do_fetch(url)
        {:reply, response, state}
      :error ->
        {:reply, {:error, :rate_limited}, state}
    end
  end

  ## Internal Helpers

  defp do_fetch(url) do
    request = Finch.build(:get, url)

    case Finch.request(request, ResearchScraperFinch) do
      {:ok, %Finch.Response{status: status, body: body}} ->
        {:ok, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
