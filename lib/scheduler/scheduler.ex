defmodule ResearchScraper.Scheduler do
  @moduledoc """
  Produces fetch tasks and coordinates scraping workflow.

  The scheduler decides *what* to fetch, not *how* to fetch it.
  """
  use GenServer
  require Logger

  alias ResearchScraper.Fetcher
  alias ResearchScraper.Fetcher.Worker

  #Public API
  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Trigger fetching of next scheduled query.
  """
  def fetch_next do
    GenServer.cast(__MODULE__, :fetch_next)
  end

  #GenServer Callbacks

  @impl true

  def init(:ok) do
    interval = Application.fetch_env!(:research_scraper, :scheduler_interval_ms)
    state = %{
      queries: default_queries(),
      interval: interval
    }
    schedule_tick(interval)
    {:ok, state}
  end

  @impl true
  def handle_cast(:fetch_next, %{queries: []} = state) do
    Logger.info("scheduler: no more queries to fetch")
    {:noreply, state}
  end

  @impl true
  def handle_cast(:fetch_next, state) do
    [query | rest] = state.queries

    url = build_arxiv_url(query)

    {:ok, worker} = Fetcher.start_worker()

    Logger.info("Scheduler : dispatching fetch for #{query}")

    Task.start(fn ->
      case Worker.fetch(worker, url) do
        {:ok, %{status: 200, body: xml}} ->
          papers =
            ResearchScraper.Parser.ArxivParser.parse(xml)
          Enum.each(papers, &ResearchScraper.Storage.insert/1)
          Logger.info(
            "Scheduler: stored #{length(papers)} papers for #{query}"
          )
        other ->
          Logger.error(
            "Scheduler: fetch failed for #{query}: #{inspect(other)}"
          )
      end
    end)
    {:noreply, %{state | queries: rest}}
  end

  @impl true
  def handle_info(:tick, state) do
    # Trigger one fetch cycle
    fetch_next()

    # Schedule the next tick
    schedule_tick(state.interval)

    {:noreply, state}
  end

  defp schedule_tick(interval) do
    Process.send_after(self(), :tick, interval)
  end

  ## Internal Helpers

  defp default_queries do
    [
      "cat:cs.AI",
      "cat:cs.LG",
      "cat:cs.DS"
    ]
  end

  defp build_arxiv_url(query) do
    "https://export.arxiv.org/api/query?search_query=#{query}&max_results=1"
  end
end
