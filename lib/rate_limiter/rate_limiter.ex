defmodule ResearchScraper.RateLimiter do
  @moduledoc """
  Controls request rate across fetcher workers.

  This module will be implemented as a GenServer that enforces
  request quotas per time window.
  """
  use GenServer
  @default_limit 5
  @default_window_ms 1_000
  #default window duration 1000 milisecong 1s
  ## public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  @doc """
  Request permisson to perform an outbound request.
  Returns :ok if allowed, :error if rate_limited.
  """
  def request_permission do
    GenServer.call(__MODULE__, :request)
  end

  ## GenServer Callbacks

  @impl true #marker as a implimentation of behaviour
  def init(opts) do
    limit = Keyword.get(opts, :limit, @default_limit)
    window = Keyword.get(opts, :window_ms, @default_window_ms)

    state = %{
      limit: limit,
      window_ms: window,
      count: 0,
      window_start: now()
    }
    {:ok, state}
  end

  @impl true
  def handle_call(:request, _from, state) do
    state = maybe_reset_window(state)

    if state.count < state.limit do
      {:reply, :ok, %{state | count: state.count + 1}}
    else
      {:reply, :error, state}
    end
  end

  ## Internal Helpers

  defp maybe_reset_window(state) do
    if now() - state.window_start >= state.window_ms do
      %{state | count: 0, window_start: now()}
    else
      state
    end
  end

  defp now do
    System.monotonic_time(:millisecond)
  end

end
