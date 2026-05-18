# GEMINI - Project: System of Car Rental Saloons

## 1. Project Overview
- **Topic:** Academic Database and Data Warehouse for a Car Rental System.
- **Goal:** Comprehensive implementation from source DB to DWH with ETL and complex OLAP queries.
- **Database Engine:** Oracle Database 23ai.

## 2. Technical Requirements
- **Source Schema:** Minimum 15 tables and 10 measures.
- **Data Population:** 
  - Basic tables: 10 - 1,000 rows.
  - Transaction table (`Wypozyczenie`): Exactly 100,000 records.
  - Tool: SQL*Loader (`.ctl` files + `.bat` for execution).
- **Data Warehouse:**
  - Designed based on the source schema.
  - Includes ETL procedures (Extract, Transform, Load).
  - Validation: 15 identical queries must return the same results on both DB and DWH.
- **Restrictions:**
  - Forbidden to use `opis` columns in any SQL queries.

## 3. Directory Structure (Mandatory)
- `01-baza/`: `baza.sql` (schema), `dane_baza.bat` (SQL*Loader runner).
- `02-hurtownia/`: `hurtownia.sql` (DWH schema), `dane_hurtownia.sql` (ETL procedures).
- `03-zapytania/`: 15 SQL files named:
  - `ro_01.sql` to `ro_03.sql` (ROLLUP)
  - `cu_01.sql` to `cu_03.sql` (CUBE)
  - `po_01.sql` to `po_03.sql` (Calculation Partitions)
  - `ok_01.sql` to `ok_03.sql` (Windows)
  - `fr_01.sql` to `fr_03.sql` (Ranking Functions)

## 4. Current State
- `projekt_bazy_wypozyczalnia.md` contains the logical schema and relationship definitions.
- Transactional measures identified: `liczba_dni`, `koszt_netto`, `koszt_brutto`, `kaucja`, `rabat_procent`, `rabat_kwota`, `dystans_km`, `kara_za_opoznienie`, `koszt_ubezpieczenia`, `koszt_paliwa`.

