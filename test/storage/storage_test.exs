defmodule ResearchScraper.StorageTest do
  use ExUnit.Case, async: false

  alias ResearchScraper.Storage

  setup do
    Storage.clear()
    :ok
  end

  test "inserts and retrieves papers" do
    paper = %{
      id: "paper-1",
      title: "Test Paper",
      abstract: "Abstract",
      authors: ["Author One"],
      published: "2024-01-01",
      source: "arXiv"
    }

    Storage.insert(paper)

    [stored] = Storage.all()

    assert stored.id == "paper-1"
    assert stored.title == "Test Paper"
  end

  test "deduplicates papers by id" do
    paper1 = %{id: "dup", title: "First"}
    paper2 = %{id: "dup", title: "Second"}

    Storage.insert(paper1)
    Storage.insert(paper2)

    [stored] = Storage.all()

    assert stored.title == "Second"
  end
end
