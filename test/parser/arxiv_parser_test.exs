defmodule ResearchScraper.Parser.ArxivParserTest do
  use ExUnit.Case, async: true

  alias ResearchScraper.Parser.ArxivParser

  @xml """
  <?xml version="1.0" encoding="UTF-8"?>
  <feed xmlns="http://www.w3.org/2005/Atom">
    <entry>
      <id>http://arxiv.org/abs/1234.5678v1</id>
      <title> Test Paper Title </title>
      <summary>
        This is a test abstract.
      </summary>
      <published>2024-01-01T00:00:00Z</published>
      <author>
        <name>Jane Doe</name>
      </author>
      <author>
        <name>John Smith</name>
      </author>
    </entry>
  </feed>
  """

  test "parses arXiv XML into normalized paper maps" do
    [paper] = ArxivParser.parse(@xml)

    assert paper.source == "arXiv"
    assert paper.id == "http://arxiv.org/abs/1234.5678v1"
    assert paper.title == "Test Paper Title"
    assert paper.abstract == "This is a test abstract."
    assert paper.authors == ["Jane Doe", "John Smith"]
    assert paper.published == "2024-01-01T00:00:00Z"
  end
end
