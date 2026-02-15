defmodule ResearchScraper.Repo.Migrations.CreatePapers do
  use Ecto.Migration

  def change do
    create table(:papers) do
      add :arxiv_id, :string
      add :title, :string
      add :authors, :text
      add :published, :string
      add :pdf_url, :string
      add :downloaded, :boolean, default: false

      timestamps()
    end

    create unique_index(:papers, [:arxiv_id])
  end
end
