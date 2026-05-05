-- =============================================================================
-- ok_02.sql — OKNA: Skumulowany dystans klienta w czasie
-- =============================================================================
-- Pytanie biznesowe:
--   Jaki jest narastajacy (skumulowany) dystans przejechany przez kazdego
--   klienta, porzadkowany chronologicznie wg daty wydania?
--   Dodatkowo wyswietlamy dystans z poprzedniego wypozyczenia (LAG)
--   i nastepnego (LEAD), co pozwala analizowac zmiany w nawykach klienta.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Klient
--   2) Wypozyczenia → Samochod → Model → Marka
--   3) Wypozyczenia → Ubezpieczenie → Typ_Ubezpieczenia
--
-- Miary: Przebieg_Start, Przebieg_Finish (dystans), Data_Wydania
-- =============================================================================

SELECT
    kl.Imie || ' ' || kl.Nazwisko                                   AS klient,
    kl.Kategoria_Prawa_Jazdy,
    mar.Nazwa_Marki,
    mod.Nazwa_Modelu,
    tu.Nazwa_Typu                                                   AS typ_ubezpieczenia,
    w.Data_Wydania,
    (w.Przebieg_Finish - w.Przebieg_Start)                          AS dystans_km,

    -- Skumulowany dystans klienta (od pierwszego do biezacego wypozyczenia)
    SUM(w.Przebieg_Finish - w.Przebieg_Start) OVER (
        PARTITION BY kl.ID_Klient
        ORDER BY w.Data_Wydania
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                               AS dystans_skumulowany_km,

    -- Dystans z poprzedniego wypozyczenia klienta
    LAG(w.Przebieg_Finish - w.Przebieg_Start, 1) OVER (
        PARTITION BY kl.ID_Klient
        ORDER BY w.Data_Wydania
    )                                                               AS dystans_poprzedni_km,

    -- Dystans z nastepnego wypozyczenia klienta
    LEAD(w.Przebieg_Finish - w.Przebieg_Start, 1) OVER (
        PARTITION BY kl.ID_Klient
        ORDER BY w.Data_Wydania
    )                                                               AS dystans_nastepny_km,

    -- Numer kolejny wypozyczenia klienta
    ROW_NUMBER() OVER (
        PARTITION BY kl.ID_Klient
        ORDER BY w.Data_Wydania
    )                                                               AS numer_wypozyczenia

FROM
    p_72_Wypozyczenia w
    JOIN p_72_Klient            kl  ON w.ID_Klient               = kl.ID_Klient
    JOIN p_72_Samochod          sam ON w.ID_Samochod              = sam.ID_Samochod
    JOIN p_72_Model             mod ON sam.ID_Model               = mod.ID_Model
    JOIN p_72_Marka             mar ON mod.ID_Marka               = mar.ID_Marka
    JOIN p_72_Ubezpieczenie     ub  ON w.ID_Ubezpieczenie         = ub.ID_Ubezpieczenie
    JOIN p_72_Typ_Ubezpieczenia tu  ON ub.ID_Typu_Ubezpieczenia   = tu.ID_Typu_Ubezpieczenia
WHERE
    w.Przebieg_Finish IS NOT NULL
    AND w.Przebieg_Start IS NOT NULL
ORDER BY
    klient,
    w.Data_Wydania
FETCH FIRST 500 ROWS ONLY;
