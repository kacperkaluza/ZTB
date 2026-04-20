# SQL*Loader

This folder contains a full CSV-based loading pipeline for all project tables.

## Main script

- `run_full_pipeline.ps1`

## What it does

1. Generates realistic CSV data (`csv/`) for all tables (total 108008 rows)
2. Cleans target tables in FK-safe order
3. Loads all tables with SQL*Loader
4. Exports verification reports to `report/`

## Run

From repository root:

```powershell
./sqlldr/run_full_pipeline.ps1
```

## Output reports

- `report/counts_actual.csv`
- `report/total_rows.csv`
