# System Architecture

## Overview
The system is designed as a supervised, concurrent pipeline
for collecting research paper metadata from public academic
sources. The architecture follows Elixir/OTP principles:
process isolation, message passing, and fault tolerance.

## Core Components

### Scheduler
Responsible for deciding which queries or URLs should be
fetched next. It produces work but does not perform I/O.

### Fetcher
A supervised pool of worker processes. Each worker performs
a single HTTP request and returns the response asynchronously.

### Rate Limiter
A GenServer responsible for enforcing request limits per
time window. Fetchers must request permission before issuing
HTTP calls.

### Parser
Pure functional modules that transform API or HTML responses
into normalized internal data structures.

### Storage
Responsible for persisting normalized metadata. This component
is isolated from fetching and parsing concerns.

## Supervision Strategy
- Core services are permanent
- Workers are temporary
- Failures are isolated and expected

Crashes are handled through supervision, not defensive coding.
