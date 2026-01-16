defmodule ResearchScraper.Fetcher do
  @moduledoc """
  Dynamically supervises fetcher worker processes.

  Uses DynamicSupervisor (modern replacement for :simple_one_for_one).
  """
  use DynamicSupervisor

  alias ResearchScraper.Fetcher.Worker

  def start_link(_opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a new fetcher worker under supervision.
  """
  def start_worker do
    DynamicSupervisor.start_child(__MODULE__, {Worker, []})
  end
end
