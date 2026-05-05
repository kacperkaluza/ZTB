-- =============================================================================
-- po_02.sql — PARTYCJE OBLICZENIOWE: Srednia kaucja i rabat w kategorii
-- =============================================================================
-- Pytanie biznesowe:
--   Jak wypada kaucja i rabat procentowy kazdego wypozyczenia na tle sredniej
--   w danej kategorii pojazdu i typie paliwa?
--   Uzywamy partycji obliczeniowej AVG OVER (PARTITION BY ID ...)
--   do porownania kazdego rekordu z jego grupa.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Samochod → Kategoria
--   2) Wypozyczenia → Samochod → Typ_Paliwa
--   3) Wypozyczenia → Klient
--
-- Miary: Kaucja, Cena_Rabat_Procent, Cena_Doba
-- =============================================================================

SELECT
    sam.ID_Kategoria,
    kat.Nazwa_Kategorii,
    sam.ID_Typu_Paliwa,
    tp.Nazwa_Paliwa,
    kl.Imie || ' ' || kl.Nazwisko                                  AS klient,
    w.Cena_Doba,
    w.Kaucja,
    w.Cena_Rabat_Procent,

    -- Srednia kaucja w danej kategorii (partycja po ID)
    ROUND(
        AVG(w.Kaucja) OVER (PARTITION BY sam.ID_Kategoria),
        2
    )                                                               AS srednia_kaucja_w_kategorii,

    -- Odchylenie kaucji od sredniej w kategorii
    ROUND(
        w.Kaucja - AVG(w.Kaucja) OVER (PARTITION BY sam.ID_Kategoria),
        2
    )                                                               AS odchylenie_kaucji,

    -- Sredni rabat w danym typie paliwa (partycja po ID)
    ROUND(
        AVG(w.Cena_Rabat_Procent) OVER (PARTITION BY sam.ID_Typu_Paliwa),
        2
    )                                                               AS sredni_rabat_wg_paliwa,

    -- Srednia stawka dzienna w danej kategorii i typie paliwa
    ROUND(
        AVG(w.Cena_Doba) OVER (PARTITION BY sam.ID_Kategoria, sam.ID_Typu_Paliwa),
        2
    )                                                               AS srednia_cena_doba_kat_paliwo

FROM
    p_72_Wypozyczenia w
    JOIN p_72_Samochod    sam ON w.ID_Samochod      = sam.ID_Samochod
    JOIN p_72_Kategoria   kat ON sam.ID_Kategoria    = kat.ID_Kategoria
    JOIN p_72_Typ_Paliwa  tp  ON sam.ID_Typu_Paliwa  = tp.ID_Typu_Paliwa
    JOIN p_72_Klient      kl  ON w.ID_Klient         = kl.ID_Klient
ORDER BY
    sam.ID_Kategoria,
    sam.ID_Typu_Paliwa,
    w.Kaucja DESC
FETCH FIRST 500 ROWS ONLY;
