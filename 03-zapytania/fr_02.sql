-- =============================================================================
-- fr_02.sql — RANKING: Top pojazdy wg wykorzystania (dni wynajmu) per kategoria
-- =============================================================================
-- Pytanie biznesowe:
--   Ktore samochody sa najczesciej i najdluzej wypozyczane w kazdej kategorii?
--   RANK() wg lacznej liczby dni wynajmu — kluczowe dla planowania floty.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Samochod → Model → Marka
--   2) Wypozyczenia → Samochod → Kategoria
--   3) Wypozyczenia → Samochod → Kolor
--   4) Wypozyczenia → Samochod → Typ_Skrzyni
--
-- Miary: Data_Wydania, Data_Faktycznego_Zwrotu (wyliczana liczba_dni), Przebieg_Limit
-- =============================================================================

WITH wykorzystanie_pojazdow AS (
    SELECT
        sam.ID_Samochod,
        sam.ID_Kategoria,
        MIN(kat.Nazwa_Kategorii)                                    AS Nazwa_Kategorii,
        MIN(mar.Nazwa_Marki)                                        AS Nazwa_Marki,
        MIN(mod.Nazwa_Modelu)                                       AS Nazwa_Modelu,
        MIN(kol.Nazwa_Koloru)                                       AS Nazwa_Koloru,
        MIN(ts.Nazwa_Skrzyni)                                       AS Nazwa_Skrzyni,
        MIN(sam.Numer_Rejestracyjny)                                AS Numer_Rejestracyjny,
        MIN(sam.Rok_Produkcji)                                      AS Rok_Produkcji,
        COUNT(*)                                                    AS liczba_wypozyczen,
        SUM(w.Data_Faktycznego_Zwrotu - w.Data_Wydania)            AS laczna_liczba_dni,
        ROUND(AVG(w.Data_Faktycznego_Zwrotu - w.Data_Wydania), 1)  AS srednia_liczba_dni,
        ROUND(AVG(w.Przebieg_Limit), 0)                             AS sredni_limit_przebiegu,
        MIN(w.Data_Wydania)                                          AS pierwsze_wypozyczenie,
        MAX(w.Data_Faktycznego_Zwrotu)                               AS ostatni_zwrot
    FROM
        p_72_Wypozyczenia w
        JOIN p_72_Samochod    sam ON w.ID_Samochod       = sam.ID_Samochod
        JOIN p_72_Model       mod ON sam.ID_Model         = mod.ID_Model
        JOIN p_72_Marka       mar ON mod.ID_Marka         = mar.ID_Marka
        JOIN p_72_Kategoria   kat ON sam.ID_Kategoria      = kat.ID_Kategoria
        JOIN p_72_Kolor       kol ON sam.ID_Kolor          = kol.ID_Kolor
        JOIN p_72_Typ_Skrzyni ts  ON sam.ID_Typu_Skrzyni   = ts.ID_Typu_Skrzyni
    WHERE
        w.Data_Faktycznego_Zwrotu IS NOT NULL
    GROUP BY
        sam.ID_Samochod,
        sam.ID_Kategoria
)
SELECT
    ID_Samochod,
    ID_Kategoria,
    Nazwa_Kategorii,
    Nazwa_Marki,
    Nazwa_Modelu,
    Nazwa_Koloru,
    Nazwa_Skrzyni,
    Numer_Rejestracyjny,
    Rok_Produkcji,
    liczba_wypozyczen,
    laczna_liczba_dni,
    srednia_liczba_dni,
    sredni_limit_przebiegu,
    pierwsze_wypozyczenie,
    ostatni_zwrot,

    RANK() OVER (
        PARTITION BY ID_Kategoria
        ORDER BY laczna_liczba_dni DESC
    )                                                               AS ranking_w_kategorii,

    -- NTILE: podzial pojazdow na 4 grupy (kwartyle) wg wykorzystania
    NTILE(4) OVER (
        PARTITION BY ID_Kategoria
        ORDER BY laczna_liczba_dni DESC
    )                                                               AS kwartyl_wykorzystania

FROM wykorzystanie_pojazdow
ORDER BY
    ID_Kategoria,
    ranking_w_kategorii;
