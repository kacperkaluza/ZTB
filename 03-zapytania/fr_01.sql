-- =============================================================================
-- fr_01.sql — RANKING: Top klienci wg lacznych wydatkow per wojewodztwo
-- =============================================================================
-- Pytanie biznesowe:
--   Ktorzy klienci wydali najwiecej na wypozyczenia w kazdym wojewodztwie?
--   DENSE_RANK() pozwala wyodrebnic top klientow per region.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Klient
--   2) Wypozyczenia → Oddzial (wydania) → Ulica → Miasto → Wojewodztwo
--   3) Wypozyczenia → Samochod → Kategoria
--
-- Miary: Cena_Doba, Kaucja, Cena_Rabat_Procent, Data_Faktycznego_Zwrotu
-- =============================================================================

WITH wydatki_klientow AS (
    SELECT
        woj.ID_Wojewodztwo,
        MIN(woj.Nazwa_Wojewodztwa)                                  AS Nazwa_Wojewodztwa,
        kl.ID_Klient,
        MIN(kl.Imie || ' ' || kl.Nazwisko)                         AS klient,
        MIN(kl.Kategoria_Prawa_Jazdy)                               AS Kategoria_Prawa_Jazdy,
        COUNT(*)                                                    AS liczba_wypozyczen,
        SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania))
                                                                    AS laczny_koszt,
        SUM(w.Kaucja)                                               AS laczna_kaucja,
        ROUND(AVG(w.Cena_Rabat_Procent), 2)                         AS sredni_rabat_procent,
        ROUND(AVG(w.Cena_Doba), 2)                                   AS srednia_stawka_dzienna,
        MIN(w.Data_Wydania)                                          AS pierwsza_wizyta,
        MAX(w.Data_Wydania)                                          AS ostatnia_wizyta
    FROM
        p_72_Wypozyczenia w
        JOIN p_72_Klient      kl  ON w.ID_Klient           = kl.ID_Klient
        JOIN p_72_Oddzial     odd ON w.ID_Oddzial_Wydania   = odd.ID_Oddzial
        JOIN p_72_Ulica       ul  ON odd.ID_Ulica            = ul.ID_Ulica
        JOIN p_72_Miasto      mia ON ul.ID_Miasta             = mia.ID_Miasta
        JOIN p_72_Wojewodztwo woj ON mia.ID_Wojewodztwo       = woj.ID_Wojewodztwo
        JOIN p_72_Samochod    sam ON w.ID_Samochod            = sam.ID_Samochod
        JOIN p_72_Kategoria   kat ON sam.ID_Kategoria          = kat.ID_Kategoria
    WHERE
        w.Data_Faktycznego_Zwrotu IS NOT NULL
    GROUP BY
        woj.ID_Wojewodztwo,
        kl.ID_Klient
)
SELECT
    ID_Wojewodztwo,
    Nazwa_Wojewodztwa,
    ID_Klient,
    klient,
    Kategoria_Prawa_Jazdy,
    liczba_wypozyczen,
    laczny_koszt,
    laczna_kaucja,
    sredni_rabat_procent,
    srednia_stawka_dzienna,
    pierwsza_wizyta,
    ostatnia_wizyta,

    DENSE_RANK() OVER (
        PARTITION BY ID_Wojewodztwo
        ORDER BY laczny_koszt DESC
    )                                                               AS ranking_w_wojewodztwie

FROM wydatki_klientow
ORDER BY
    ID_Wojewodztwo,
    ranking_w_wojewodztwie
FETCH FIRST 200 ROWS ONLY;
