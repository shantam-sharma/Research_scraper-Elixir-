defmodule ResearchScraper.Storage do
  @moduledoc """
  Database-backed storage using Ecto.
  """

  alias ResearchScraper.{Repo, Paper}

  def insert(attrs) do
    %Paper{}
    |> Paper.changeset(attrs)
    |> Repo.insert(
      on_conflict: :nothing,
      conflict_target: :arxiv_id
    )
  end

  def all do
    Repo.all(Paper)
  end

  def get_by_index(index) do
    Repo.all(Paper)
    |> Enum.at(index - 1)
  end

  def clear do
    Repo.delete_all(Paper)
  end
end
