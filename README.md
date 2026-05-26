# Project ZTB

```bash
git clone https://github.com/kacperkaluza/ZTB.git
```

## Tool versions

- Oracle SQL Developer Data Modeler: 24.3.1.351
- Java runtime: 25.0.1 (2025-10-21 LTS)
- Git: 2.50.1 (Apple Git-155)

## Database Schema

![Database Schema](Schema.png)

## ⚡ Quick Start & One-Command Setup

To make onboarding and setting up the database environment as simple as possible, a root orchestration script (`setup.sh`) is provided. This automates the container startup, health checks, schema deployment, mock data generation, and SQL*Loader populating in **one single command**.

### Automatic Environment Build

To fully build, deploy, and seed your Oracle Database free environment, run:

```bash
./setup.sh
```

**What this orchestrator script does for you:**
1. **Docker Container Launch:** Spins up the Oracle Database 26ai Free container (`docker compose up -d`).
2. **Robust Connection Polling:** Actively polls the container via `sqlplus` with an active loader spinner until the database is fully online and accepting connections (averting initialization-phase connection failures).
3. **Automatic Schema Deployment:** Deploys the database tables and constraints (`schema.ddl`) directly into the container.
4. **Mock Data Generation:** Generates extremely realistic automotive and transaction data (exactly 100,000 transaction rows) using Faker.
5. **SQL*Loader Loading:** Copies files and bulk-loads all 18 tables in correct Foreign Key sequence.

---

### Prerequisites

- Docker Desktop / Docker Engine.
- Access to Oracle Container Registry (if running for the first time, accept the license terms for `container-registry.oracle.com/database/free` and run `docker login container-registry.oracle.com`).
- Python runtime (`uv` recommended, but standard `python3` with `faker` and `tqdm` is also supported as a fallback).

### Connection Details

- **Host:** `localhost`
- **Port:** `1521`
- **Service:** `FREE`
- **User:** `system`
- **Password:** `ZtbOracle123!`

### Persistence

Database files are stored in the named Docker volume `oracle_data`, so the data survives container recreation.

