defmodule ResearchScraper.Parser.ArxivParser do
  @moduledoc """
  Parses arXiv API XML responses into normalized internal data structures.

  Parsing is pure and side-effect free.
  """

  import SweetXml

  @doc """
  Parses an arXiv API XML response body.

  Returns a list of paper maps.
  """
  def parse(xml) when is_binary(xml) do
    xml
    |> SweetXml.parse()
    |> xpath(
      ~x"//entry"l,
      id: ~x"./id/text()"s,
      title: ~x"./title/text()"s,
      summary: ~x"./summary/text()"s,
      published: ~x"./published/text()"s,
      authors: ~x"./author/name/text()"ls,
      pdf_url: ~x"./link[@title='pdf']/@href"s
    )
    |> Enum.map(&normalize/1)
  end

  ## Internal helpers

  defp normalize(entry) do
    %{
      source: "arXiv",
      id: String.trim(entry.id),
      title: clean(entry.title),
      abstract: clean(entry.summary),
      authors: Enum.map(entry.authors, &String.trim/1),
      published: entry.published,
      pdf_url: entry.pdf_url
    }
  end

  defp clean(text) do
    text
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
