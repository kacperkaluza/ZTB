-- RANKINGI 01
-- Pokazuje TOP 3 najwieksze kombinacje oddzialu, pracownika i statusu pod wzgledem przychodu

SELECT
    r.ranking,
    s.Nazwa_Oddzialu AS nazwa_oddzialu,
    p.Nazwisko AS pracownik,
    r.STATUS_WYPOZYCZENIA AS status_wypozyczenia,
    r.calkowita_sprzedaz
FROM (
    SELECT
        RANK() OVER (ORDER BY z.kwota DESC) AS ranking,
        z.ID_Oddzial_Wydania,
        z.ID_Pracownik_Wydania,
        z.STATUS_WYPOZYCZENIA,
        z.kwota AS calkowita_sprzedaz
    FROM (
        SELECT
            w.ID_Oddzial_Wydania,
            w.ID_Pracownik_Wydania,
            w.STATUS_WYPOZYCZENIA,
            SUM(w.Cena_Doba) AS kwota
        FROM p_72_Wypozyczenia w
        GROUP BY w.ID_Oddzial_Wydania, w.ID_Pracownik_Wydania, w.STATUS_WYPOZYCZENIA
    ) z
) r
LEFT JOIN p_72_Oddzial s ON r.ID_Oddzial_Wydania = s.ID_Oddzial
LEFT JOIN p_72_Pracownik p ON r.ID_Pracownik_Wydania = p.ID_Pracownik
WHERE r.ranking <= 3
ORDER BY r.ranking;
