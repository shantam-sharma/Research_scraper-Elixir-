defmodule ResearchScraper.Storage do
  @moduledoc """
  Stores normalized research papers using ETS.

  This module owns the ETS table and provides
  a controlled interface for persistence.
  """
  use GenServer

  @table :papers

  ## Public API

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Inserts a paper into storsge
  papers are deduplicated by `id`.
  """
  def insert(%{id: id} = paper) do
    GenServer.cast(__MODULE__, {:insert, id, paper})
  end

  @doc """
  Returns all stored papers.
  """
  def all do
    GenServer.call(__MODULE__, :all)
  end

  ## GenServer Callbacks

  @impl true

  def init(:ok) do
    table =
      :ets.new(
        @table,
        [:set, :named_table, :public, read_concurrency: true]
      )
    {:ok, table}
  end

  @impl true
  def handle_cast({:insert, id, paper}, table) do
    :ets.insert(table, {id, paper})
    {:noreply, table}
  end

  @impl true
  def handle_call(:all, _from, table) do
    papers =
      :ets.tab2list(table)
      |> Enum.map(fn {_id, paper} -> paper end)
    {:reply, papers, table}
  end
end
