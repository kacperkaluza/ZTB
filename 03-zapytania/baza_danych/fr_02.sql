-- RANKINGI 02
-- Pokazuje pelny ranking pracownikow pod wzgledem lacznego przychodu z wypozyczen

SELECT
    r.lp AS pozycja_rankingu,
    p.Nazwisko AS pracownik,
    st.Nazwa_Stanowiska AS stanowisko,
    s.Nazwa_Oddzialu AS oddzial_wydania,
    r.STATUS_WYPOZYCZENIA AS status_wypozyczenia,
    r.kwota AS laczny_przychod
FROM (
    SELECT
        RANK() OVER (ORDER BY z.kwota DESC) AS lp,
        z.ID_Pracownik_Wydania,
        z.ID_Oddzial_Wydania,
        z.STATUS_WYPOZYCZENIA,
        z.kwota
    FROM (
        SELECT
            w.ID_Pracownik_Wydania,
            w.ID_Oddzial_Wydania,
            w.STATUS_WYPOZYCZENIA,
            SUM(w.Cena_Doba) AS kwota
        FROM p_72_Wypozyczenia w
        GROUP BY w.ID_Pracownik_Wydania, w.ID_Oddzial_Wydania, w.STATUS_WYPOZYCZENIA
    ) z
) r
LEFT JOIN p_72_Pracownik p ON r.ID_Pracownik_Wydania = p.ID_Pracownik
LEFT JOIN p_72_Stanowisko st ON p.ID_Stanowisko = st.ID_Stanowisko
LEFT JOIN p_72_Oddzial s ON r.ID_Oddzial_Wydania = s.ID_Oddzial
ORDER BY r.lp, pracownik, oddzial_wydania, status_wypozyczenia, laczny_przychod DESC;
