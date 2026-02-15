# Research Scraper (Elixir)

A concurrent, fault-tolerant research paper metadata collector built
using Elixir/OTP. The project demonstrates supervised concurrency,
rate-limited HTTP fetching, XML parsing, and persistent storage.

This is a **systems-focused personal project**, not a production crawler.
_________________________________________________________________________

## What This Project Does

- Search research papers by topic using the arXiv API
- Fetch research papers by predefined categories
- Uses supervised worker pools for concurrent fetching
- Enforces global rate limiting
- Implements retry + exponential backoff
- Parses XML responses into structured Elixir maps
- Stores results persistently using SQLite (Ecto)
- Download research paper PDFs to disk
- Track downloaded status in database
- Provides a CLI interface
- Includes unit tests for core components

## What This Project Does NOT Do (Yet)

- Provide a web interface
- Perform full-text PDF parsing
- Distributed crawling
- Advanced ranking or filtering

_________________________________________________________________________
## Requirements

- Elixir >= 1.16
- Erlang/OTP >= 26
_________________________________________________________________________

## Setup

Install dependencies:
    mix deps.get
Create and migrate database:
    mix ecto.create
    mix ecto.migrate
_________________________________________________________________________

## CLI Usage

Search by topic:
    mix scraper.search "transformers"
    mix scraper.search "neural network" 10

Fetch predefined category:
    mix scraper.fetch

List stored papers:
    mix scraper.list

Download paper by index:
    mix scraper.download 1

Clear database:
    mix scraper.clear
_________________________________________________________________________
## Correct Ways to Run Tasks

From PowerShell / CMD:

Use Mix CLI:
    mix scraper.search "Neural Networks"
    mix scraper.fetch
    mix scraper.list
    mix scraper.download 1
    mix scraper.clear

From IEx:
    Start IEx:
    iex -S mix
    Then:
    Mix.Tasks.Scraper.Search.run(["Neural Networks"])
    Mix.Tasks.Scraper.Fetch.run([])
    Mix.Tasks.Scraper.List.run([])
    Mix.Tasks.Scraper.Download.run(["1"])
    Mix.Tasks.Scraper.Clear.run([])
_________________________________________________________________________

## Architecture Summary

    CLI Layer
    ↓
    Search / Fetch → Fetcher Worker → Parser → Storage (Ecto)
    ↓
    SQLite Database
    ↓
    Download → PDF Worker → File System

    The system follows OTP supervision principles and isolates
    failures at the worker level.

_________________________________________________________________________

## Future Improvements

- Batch download support
- Advanced filtering (author/year)
- Telemetry & metrics
- Convert to escript
- Web interface (Phoenix)

_________________________________________________________________________
