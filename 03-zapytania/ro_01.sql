-- =============================================================================
-- ro_01.sql — ROLLUP: Przychody wg hierarchii geograficznej
-- =============================================================================
-- Pytanie biznesowe:
--   Jaki jest laczny przychod (suma stawek dziennych * dni, srednia kaucja)
--   z wypozyczen w podziale na hierarchie geograficzna oddzialu wydania:
--   Panstwo → Wojewodztwo → Miasto?
--   ROLLUP generuje podsumowania na kazdym poziomie hierarchii
--   (miasto, wojewodztwo, panstwo, ogolna suma).
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Oddzial (wydania) → Ulica → Miasto → Wojewodztwo → Panstwo
--   2) Wypozyczenia → Samochod → Kategoria
--
-- Miary: Cena_Doba, Kaucja, wyliczana liczba_dni i koszt_calkowity
-- =============================================================================

SELECT
    pa.ID_Panstwa,
    MIN(pa.Nazwa_Panstwa)                                           AS Nazwa_Panstwa,
    woj.ID_Wojewodztwo,
    MIN(woj.Nazwa_Wojewodztwa)                                      AS Nazwa_Wojewodztwa,
    mia.ID_Miasta,
    MIN(mia.Nazwa_Miasta)                                           AS Nazwa_Miasta,
    kat.ID_Kategoria,
    MIN(kat.Nazwa_Kategorii)                                        AS Nazwa_Kategorii,
    COUNT(*)                                                        AS liczba_wypozyczen,
    SUM(w.Cena_Doba * (w.Data_Faktycznego_Zwrotu - w.Data_Wydania))
                                                                    AS przychod_calkowity,
    ROUND(AVG(w.Cena_Doba), 2)                                      AS srednia_stawka_dzienna,
    ROUND(AVG(w.Kaucja), 2)                                         AS srednia_kaucja,
    SUM(w.Kaucja)                                                   AS suma_kaucji
FROM
    p_72_Wypozyczenia w
    -- Sciezka geograficzna: Oddzial wydania → Ulica → Miasto → Wojewodztwo → Panstwo
    JOIN p_72_Oddzial     odd ON w.ID_Oddzial_Wydania = odd.ID_Oddzial
    JOIN p_72_Ulica       ul  ON odd.ID_Ulica          = ul.ID_Ulica
    JOIN p_72_Miasto      mia ON ul.ID_Miasta           = mia.ID_Miasta
    JOIN p_72_Wojewodztwo woj ON mia.ID_Wojewodztwo     = woj.ID_Wojewodztwo
    JOIN p_72_Panstwo     pa  ON woj.ID_Panstwa         = pa.ID_Panstwa
    -- Sciezka pojazdu: Samochod → Kategoria
    JOIN p_72_Samochod    sam ON w.ID_Samochod           = sam.ID_Samochod
    JOIN p_72_Kategoria   kat ON sam.ID_Kategoria         = kat.ID_Kategoria
WHERE
    w.Data_Faktycznego_Zwrotu IS NOT NULL
GROUP BY
    ROLLUP(pa.ID_Panstwa, woj.ID_Wojewodztwo, mia.ID_Miasta, kat.ID_Kategoria)
ORDER BY
    pa.ID_Panstwa       NULLS LAST,
    woj.ID_Wojewodztwo  NULLS LAST,
    mia.ID_Miasta       NULLS LAST,
    kat.ID_Kategoria    NULLS LAST;
