#!/bin/bash
# ZTB Project - Database Environment Setup Orchestrator
# Auto-generated to simplify setup & populating the Oracle Database environment.

# --- Colors for premium console output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
CLEAR='\033[0m'

CONTAINER_NAME="ztb-oracle-db"
DB_USER="system"
DB_PASS="ZtbOracle123!"
DB_SERVICE="FREE"

echo -e "${PURPLE}${BOLD}=====================================================${CLEAR}"
echo -e "${PURPLE}${BOLD}   💎 ZTB ORACLE DATABASE ENVIRONMENT BUILDER 💎     ${CLEAR}"
echo -e "${PURPLE}${BOLD}=====================================================${CLEAR}"

# Helper function to print headers
print_step() {
    echo -e "\n${CYAN}${BOLD}▶ Step $1: $2${CLEAR}"
}

# 1. Start Docker Container
print_step "1" "Starting Oracle Database Docker Container"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Error: docker is not installed. Please install Docker first.${CLEAR}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Error: docker-compose is not installed.${CLEAR}"
    exit 1
fi

echo -e "${BLUE}Running docker-compose up...${CLEAR}"
docker compose up -d

# 2. Wait for Oracle to be ready
print_step "2" "Waiting for Oracle Database to fully initialize"
echo -e "${YELLOW}Note: Oracle Database 26ai initial startup can take 1-2 minutes...${CLEAR}"

spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
count=0
start_time=$SECONDS

while true; do
    # Try connecting to sqlplus inside the container to check health
    if docker exec "$CONTAINER_NAME" sqlplus -L "$DB_USER/$DB_PASS@$DB_SERVICE" <<< "EXIT;" &> /dev/null; then
        break
    fi
    
    elapsed=$(( SECONDS - start_time ))
    spin_idx=$(( count % 10 ))
    echo -ne "\r${YELLOW}${spinner[spin_idx]} Database is starting up... (Elapsed: ${elapsed}s)${CLEAR}"
    sleep 2
    count=$(( count + 1 ))
    
    # Fail-safe after 5 minutes
    if [ $elapsed -gt 300 ]; then
        echo -e "\n${RED}❌ Timeout: Oracle Database took too long to start. Check logs via 'docker logs $CONTAINER_NAME'.${CLEAR}"
        exit 1
    fi
done

echo -e "\n${GREEN}✅ Database is up, running, and accepting connections!${CLEAR}"

# 3. Create Schema Tables
print_step "3" "Deploying Database Schema (schema.ddl)"
echo -e "${BLUE}Running DDL script via SQL*Plus...${CLEAR}"
# Inject an exit command at the end of the DDL to guarantee SQL*Plus terminates
(cat 01-baza/schema.ddl; echo -e "\nEXIT;") | docker exec -i "$CONTAINER_NAME" sqlplus -s "$DB_USER/$DB_PASS@$DB_SERVICE" > /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Tables and constraints created successfully!${CLEAR}"
else
    echo -e "${RED}❌ Error during schema deployment. Check schema.ddl file.${CLEAR}"
    exit 1
fi

# 4. Generate Mock Data CSVs
print_step "4" "Generating Mock Data (100k records via generator)"
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}⚠️ 'uv' python manager not found on host. Attempting standard 'python3'...${CLEAR}"
    if command -v python3 &> /dev/null; then
        python3 -m pip install faker tqdm &> /dev/null
        python3 01-baza/sqlldr/generator_danych.py
    else
        echo -e "${RED}❌ Error: python3 is required to generate mock data.${CLEAR}"
        exit 1
    fi
else
    echo -e "${BLUE}Running generator via uv...${CLEAR}"
    uv run 01-baza/sqlldr/generator_danych.py
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Mock CSV and CTL files generated locally!${CLEAR}"
else
    echo -e "${RED}❌ Data generation failed.${CLEAR}"
    exit 1
fi

# 5. Populate via SQL*Loader
print_step "5" "Loading Data using SQL*Loader inside Docker"
./01-baza/sqlldr/0-sqlldr-docker.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Data loaded successfully!${CLEAR}"
else
    echo -e "${RED}❌ SQL*Loader import failed.${CLEAR}"
    exit 1
fi

echo -e "\n${GREEN}${BOLD}=====================================================${CLEAR}"
echo -e "${GREEN}${BOLD}   🎉 ENVIRONMENT SETUP COMPLETED SUCCESSFULLY! 🎉   ${CLEAR}"
echo -e "${GREEN}${BOLD}=====================================================${CLEAR}"
echo -e "You can now connect to the database at:"
echo -e "  Host:      ${BOLD}localhost${CLEAR}"
echo -e "  Port:      ${BOLD}1521${CLEAR}"
echo -e "  Service:   ${BOLD}FREE${CLEAR}"
echo -e "  User/Pass: ${BOLD}system / ZtbOracle123!${CLEAR}\n"
