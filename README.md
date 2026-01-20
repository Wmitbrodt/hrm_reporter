# Heart Rate Monitor Reporting App

## Rails Code Test Submission

This repository contains my solution to the Heart Rate Monitor (HRM) Rails code test. The goal of the exercise was to ingest a large relational CSV dataset and build a performant, user-friendly reporting and visualization interface.

The emphasis of my approach was:

- Correctness of heart-rate calculations  
- Performance on a large dataset  
- Clear UI/UX for reviewing session and aggregate data  
- Clean, explainable architecture within the 3-hour time constraint  

---

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
