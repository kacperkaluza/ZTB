-- ZTB Project - ETL Data Warehouse Population Script (dane_hurtownia.sql)
-- Prefix: h_72_
-- Target Engine: Oracle Database 23ai
-- Strict restriction: Forbidden to use `opis` columns in any SQL queries.

SET ECHO ON;
SET FEEDBACK ON;

---------------------------------------------------------
-- Krok 1: Czyszczenie tabel (od tabeli faktów do wymiarów)
---------------------------------------------------------
PROMPT [ETL] Truncating target DWH tables...

TRUNCATE TABLE h_72_Wypozyczenia;
TRUNCATE TABLE h_72_Klient;
TRUNCATE TABLE h_72_Samochod;
TRUNCATE TABLE h_72_Oddzial;
TRUNCATE TABLE h_72_Pracownik;
TRUNCATE TABLE h_72_Ubezpieczenie;
TRUNCATE TABLE h_72_Data;

---------------------------------------------------------
-- Krok 2: Zasilanie wymiaru H_72_Klient (Klienci)
---------------------------------------------------------
PROMPT [ETL] Loading h_72_Klient...

INSERT INTO h_72_Klient (ID_Klient, Imie, Nazwisko)
SELECT ID_Klient, Imie, Nazwisko 
FROM p_72_Klient;

---------------------------------------------------------
-- Krok 3: Zasilanie wymiaru H_72_Samochod (Samochody - Denormalizacja)
---------------------------------------------------------
PROMPT [ETL] Loading h_72_Samochod...

INSERT INTO h_72_Samochod (
    ID_Samochod,
    ID_Model,
    ID_Marka,
    ID_Kategoria,
    ID_Typu_Paliwa,
    Nazwa_Modelu,
    Nazwa_Marki,
    Nazwa_Paliwa,
    Nazwa_Kategorii
)
SELECT 
    s.ID_Samochod,
    s.ID_Model,
    m.ID_Marka,
    s.ID_Kategoria,
    s.ID_Typu_Paliwa,
    m.Nazwa_Modelu,
    mk.Nazwa_Marki,
    tp.Nazwa_Paliwa,
    kt.Nazwa_Kategorii
FROM p_72_Samochod s
JOIN p_72_Model m ON s.ID_Model = m.ID_Model
JOIN p_72_Marka mk ON m.ID_Marka = mk.ID_Marka
JOIN p_72_Typ_Paliwa tp ON s.ID_Typu_Paliwa = tp.ID_Typu_Paliwa
JOIN p_72_Kategoria kt ON s.ID_Kategoria = kt.ID_Kategoria;

---------------------------------------------------------
-- Krok 4: Zasilanie wymiaru H_72_Oddzial (Oddziały - Denormalizacja)
---------------------------------------------------------
PROMPT [ETL] Loading h_72_Oddzial...

INSERT INTO h_72_Oddzial (
    ID_Oddzial,
    ID_Miasta,
    ID_Wojewodztwo,
    ID_Panstwa,
    Nazwa_Oddzialu,
    Nazwa_Miasta,
    Nazwa_Wojewodztwa,
    Nazwa_Panstwa
)
SELECT 
    o.ID_Oddzial,
    u.ID_Miasta,
    m.ID_Wojewodztwo,
    w.ID_Panstwa,
    o.Nazwa_Oddzialu,
    m.Nazwa_Miasta,
    w.Nazwa_Wojewodztwa,
    p.Nazwa_Panstwa
FROM p_72_Oddzial o
JOIN p_72_Ulica u ON o.ID_Ulica = u.ID_Ulica
JOIN p_72_Miasto m ON u.ID_Miasta = m.ID_Miasta
JOIN p_72_Wojewodztwo w ON m.ID_Wojewodztwo = w.ID_Wojewodztwo
JOIN p_72_Panstwo p ON w.ID_Panstwa = p.ID_Panstwa;

---------------------------------------------------------
-- Krok 5: Zasilanie wymiaru H_72_Pracownik (Pracownicy - Denormalizacja)
---------------------------------------------------------
PROMPT [ETL] Loading h_72_Pracownik...

