#!/bin/bash

DB_USER="system"
DB_PASS="ZtbOracle123!"
DB_SERVICE="FREE"

echo "Loading data into Oracle Database..."

# Array of tables in correct load order
tables=(
  "p_72_panstwo"
  "p_72_wojewodztwo"
  "p_72_miasto"
  "p_72_ulica"
  "p_72_oddzial"
  "p_72_stanowisko"
  "p_72_pracownik"
  "p_72_kategoria"
  "p_72_kolor"
  "p_72_marka"
  "p_72_model"
  "p_72_typ_paliwa"
  "p_72_typ_skrzyni"
  "p_72_samochod"
  "p_72_typ_ubezpieczenia"
  "p_72_ubezpieczenie"
  "p_72_klient"
  "p_72_wypozyczenia"
)

for table in "${tables[@]}"; do
  echo "Loading $table..."
  sqlldr ${DB_USER}/${DB_PASS}@${DB_SERVICE} control=ctl/${table}.ctl log=csv/${table}.log
done

echo "Data loading completed."
