defmodule ResearchScraper.Paper do
  use Ecto.Schema
  import Ecto.Changeset

  schema "papers" do
    field :arxiv_id, :string
    field :title, :string
    field :authors, :string
    field :published, :string
    field :pdf_url, :string
    field :downloaded, :boolean, default: false

    timestamps()
  end

  def changeset(paper, attrs) do
    paper
    |> cast(attrs, [:arxiv_id, :title, :authors, :published, :pdf_url, :downloaded])
    |> validate_required([:arxiv_id, :title])
    |> unique_constraint(:arxiv_id)
  end
end
