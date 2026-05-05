-- =============================================================================
-- ok_03.sql — OKNA: Zmiana sredniej stawki dziennej m/m wg kategorii
-- =============================================================================
-- Pytanie biznesowe:
--   Jak zmienia sie srednia stawka dzienna (Cena_Doba) z miesiaca na miesiac
--   dla kazdej kategorii pojazdu? LAG + zmiana procentowa.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Samochod → Kategoria
--   2) Wypozyczenia → Ubezpieczenie → Typ_Ubezpieczenia
--   3) Wypozyczenia → Oddzial (wydania) → Ulica → Miasto → Wojewodztwo → Panstwo
--
-- Miary: Cena_Doba, Data_Wydania (wymiar czasowy)
-- =============================================================================

WITH miesieczne_stawki AS (
    SELECT
        kat.ID_Kategoria,
        MIN(kat.Nazwa_Kategorii)                                    AS Nazwa_Kategorii,
        pa.ID_Panstwa,
        MIN(pa.Nazwa_Panstwa)                                       AS Nazwa_Panstwa,
        EXTRACT(YEAR FROM w.Data_Wydania)                           AS rok,
        EXTRACT(MONTH FROM w.Data_Wydania)                          AS miesiac,
        COUNT(*)                                                    AS liczba_wypozyczen,
        ROUND(AVG(w.Cena_Doba), 2)                                  AS srednia_stawka,
        SUM(w.Cena_Doba)                                            AS suma_stawek
    FROM
        p_72_Wypozyczenia w
        JOIN p_72_Samochod         sam ON w.ID_Samochod            = sam.ID_Samochod
        JOIN p_72_Kategoria        kat ON sam.ID_Kategoria          = kat.ID_Kategoria
        JOIN p_72_Ubezpieczenie    ub  ON w.ID_Ubezpieczenie        = ub.ID_Ubezpieczenie
        JOIN p_72_Typ_Ubezpieczenia tu ON ub.ID_Typu_Ubezpieczenia = tu.ID_Typu_Ubezpieczenia
        JOIN p_72_Oddzial          odd ON w.ID_Oddzial_Wydania      = odd.ID_Oddzial
        JOIN p_72_Ulica            ul  ON odd.ID_Ulica               = ul.ID_Ulica
        JOIN p_72_Miasto           mia ON ul.ID_Miasta                = mia.ID_Miasta
        JOIN p_72_Wojewodztwo      woj ON mia.ID_Wojewodztwo          = woj.ID_Wojewodztwo
        JOIN p_72_Panstwo          pa  ON woj.ID_Panstwa              = pa.ID_Panstwa
    WHERE
        w.Data_Wydania IS NOT NULL
    GROUP BY
        kat.ID_Kategoria,
        pa.ID_Panstwa,
        EXTRACT(YEAR FROM w.Data_Wydania),
        EXTRACT(MONTH FROM w.Data_Wydania)
)
SELECT
    ID_Kategoria,
    Nazwa_Kategorii,
    ID_Panstwa,
    Nazwa_Panstwa,
    rok,
    miesiac,
    liczba_wypozyczen,
    srednia_stawka,
    suma_stawek,

    -- Srednia stawka z poprzedniego miesiaca
    LAG(srednia_stawka, 1) OVER (
        PARTITION BY ID_Kategoria, ID_Panstwa
        ORDER BY rok, miesiac
    )                                                               AS stawka_poprzedni_miesiac,

    -- Roznica bezwzgledna: biezacy - poprzedni
    ROUND(
        srednia_stawka - LAG(srednia_stawka, 1) OVER (
            PARTITION BY ID_Kategoria, ID_Panstwa
            ORDER BY rok, miesiac
        ),
        2
    )                                                               AS zmiana_bezwzgledna,

    -- Zmiana procentowa m/m
    ROUND(
        (srednia_stawka - LAG(srednia_stawka, 1) OVER (
            PARTITION BY ID_Kategoria, ID_Panstwa
            ORDER BY rok, miesiac
        ))
        / NULLIF(LAG(srednia_stawka, 1) OVER (
            PARTITION BY ID_Kategoria, ID_Panstwa
            ORDER BY rok, miesiac
        ), 0) * 100,
        2
    )                                                               AS zmiana_procentowa_m_m,

    MIN(srednia_stawka) OVER (
        PARTITION BY ID_Kategoria, ID_Panstwa
    )                                                               AS min_stawka_historyczna,

    MAX(srednia_stawka) OVER (
        PARTITION BY ID_Kategoria, ID_Panstwa
    )                                                               AS max_stawka_historyczna

FROM miesieczne_stawki
ORDER BY
    ID_Kategoria,
    ID_Panstwa,
    rok,
    miesiac;