INSERT INTO h_72_Pracownik (
    ID_Pracownik,
    ID_Stanowisko,
    Nazwisko,
    Nazwa_Stanowiska
)
SELECT 
    p.ID_Pracownik,
    p.ID_Stanowisko,
    p.Nazwisko,
    s.Nazwa_Stanowiska
FROM p_72_Pracownik p
JOIN p_72_Stanowisko s ON p.ID_Stanowisko = s.ID_Stanowisko;

---------------------------------------------------------
-- Krok 6: Zasilanie wymiaru H_72_Ubezpieczenie (Ubezpieczenia - Denormalizacja)
---------------------------------------------------------
PROMPT [ETL] Loading h_72_Ubezpieczenie...

INSERT INTO h_72_Ubezpieczenie (
    ID_Ubezpieczenie,
    ID_Typu_Ubezpieczenia,
    Nazwa_Typu
)
SELECT 
    u.ID_Ubezpieczenie,
    u.ID_Typu_Ubezpieczenia,
    t.Nazwa_Typu
FROM p_72_Ubezpieczenie u
JOIN p_72_Typ_Ubezpieczenia t ON u.ID_Typu_Ubezpieczenia = t.ID_Typu_Ubezpieczenia;

---------------------------------------------------------
-- Krok 7: Zasilanie wymiaru H_72_Data (Czas / Kalendarz)
-- Unikalne daty wydania ze wszystkich transakcji w bazie
---------------------------------------------------------
PROMPT [ETL] Loading h_72_Data...

INSERT INTO h_72_Data (
    ID_Daty, Pelna_Data, Dzien, Miesiac, Nazwa_Miesiaca, Kwartal, Rok, Dzien_Tygodnia, Czy_Weekend
)
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(Data_Wydania, 'YYYYMMDD')) AS ID_Daty,
    TRUNC(Data_Wydania) AS Pelna_Data,
    TO_NUMBER(TO_CHAR(Data_Wydania, 'DD')) AS Dzien,
    TO_NUMBER(TO_CHAR(Data_Wydania, 'MM')) AS Miesiac,
    TRIM(TO_CHAR(Data_Wydania, 'Month')) AS Nazwa_Miesiaca,
    TO_NUMBER(TO_CHAR(Data_Wydania, 'Q')) AS Kwartal,
    TO_NUMBER(TO_CHAR(Data_Wydania, 'YYYY')) AS Rok,
    TRIM(TO_CHAR(Data_Wydania, 'Day')) AS Dzien_Tygodnia,
    CASE WHEN TO_CHAR(Data_Wydania, 'DY', 'NLS_DATE_LANGUAGE=english') IN ('SAT', 'SUN') THEN 'Y' ELSE 'N' END AS Czy_Weekend
FROM p_72_Wypozyczenia
WHERE Data_Wydania IS NOT NULL;

---------------------------------------------------------
-- Krok 8: Zasilanie centralnej tabeli faktów H_72_Wypozyczenia
---------------------------------------------------------
PROMPT [ETL] Loading fact table h_72_Wypozyczenia (this might take a few seconds)...

INSERT INTO h_72_Wypozyczenia (
    ID_Samochod,
    ID_Klient,
    ID_Oddzial_Wydania,
    ID_Pracownik_Wydania,
    ID_Ubezpieczenie,
    Status_Wypozyczenia,
    Data_Wydania,
    Cena_Doba
)
SELECT DISTINCT
    ID_Samochod,
    ID_Klient,
    ID_Oddzial_Wydania,
    ID_Pracownik_Wydania,
    ID_Ubezpieczenie,
    Status_Wypozyczenia,
    Data_Wydania,
    Cena_Doba
FROM p_72_Wypozyczenia
WHERE Data_Wydania IS NOT NULL;

---------------------------------------------------------
-- Krok 9: Zatwierdzenie transakcji
---------------------------------------------------------
PROMPT [ETL] Committing transaction...

COMMIT;

PROMPT [ETL] Data Warehouse successfully populated!
