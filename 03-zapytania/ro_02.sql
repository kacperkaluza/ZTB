-- =============================================================================
-- ro_02.sql — ROLLUP: Analiza przebiegu i rabatow wg hierarchii pojazdu
-- =============================================================================
-- Pytanie biznesowe:
--   Jaki jest sredni dystans przejechany i sredni rabat procentowy
--   w podziale na hierarchie pojazdu: Marka → Model?
--   Dodatkowo uwzgledniamy typ paliwa.
--   ROLLUP generuje podsumowania: model, marka, ogolnie.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Samochod → Model → Marka
--   2) Wypozyczenia → Samochod → Typ_Paliwa
--   3) Wypozyczenia → Klient
--
-- Miary: Przebieg_Start, Przebieg_Finish (wyliczany dystans), Cena_Rabat_Procent
-- =============================================================================

SELECT
    mar.ID_Marka,
    MIN(mar.Nazwa_Marki)                                            AS Nazwa_Marki,
    mod.ID_Model,
    MIN(mod.Nazwa_Modelu)                                           AS Nazwa_Modelu,
    tp.ID_Typu_Paliwa,
    MIN(tp.Nazwa_Paliwa)                                            AS Nazwa_Paliwa,
    COUNT(*)                                                        AS liczba_wypozyczen,
    SUM(w.Przebieg_Finish - w.Przebieg_Start)                       AS calkowity_dystans_km,
    ROUND(AVG(w.Przebieg_Finish - w.Przebieg_Start), 1)             AS sredni_dystans_km,
    ROUND(AVG(w.Cena_Rabat_Procent), 2)                             AS sredni_rabat_procent,
    COUNT(DISTINCT w.ID_Klient)                                     AS unikalni_klienci
FROM
    p_72_Wypozyczenia w
    -- Sciezka pojazdu: Samochod → Model → Marka
    JOIN p_72_Samochod   sam ON w.ID_Samochod      = sam.ID_Samochod
    JOIN p_72_Model      mod ON sam.ID_Model        = mod.ID_Model
    JOIN p_72_Marka      mar ON mod.ID_Marka        = mar.ID_Marka
    -- Sciezka paliwa
    JOIN p_72_Typ_Paliwa tp  ON sam.ID_Typu_Paliwa  = tp.ID_Typu_Paliwa
    -- Sciezka klienta
    JOIN p_72_Klient     kl  ON w.ID_Klient         = kl.ID_Klient
WHERE
    w.Przebieg_Finish IS NOT NULL
    AND w.Przebieg_Start IS NOT NULL
GROUP BY
    ROLLUP(mar.ID_Marka, mod.ID_Model, tp.ID_Typu_Paliwa)
ORDER BY
    mar.ID_Marka      NULLS LAST,
    mod.ID_Model      NULLS LAST,
    tp.ID_Typu_Paliwa NULLS LAST;
