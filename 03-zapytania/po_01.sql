-- =============================================================================
-- po_01.sql — PARTYCJE OBLICZENIOWE: Udzial przychodu marki w wojewodztwie
-- =============================================================================
-- Pytanie biznesowe:
--   Jaki udzial procentowy w lacznym przychodzie wojewodztwa ma kazda marka
--   samochodow? Pozwala zidentyfikowac dominujace marki w regionach.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Samochod → Model → Marka
--   2) Wypozyczenia → Oddzial (wydania) → Ulica → Miasto → Wojewodztwo
--   3) Wypozyczenia → Samochod → Kategoria
--
-- Miary: Cena_Doba, wyliczany koszt_calkowity
-- =============================================================================

SELECT
    woj.ID_Wojewodztwo,
    MIN(woj.Nazwa_Wojewodztwa)                                       AS Nazwa_Wojewodztwa,
    mar.ID_Marka,
    MIN(mar.Nazwa_Marki)                                             AS Nazwa_Marki,
    kat.ID_Kategoria,
    MIN(kat.Nazwa_Kategorii)                                         AS Nazwa_Kategorii,
    COUNT(*)                                                         AS liczba_wypozyczen,
    SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania)) AS przychod_marki,

    -- Partycja obliczeniowa: laczny przychod w wojewodztwie
    SUM(SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania)))
        OVER (PARTITION BY woj.ID_Wojewodztwo)                       AS przychod_wojewodztwa,

    -- Udzial procentowy marki w przychodzie wojewodztwa
    ROUND(
        SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania))
        / NULLIF(
            SUM(SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania)))
                OVER (PARTITION BY woj.ID_Wojewodztwo),
            0
          ) * 100,
        2
    )                                                                AS udzial_procentowy

FROM
    p_72_Wypozyczenia w
    JOIN p_72_Samochod    sam ON w.ID_Samochod         = sam.ID_Samochod
    JOIN p_72_Model       mod ON sam.ID_Model           = mod.ID_Model
    JOIN p_72_Marka       mar ON mod.ID_Marka           = mar.ID_Marka
    JOIN p_72_Kategoria   kat ON sam.ID_Kategoria        = kat.ID_Kategoria
    JOIN p_72_Oddzial     odd ON w.ID_Oddzial_Wydania    = odd.ID_Oddzial
    JOIN p_72_Ulica       ul  ON odd.ID_Ulica             = ul.ID_Ulica
    JOIN p_72_Miasto      mia ON ul.ID_Miasta              = mia.ID_Miasta
    JOIN p_72_Wojewodztwo woj ON mia.ID_Wojewodztwo        = woj.ID_Wojewodztwo
WHERE
    w.Data_Faktycznego_Zwrotu IS NOT NULL
GROUP BY
    woj.ID_Wojewodztwo,
    mar.ID_Marka,
    kat.ID_Kategoria
ORDER BY
    woj.ID_Wojewodztwo,
    przychod_marki DESC;
