-- =============================================================================
-- po_03.sql — PARTYCJE OBLICZENIOWE: Rozklad kosztow transportu per oddzial
-- =============================================================================
-- Pytanie biznesowe:
--   Jaki procentowy udzial w lacznym koszcie transportu danego panstwa
--   ma kazdy oddzial? Jaka jest pozycja kazdego pracownika w generowaniu
--   kosztow transportu w ramach oddzialu?
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Oddzial (wydania) → Ulica → Miasto → Wojewodztwo → Panstwo
--   2) Wypozyczenia → Pracownik (wydania) → Stanowisko
--   3) Wypozyczenia → Samochod
--
-- Miary: Koszt_Transportu
-- =============================================================================

SELECT
    pa.ID_Panstwa,
    MIN(pa.Nazwa_Panstwa)                                           AS Nazwa_Panstwa,
    odd.ID_Oddzial,
    MIN(odd.Nazwa_Oddzialu)                                         AS Nazwa_Oddzialu,
    st.ID_Stanowisko,
    MIN(st.Nazwa_Stanowiska)                                        AS Nazwa_Stanowiska,
    pr.ID_Pracownik,
    MIN(pr.Imie || ' ' || pr.Nazwisko)                              AS pracownik,
    COUNT(*)                                                        AS liczba_transakcji,
    SUM(w.Koszt_Transportu)                                         AS koszt_transportu_pracownika,

    -- Laczny koszt transportu w oddziale
    SUM(SUM(w.Koszt_Transportu))
        OVER (PARTITION BY odd.ID_Oddzial)                           AS koszt_transportu_oddzialu,

    -- Laczny koszt transportu w panstwie
    SUM(SUM(w.Koszt_Transportu))
        OVER (PARTITION BY pa.ID_Panstwa)                            AS koszt_transportu_panstwa,

    -- Udzial pracownika w koszcie oddzialu [%]
    ROUND(
        SUM(w.Koszt_Transportu)
        / NULLIF(
            SUM(SUM(w.Koszt_Transportu)) OVER (PARTITION BY odd.ID_Oddzial),
            0
          ) * 100,
        2
    )                                                               AS udzial_w_oddziale_pct,

    -- Udzial oddzialu w koszcie panstwa [%]
    ROUND(
        SUM(SUM(w.Koszt_Transportu)) OVER (PARTITION BY odd.ID_Oddzial)
        / NULLIF(
            SUM(SUM(w.Koszt_Transportu)) OVER (PARTITION BY pa.ID_Panstwa),
            0
          ) * 100,
        2
    )                                                               AS udzial_oddzialu_w_panstwie_pct

FROM
    p_72_Wypozyczenia w
    JOIN p_72_Oddzial     odd ON w.ID_Oddzial_Wydania  = odd.ID_Oddzial
    JOIN p_72_Ulica       ul  ON odd.ID_Ulica           = ul.ID_Ulica
    JOIN p_72_Miasto      mia ON ul.ID_Miasta            = mia.ID_Miasta
    JOIN p_72_Wojewodztwo woj ON mia.ID_Wojewodztwo      = woj.ID_Wojewodztwo
    JOIN p_72_Panstwo     pa  ON woj.ID_Panstwa          = pa.ID_Panstwa
    JOIN p_72_Pracownik   pr  ON w.ID_Pracownik_Wydania  = pr.ID_Pracownik
    JOIN p_72_Stanowisko  st  ON pr.ID_Stanowisko         = st.ID_Stanowisko
    JOIN p_72_Samochod    sam ON w.ID_Samochod            = sam.ID_Samochod
WHERE
    w.Koszt_Transportu IS NOT NULL
    AND w.Koszt_Transportu > 0
GROUP BY
    pa.ID_Panstwa,
    odd.ID_Oddzial,
    st.ID_Stanowisko,
    pr.ID_Pracownik
ORDER BY
    pa.ID_Panstwa,
    odd.ID_Oddzial,
    koszt_transportu_pracownika DESC;
