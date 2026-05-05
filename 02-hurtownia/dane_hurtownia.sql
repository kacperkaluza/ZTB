-- ETL Procedures for Data Warehouse
-- Using h_72_ prefix

-- 1. Clear Data Warehouse
TRUNCATE TABLE h_72_wypozyczenie;
DELETE FROM h_72_klient;
DELETE FROM h_72_samochod;
DELETE FROM h_72_oddzial;
DELETE FROM h_72_pracownik;
DELETE FROM h_72_czas;

-- 2. Populate Dimension: Time
BEGIN
  FOR i IN 0..1825 LOOP
    INSERT INTO h_72_czas (
      id_czas, data, dzien, miesiac, rok, kwartal, dzien_tygodnia, czy_weekend
    )
    SELECT 
      TO_NUMBER(TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD') + i, 'YYYYMMDD')),
      TO_DATE('2024-01-01', 'YYYY-MM-DD') + i,
      TO_NUMBER(TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD') + i, 'DD')),
      TO_NUMBER(TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD') + i, 'MM')),
      TO_NUMBER(TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD') + i, 'YYYY')),
      TO_NUMBER(TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD') + i, 'Q')),
      TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD') + i, 'DAY'),
      CASE WHEN TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD') + i, 'D') IN ('6', '7') THEN 1 ELSE 0 END
    FROM dual;
  END LOOP;
  COMMIT;
END;
/

-- 3. Populate Dimension: Client
INSERT INTO h_72_klient (id_klient_dw, id_klient_src, imie, nazwisko, pesel, miasto, wojewodztwo, panstwo)
SELECT 
    ID_Klient,
    ID_Klient,
    Imie,
    Nazwisko,
    PESEL,
    'Nieznane',
    'Nieznane',
    'Nieznane'
FROM p_72_Klient;

-- 4. Populate Dimension: Car
INSERT INTO h_72_samochod (id_samochod_dw, id_samochod_src, marka, model, kategoria, kolor, typ_paliwa, rok_produkcji)
SELECT 
    s.ID_Samochod,
    s.ID_Samochod,
    m.Nazwa_Marki,
    mo.Nazwa_Modelu,
    k.Nazwa_Kategorii,
    ko.Nazwa_Koloru,
    tp.Nazwa_Paliwa,
    s.Rok_Produkcji
FROM p_72_Samochod s
JOIN p_72_Model mo ON s.ID_Model = mo.ID_Model
JOIN p_72_Marka m ON mo.ID_Marka = m.ID_Marka
JOIN p_72_Kategoria k ON s.ID_Kategoria = k.ID_Kategoria
JOIN p_72_Kolor ko ON s.ID_Kolor = ko.ID_Kolor
JOIN p_72_Typ_Paliwa tp ON s.ID_Typu_Paliwa = tp.ID_Typu_Paliwa;

-- 5. Populate Dimension: Branch
INSERT INTO h_72_oddzial (id_oddzial_dw, id_oddzial_src, nazwa_oddzialu, miasto, wojewodztwo)
SELECT 
    o.ID_Oddzial,
    o.ID_Oddzial,
    o.Nazwa_Oddzialu,
    mi.Nazwa_Miasta,
    w.Nazwa_Wojewodztwa
FROM p_72_Oddzial o
JOIN p_72_Ulica u ON o.ID_Ulica = u.ID_Ulica
JOIN p_72_Miasto mi ON u.ID_Miasta = mi.ID_Miasta
JOIN p_72_Wojewodztwo w ON mi.ID_Wojewodztwo = w.ID_Wojewodztwo;

-- 6. Populate Dimension: Employee
INSERT INTO h_72_pracownik (id_pracownik_dw, id_pracownik_src, imie, nazwisko, stanowisko)
SELECT 
    p.ID_Pracownik,
    p.ID_Pracownik,
    p.Imie,
    p.Nazwisko,
    s.Nazwa_Stanowiska
FROM p_72_Pracownik p
JOIN p_72_Stanowisko s ON p.ID_Stanowisko = s.ID_Stanowisko;

-- 7. Populate Fact Table: Rentals
INSERT INTO h_72_wypozyczenie (
    id_wypozyczenia_dw, id_klient_dw, id_samochod_dw, id_oddzial_wydania_dw, 
    id_oddzial_odbioru_dw, id_pracownik_wydania_dw, id_pracownik_odbioru_dw,
    id_data_wydania, id_data_zwrotu,
    cena_doba, liczba_dni, koszt_netto, koszt_brutto, kaucja, 
    rabat_procent, dystans_km, kara_za_opoznienie
)
SELECT 
    ROWNUM,
    ID_Klient,
    ID_Samochod,
    ID_Oddzial_Wydania,
    ID_Oddzial_Odbioru,
    ID_Pracownik_Wydania,
    ID_Pracownik_Odbioru,
    TO_NUMBER(TO_CHAR(Data_Wydania, 'YYYYMMDD')),
    TO_NUMBER(TO_CHAR(Data_Faktycznego_Zwrotu, 'YYYYMMDD')),
    Cena_Doba,
    (Data_Faktycznego_Zwrotu - Data_Wydania),
    (Cena_Doba * (Data_Faktycznego_Zwrotu - Data_Wydania)),
    (Cena_Doba * (Data_Faktycznego_Zwrotu - Data_Wydania) * 1.23),
    Kaucja,
    Cena_Rabat_Procent,
    (Przebieg_Finish - Przebieg_Start),
    CASE WHEN Data_Faktycznego_Zwrotu > Data_Planowanego_Zwrotu THEN 100 ELSE 0 END
FROM p_72_Wypozyczenia;

COMMIT;
