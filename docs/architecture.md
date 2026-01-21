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

- Implemented as a GenServer
- Decides *what* to fetch
- Dispatches work asynchronously
- Never performs I/O directly

### Fetcher
A supervised pool of worker processes. Each worker performs
a single HTTP request and returns the response asynchronously.

- DynamicSupervisor managing worker processes
- Each worker performs one HTTP request
- Enforces global rate limiting before fetching
- Isolates failures at the worker level

### Rate Limiter
A GenServer responsible for enforcing request limits per
time window. Fetchers must request permission before issuing
HTTP calls.

- GenServer-based global request controller
- Enforces fixed-window limits
- Shared across all workers

### Parser
Pure functional modules that transform API or HTML responses
into normalized internal data structures.

- Pure functional modules
- Converts arXiv XML into normalized maps
- No side effects
- Fully unit tested

### Storage
Responsible for persisting normalized metadata. This component
is isolated from fetching and parsing concerns.

- GenServer owning an ETS table
- Deduplicates papers by ID
- Provides read and clear interfaces
- Used as in-memory persistence

## Supervision Strategy
- Core services are permanent
- Fetcher workers are temporary
- Failures are isolated and recoverable

The system favors restartability over defensive coding.
