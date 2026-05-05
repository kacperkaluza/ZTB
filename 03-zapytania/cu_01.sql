-- =============================================================================
-- cu_01.sql — CUBE: Wielowymiarowa analiza: Kategoria × Typ_Paliwa × Województwo
-- =============================================================================
-- Pytanie biznesowe:
--   Jaka jest laczna wartosc wypozyczen, sredni limit przebiegu i srednia
--   stawka dzienna w kazdej kombinacji: kategorii pojazdu, typu paliwa
--   i wojewodztwa oddzialu wydania?
--   CUBE tworzy podsumowania dla WSZYSTKICH mozliwych kombinacji wymiarow.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Samochod → Kategoria
--   2) Wypozyczenia → Samochod → Typ_Paliwa
--   3) Wypozyczenia → Oddzial (wydania) → Ulica → Miasto → Wojewodztwo
--
-- Miary: Cena_Doba, Kaucja, Przebieg_Limit
-- =============================================================================
-- TODO: zobaczyc pdfa z wykladu
SELECT
    kat.ID_Kategoria,
    MIN(kat.Nazwa_Kategorii)                                        AS Nazwa_Kategorii,
    tp.ID_Typu_Paliwa,
    MIN(tp.Nazwa_Paliwa)                                            AS Nazwa_Paliwa,
    woj.ID_Wojewodztwo,
    MIN(woj.Nazwa_Wojewodztwa)                                      AS Nazwa_Wojewodztwa,
    COUNT(*)                                                        AS liczba_wypozyczen,
    SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania))
                                                                    AS przychod_calkowity,
    ROUND(AVG(w.Cena_Doba), 2)                                      AS srednia_stawka_dzienna,
    ROUND(AVG(w.Przebieg_Limit), 0)                                  AS sredni_limit_przebiegu,
    SUM(w.Kaucja)                                                    AS suma_kaucji,
    ROUND(AVG(w.Kaucja), 2)                                          AS srednia_kaucja
FROM
    p_72_Wypozyczenia w
    JOIN p_72_Samochod    sam ON w.ID_Samochod          = sam.ID_Samochod
    JOIN p_72_Kategoria   kat ON sam.ID_Kategoria        = kat.ID_Kategoria
    JOIN p_72_Typ_Paliwa  tp  ON sam.ID_Typu_Paliwa      = tp.ID_Typu_Paliwa
    JOIN p_72_Oddzial     odd ON w.ID_Oddzial_Wydania    = odd.ID_Oddzial
    JOIN p_72_Ulica       ul  ON odd.ID_Ulica             = ul.ID_Ulica
    JOIN p_72_Miasto      mia ON ul.ID_Miasta              = mia.ID_Miasta
    JOIN p_72_Wojewodztwo woj ON mia.ID_Wojewodztwo        = woj.ID_Wojewodztwo
WHERE
    w.Data_Faktycznego_Zwrotu IS NOT NULL
GROUP BY
    CUBE(kat.ID_Kategoria, tp.ID_Typu_Paliwa, woj.ID_Wojewodztwo)
ORDER BY
    kat.ID_Kategoria    NULLS LAST,
    tp.ID_Typu_Paliwa   NULLS LAST,
    woj.ID_Wojewodztwo  NULLS LAST;
