#!/bin/bash
# SQL*Loader Runner for macOS/Linux (ZTB project)
# Auto-generated to duplicate SQL*Loader commands for Docker environment.

# --- Colors for beautiful output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
CLEAR='\033[0m'

# --- Configuration ---
CONTAINER_NAME="ztb-oracle-db"
SQLLDR_PATH="/opt/oracle/product/26ai/dbhomeFree/bin/sqlldr"
DB_CONN="system/ZtbOracle123!@FREE"

# Get absolute path to this script's directory for robust execution from anywhere
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV_DIR="$SCRIPT_DIR/csv"
CTL_DIR="$SCRIPT_DIR/ctl"

echo -e "${BLUE}${BOLD}===================================================${CLEAR}"
echo -e "${BLUE}${BOLD}   [ZTB] SQL*Loader Data Loader (Docker macOS)      ${CLEAR}"
echo -e "${BLUE}${BOLD}===================================================${CLEAR}"

# --- Functions ---

# Verifies all system and environment requirements are met
check_requirements() {
    # 1. Check if docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: 'docker' command is not installed!${CLEAR}"
        exit 1
    fi

    # 2. Check if target container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${RED}Error: Docker container '$CONTAINER_NAME' is not running!${CLEAR}"
        echo -e "Please start your container before running this script."
        exit 1
    fi
}

# Prepares target directories inside the Docker container
prepare_directories() {
    echo -e "\n${GREEN}Using Docker execution inside '$CONTAINER_NAME'...${CLEAR}"
    echo -e "${BLUE}Preparing container directories under /tmp/sqlldr/...${CLEAR}"
    docker exec -u root "$CONTAINER_NAME" mkdir -p /tmp/sqlldr/csv /tmp/sqlldr/ctl /tmp/sqlldr/log /tmp/sqlldr/bad
}

# Copies files into container and applies CRLF to LF conversions and permissions adjustments
copy_and_convert_files() {
    echo -e "${BLUE}Copying CTL files to Docker container...${CLEAR}"
    docker cp "$CTL_DIR/." "$CONTAINER_NAME":/tmp/sqlldr/ctl/

    echo -e "${BLUE}Copying and converting CSV files (CRLF -> LF on the fly)...${CLEAR}"
    for csv_file in "$CSV_DIR"/*.csv; do
        filename=$(basename "$csv_file")
        # Optimal solution: Stream the CSV through 'tr' directly into the container's bash via stdin as root,
        # avoiding disk writes of temporary files on the host computer.
        docker exec -u root -i "$CONTAINER_NAME" sh -c "tr -d '\r' > /tmp/sqlldr/csv/$filename" < "$csv_file"
    done

    # Set permissions so the 'oracle' database user can read/write everything in the directory
    docker exec -u root "$CONTAINER_NAME" chmod -R 777 /tmp/sqlldr

    echo -e "${GREEN}Files copied and permissions set successfully!${CLEAR}\n"
}

# Runs the SQL*Loader utility for a single table inside the container
run_sqlldr() {
    local name=$1
    echo -e "${BLUE}Loading $name inside Docker...${CLEAR}"
    docker exec "$CONTAINER_NAME" bash -lc \
        "NLS_NUMERIC_CHARACTERS='.,' $SQLLDR_PATH $DB_CONN \
        control=/tmp/sqlldr/ctl/${name}.ctl \
        log=/tmp/sqlldr/log/${name}.log \
        bad=/tmp/sqlldr/bad/${name}.bad"
}

# Orchestrates the loading pipeline in strict order of FK dependencies
run_all_loaders() {
    run_sqlldr "p_72_panstwo"
    run_sqlldr "p_72_wojewodztwo"
    run_sqlldr "p_72_miasto"
    run_sqlldr "p_72_ulica"
    run_sqlldr "p_72_oddzial"
    run_sqlldr "p_72_stanowisko"
    run_sqlldr "p_72_pracownik"
    run_sqlldr "p_72_kategoria"
    run_sqlldr "p_72_kolor"
    run_sqlldr "p_72_marka"
    run_sqlldr "p_72_model"
    run_sqlldr "p_72_typ_paliwa"
    run_sqlldr "p_72_typ_skrzyni"
    run_sqlldr "p_72_samochod"
    run_sqlldr "p_72_typ_ubezpieczenia"
    run_sqlldr "p_72_ubezpieczenie"
    run_sqlldr "p_72_klient"
    run_sqlldr "p_72_wypozyczenia"
}

# --- Main Logic ---
check_requirements
prepare_directories
copy_and_convert_files
run_all_loaders

echo -e "\n${GREEN}${BOLD}===================================================${CLEAR}"
echo -e "${GREEN}${BOLD}   [ZTB] SQL*Loader run finished successfully!     ${CLEAR}"
echo -e "${GREEN}${BOLD}===================================================${CLEAR}"
