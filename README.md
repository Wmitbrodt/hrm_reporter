# Heart Rate Monitor Reporting App

## Rails Code Test Submission

This repository contains my solution to the Heart Rate Monitor (HRM) Rails code test. The goal of the exercise was to ingest a large relational CSV dataset and build a performant, user-friendly reporting and visualization interface.

The emphasis of my approach was:

- Correctness of heart-rate calculations
- Performance on a large dataset
- Clear UI/UX for reviewing session and aggregate data
- Clean, explainable architecture within the 3-hour time constraint

---

## UI/UX
<img width="3848" height="3686" alt="screencapture-localhost-3000-2026-01-19-18_30_53" src="https://github.com/user-attachments/assets/a2e5901d-8059-4f5a-89aa-71bd851a1e86" />

<img width="3848" height="7988" alt="screencapture-localhost-3000-hrm-sessions-2026-01-19-18_31_04" src="https://github.com/user-attachments/assets/86d7ad98-4a2d-4ab7-b6e2-184e3d2e2737" />

<img width="3848" height="1868" alt="screencapture-localhost-3000-hrm-sessions-51576-2026-01-19-18_31_15" src="https://github.com/user-attachments/assets/74ab30ab-9653-4c4e-8ab8-f5946e09dcf4" />


## Assignment Overview (How This README Is Structured)

Below, I walk through the original assignment **line by line** and explain how each requirement was addressed, including design decisions and tradeoffs.

---

## Main Task

**Download the data dump at:**  
https://assets.benny.ai/code-test/heart-rate-monitor/data.zip

### ✔️ Implemented

The application includes a custom import pipeline that downloads, extracts, and ingests the provided dataset into a relational PostgreSQL schema.

To make this easy to run locally, I documented a **single command** that:

- Downloads the dataset
- Unzips it
- Imports all data into the database

```bash
mkdir -p tmp/hrm_data && \
curl -L https://assets.benny.ai/code-test/heart-rate-monitor/data.zip -o tmp/hrm_data/data.zip && \
unzip -oq tmp/hrm_data/data.zip -d tmp/hrm_data && \
bin/rails hrm:import FOLDER=tmp/hrm_data
```

Note: If you omit `-o` when unzipping, unzip may prompt to overwrite files. This is expected behavior and safe to approve.

---

## Core Goal

Build a Rails app that provides a visualization and reporting interface. UI/UX quality and performance on a large dataset are evaluated.

### ✔️ Implemented

The application provides:

- A session listing UI ordered by recency
- Per-session summary metrics
- Interactive time-series visualizations
- Global aggregate statistics across all users and sessions

The UI is intentionally minimal and readable, optimized for scanning metrics and drilling into individual sessions.

---

## Feature Requirements

### 1️⃣ Display a listing of all HRM sessions (most recent first)

For each session, the app displays:

- ✅ Minimum, maximum, and average heart rate  
  Calculated using duration-weighted averages, not simple means  
  Avoids skew from uneven BPM sampling intervals

- ✅ Time spent in each heart rate zone  
  Zone thresholds are user-specific  
  Each data point contributes time to the appropriate zone  
  Aggregated per session and displayed as readable totals

- ✅ Visualization of HRM data points  
  Line chart visualization of BPM over time  
  Rendered per session using Chart.js  
  Efficiently scoped queries to avoid loading unnecessary records

### 2️⃣ Display overall minimum, maximum, and average heart rate (all sessions)

✅ Implemented

- Global aggregates computed across all sessions
- Duration-weighted average for accuracy
- Displayed prominently at the top of the reporting interface

### 3️⃣ Display % of time spent in each heart rate zone (all users)

✅ Implemented

- Aggregates zone durations across all sessions
- Calculates percentages relative to total recorded time
- Clearly presented for high-level analysis

---

## Guidelines & How They Were Addressed

- ✔️ Must use Ruby on Rails  
  Rails 7 used as the core platform

- ✔️ Schema flexibility allowed  
  CSVs translated into normalized relational tables  
  Added computed fields for performance (session summaries)

- ✔️ Free to use gems / JS frameworks  
  Chart.js for visualization  
  Standard Rails + ActiveRecord tooling otherwise

- ✔️ Not all features required  
  Prioritized correctness, performance, and clarity  
  Left room for extension (pagination, filters, caching)

- ✔️ No auth / security required  
  Application intentionally unauthenticated

- ✔️ Performance matters  
  Key performance decisions:

  - Streaming CSV reads (no full file loads)
  - Batched inserts
  - Precomputed session-level metrics
  - Avoided N+1 queries in reporting views

- ✔️ Creative freedom  
  Focused on a clean reporting dashboard  
  Structured code for easy extension

- ✔️ Easy to run locally  
  One-line import  
  Clear setup steps (below)

---

## Data Model & Schema Design

### Users

Stores:

- Demographics
- Heart rate zone thresholds (zone 1–4 min/max)

### HRM Sessions

Stores:

- User association
- Session duration
- Imported timestamp
- Precomputed summary metrics

### HRM Data Points

Stores:

- BPM readings
- Start/end timestamps
- Duration (used for weighted averages)

---

## Local Setup Instructions

### Requirements

- Ruby (compatible with `.ruby-version`)
- PostgreSQL
- Node/Yarn (for assets)

### Setup

```bash
git clone https://github.com/Wmitbrodt/hrm_reporter.git
cd hrm_reporter
bundle install
bin/rails db:create db:migrate
```

### Import Data

```bash
mkdir -p tmp/hrm_data && \
curl -L https://assets.benny.ai/code-test/heart-rate-monitor/data.zip -o tmp/hrm_data/data.zip && \
unzip -oq tmp/hrm_data/data.zip -d tmp/hrm_data && \
bin/rails hrm:import FOLDER=tmp/hrm_data
```

### Run the App

```bash
bin/rails server
```

Then visit:  
http://localhost:3000

---

## Notes on Deployment

Deployment was not a requirement of the assignment. Given the size of the dataset (~1GB CSV), the focus was placed on:

- Data modeling
- Import correctness
- Query performance
- UI clarity

With additional time, production deployment could be handled via:

- Background job–based imports
- COPY-based ingestion
- Pre-seeded database snapshots

---

## What I Would Do Next With More Time

- Pagination and filtering for sessions
- Background job–based imports
- Caching of aggregate metrics
- More interactive chart tooling (hover states, comparisons)
- Exportable reports

---

## Optional Walkthrough

I’m happy to walk through:

- The data import pipeline
- Performance decisions
- UI tradeoffs
- Schema design

A short Loom walkthrough can be provided if helpful.

---

## Final Notes

This project was completed within the intended timebox, prioritizing:

- Correct data handling
- Performance on large datasets
- Clear, maintainable architecture

Thanks for reviewing — I’m happy to discuss any part of the solution in more detail.

— Will
