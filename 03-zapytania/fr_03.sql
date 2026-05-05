-- =============================================================================
-- fr_03.sql — RANKING: Ranking pracownikow wg obslugi transakcji per stanowisko
-- =============================================================================
-- Pytanie biznesowe:
--   Ktorzy pracownicy obsluzyli najwiecej transakcji i wygenerowali najwyzsza
--   laczna wartosc kaucji w ramach swojego stanowiska?
--   DENSE_RANK() per stanowisko — do ocen okresowych i systemow premiowych.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Pracownik (wydania) → Stanowisko
--   2) Wypozyczenia → Pracownik (wydania) → Oddzial
--   3) Wypozyczenia → Oddzial → Ulica → Miasto → Wojewodztwo
--
-- Miary: COUNT (liczba transakcji), Kaucja, Cena_Doba
-- =============================================================================

WITH statystyki_pracownikow AS (
    SELECT
        pr.ID_Pracownik,
        st.ID_Stanowisko,
        MIN(st.Nazwa_Stanowiska)                                    AS Nazwa_Stanowiska,
        odd.ID_Oddzial,
        MIN(odd.Nazwa_Oddzialu)                                     AS Nazwa_Oddzialu,
        MIN(woj.Nazwa_Wojewodztwa)                                  AS Nazwa_Wojewodztwa,
        MIN(pr.Imie || ' ' || pr.Nazwisko)                          AS pracownik,
        MIN(pr.Data_Zatrudnienia)                                   AS Data_Zatrudnienia,
        MIN(st.Stawka_Godzinowa)                                    AS Stawka_Godzinowa,
        COUNT(*)                                                    AS liczba_transakcji,
        SUM(w.Kaucja)                                               AS laczna_kaucja,
        ROUND(AVG(w.Cena_Doba), 2)                                   AS srednia_stawka_obslugiwana,
        SUM(w.Cena_Doba)                                             AS suma_stawek,
        MIN(w.Data_Wydania)                                          AS pierwsza_transakcja,
        MAX(w.Data_Wydania)                                          AS ostatnia_transakcja
    FROM
        p_72_Wypozyczenia w
        JOIN p_72_Pracownik   pr  ON w.ID_Pracownik_Wydania = pr.ID_Pracownik
        JOIN p_72_Stanowisko  st  ON pr.ID_Stanowisko        = st.ID_Stanowisko
        JOIN p_72_Oddzial     odd ON pr.ID_Oddzial           = odd.ID_Oddzial
        JOIN p_72_Ulica       ul  ON odd.ID_Ulica             = ul.ID_Ulica
        JOIN p_72_Miasto      mia ON ul.ID_Miasta              = mia.ID_Miasta
        JOIN p_72_Wojewodztwo woj ON mia.ID_Wojewodztwo        = woj.ID_Wojewodztwo
    GROUP BY
        pr.ID_Pracownik,
        st.ID_Stanowisko,
        odd.ID_Oddzial
)
SELECT
    ID_Pracownik,
    ID_Stanowisko,
    Nazwa_Stanowiska,
    ID_Oddzial,
    Nazwa_Oddzialu,
    Nazwa_Wojewodztwa,
    pracownik,
    Data_Zatrudnienia,
    Stawka_Godzinowa,
    liczba_transakcji,
    laczna_kaucja,
    srednia_stawka_obslugiwana,
    suma_stawek,
    pierwsza_transakcja,
    ostatnia_transakcja,

    DENSE_RANK() OVER (
        PARTITION BY ID_Stanowisko
        ORDER BY liczba_transakcji DESC
    )                                                               AS ranking_transakcji,

    DENSE_RANK() OVER (
        PARTITION BY ID_Stanowisko
        ORDER BY laczna_kaucja DESC
    )                                                               AS ranking_kaucji,

    ROUND(
        PERCENT_RANK() OVER (
            PARTITION BY ID_Oddzial
            ORDER BY suma_stawek
        ) * 100,
        1
    )                                                               AS percentyl_w_oddziale

FROM statystyki_pracownikow
ORDER BY
    ID_Stanowisko,
    ranking_transakcji;
