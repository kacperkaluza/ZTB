-- =============================================================================
-- ok_01.sql — OKNA: 3-miesieczna srednia kroczaca przychodu wg marki
-- =============================================================================
-- Pytanie biznesowe:
--   Jaka jest 3-miesieczna srednia kroczaca lacznego przychodu
--   dla kazdej marki samochodu?
--   Okno ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING wygladza wahania miesieczne.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Samochod → Model → Marka
--   2) Wypozyczenia → Samochod → Kategoria
--   3) Wypozyczenia → Oddzial (wydania)
--
-- Miary: Cena_Doba, wyliczany przychod, Data_Wydania (wymiar czasowy)
-- =============================================================================

WITH miesieczny_przychod AS (
    SELECT
        mar.ID_Marka,
        MIN(mar.Nazwa_Marki)                                        AS Nazwa_Marki,
        EXTRACT(YEAR FROM w.Data_Wydania)                           AS rok,
        EXTRACT(MONTH FROM w.Data_Wydania)                          AS miesiac,
        COUNT(*)                                                    AS liczba_wypozyczen,
        SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania))
                                                                    AS przychod_miesieczny,
        ROUND(AVG(w.Cena_Doba), 2)                                  AS srednia_stawka
    FROM
        p_72_Wypozyczenia w
        JOIN p_72_Samochod  sam ON w.ID_Samochod        = sam.ID_Samochod
        JOIN p_72_Model     mod ON sam.ID_Model          = mod.ID_Model
        JOIN p_72_Marka     mar ON mod.ID_Marka          = mar.ID_Marka
        JOIN p_72_Kategoria kat ON sam.ID_Kategoria       = kat.ID_Kategoria
        JOIN p_72_Oddzial   odd ON w.ID_Oddzial_Wydania   = odd.ID_Oddzial
    WHERE
        w.Data_Faktycznego_Zwrotu IS NOT NULL
        AND w.Data_Wydania IS NOT NULL
    GROUP BY
        mar.ID_Marka,
        EXTRACT(YEAR FROM w.Data_Wydania),
        EXTRACT(MONTH FROM w.Data_Wydania)
)
SELECT
    ID_Marka,
    Nazwa_Marki,
    rok,
    miesiac,
    liczba_wypozyczen,
    przychod_miesieczny,
    srednia_stawka,

    -- Srednia kroczaca 3-miesieczna
    ROUND(
        AVG(przychod_miesieczny) OVER (
            PARTITION BY ID_Marka
            ORDER BY rok, miesiac
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ),
        2
    )                                                               AS srednia_kroczaca_3m,

    -- Suma narastajaca w ramach marki
    SUM(przychod_miesieczny) OVER (
        PARTITION BY ID_Marka
        ORDER BY rok, miesiac
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                               AS przychod_narastajaco

FROM miesieczny_przychod
ORDER BY
    ID_Marka,
    rok,
    miesiac;
