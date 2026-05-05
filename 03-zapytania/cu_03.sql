-- =============================================================================
-- cu_03.sql — CUBE: Wielowymiarowa analiza: Stanowisko × Oddzial × Typ_Skrzyni
-- =============================================================================
-- Pytanie biznesowe:
--   Jaka jest srednia stawka dzienna i sredni dystans przejechany
--   w kazdej kombinacji: stanowiska pracownika, oddzialu wydania
--   i typu skrzyni biegow pojazdu?
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Pracownik (wydania) → Stanowisko
--   2) Wypozyczenia → Oddzial (wydania)
--   3) Wypozyczenia → Samochod → Typ_Skrzyni
--
-- Miary: Cena_Doba, Przebieg_Start, Przebieg_Finish (wyliczany dystans)
-- =============================================================================

SELECT
    st.ID_Stanowisko,
    MIN(st.Nazwa_Stanowiska)                                        AS Nazwa_Stanowiska,
    odd.ID_Oddzial,
    MIN(odd.Nazwa_Oddzialu)                                         AS Nazwa_Oddzialu,
    ts.ID_Typu_Skrzyni,
    MIN(ts.Nazwa_Skrzyni)                                           AS Nazwa_Skrzyni,
    COUNT(*)                                                        AS liczba_wypozyczen,
    ROUND(AVG(w.Cena_Doba), 2)                                      AS srednia_stawka_dzienna,
    SUM(w.Cena_Doba)                                                AS suma_stawek,
    SUM(w.Przebieg_Finish - w.Przebieg_Start)                       AS calkowity_dystans_km,
    ROUND(AVG(w.Przebieg_Finish - w.Przebieg_Start), 1)             AS sredni_dystans_km,
    ROUND(AVG(st.Stawka_Godzinowa), 2)                               AS srednia_stawka_godzinowa_prac
FROM
    p_72_Wypozyczenia w
    JOIN p_72_Pracownik  pr  ON w.ID_Pracownik_Wydania = pr.ID_Pracownik
    JOIN p_72_Stanowisko st  ON pr.ID_Stanowisko        = st.ID_Stanowisko
    JOIN p_72_Oddzial    odd ON w.ID_Oddzial_Wydania    = odd.ID_Oddzial
    JOIN p_72_Samochod   sam ON w.ID_Samochod            = sam.ID_Samochod
    JOIN p_72_Typ_Skrzyni ts ON sam.ID_Typu_Skrzyni      = ts.ID_Typu_Skrzyni
WHERE
    w.Przebieg_Finish IS NOT NULL
    AND w.Przebieg_Start IS NOT NULL
GROUP BY
    CUBE(st.ID_Stanowisko, odd.ID_Oddzial, ts.ID_Typu_Skrzyni)
ORDER BY
    st.ID_Stanowisko   NULLS LAST,
    odd.ID_Oddzial     NULLS LAST,
    ts.ID_Typu_Skrzyni NULLS LAST;
