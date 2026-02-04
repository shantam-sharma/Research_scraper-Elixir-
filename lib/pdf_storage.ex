defmodule ResearchScraper.PDFStorage do
  @moduledoc """
  Determines filesystem paths for stored PDF files.

  This module centralizes all path and naming logic for PDFs.
  """

  @base_dir "data/pdfs"

  @doc """
  Returns the filesystem path for a paper's PDF.

  Expects a paper map with a `:pdf_url` field.
  """
  def pdf_path(%{pdf_url: pdf_url}) when is_binary(pdf_url) do
    pdf_path_from_url(pdf_url)
  end

  @doc """
  Returns the filesystem path for a PDF URL.
  """
  def pdf_path_from_url(pdf_url) when is_binary(pdf_url) do
    filename =
      pdf_url
      |> Path.basename()
      |> sanitize_filename()

    Path.join(@base_dir, filename)
  end

  ## Helpers

  # Keep filenames conservative and filesystem-safe
  defp sanitize_filename(name) do
    name
    |> String.replace(~r/[^a-zA-Z0-9._-]/, "_")
  end
end
