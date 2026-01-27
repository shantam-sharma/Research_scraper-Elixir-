# Research Scraper (Elixir)

A concurrent, fault-tolerant research paper metadata collector built
using Elixir/OTP. The project demonstrates supervised concurrency,
rate-limited HTTP fetching, XML parsing, and persistent storage.

This is a **systems-focused personal project**, not a production crawler.
_________________________________________________________________________

## What This Project Does

- Fetches research paper metadata from the arXiv API
- Uses supervised worker pools for concurrent fetching
- Enforces global rate limiting
- Parses XML responses into structured Elixir maps
- Stores results in ETS
- Includes unit tests for core components

## What This Project Does NOT Do (Yet)

- Download or parse PDFs
- Scrape HTML websites
- Persist data across restarts
- Provide a CLI or web interface
_________________________________________________________________________
## Requirements

- Elixir >= 1.16
- Erlang/OTP >= 26
_________________________________________________________________________

## CLI Usage

Trigger one fetch cycle:

mix scraper.fetch
mix scraper.list
mix scraper.clear

_________________________________________________________________________

## Planned Next Steps

- Add retry and exponential backoff to fetcher workers
- Add periodic scheduling (timer-based ingestion)
- Persist data using Postgres/Ecto
- Add PDF fetching and metadata extraction
- Add search and query interface
- Add telemetry and metrics
