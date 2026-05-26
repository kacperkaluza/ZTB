-- PARTYCJONOWANIE OBLICZENIOWE 03
-- Pokazuje wartosc sprzedazy pracownika na tle sredniej oddzialu w podziale na statusy wypozyczen

SELECT
    sa.Nazwa_Oddzialu AS nazwa_oddzialu,
    analiza.ID_Pracownik_Wydania AS id_pracownika,
    p.Nazwisko AS pracownik,
    analiza.STATUS_WYPOZYCZENIA AS status_wypozyczenia,
    analiza.wartosc_sprzedazy,
    analiza.srednia_w_oddziale,
    analiza.roznica
FROM (
    SELECT
        z.ID_Oddzial_Wydania,
        z.ID_Pracownik_Wydania,
        z.STATUS_WYPOZYCZENIA,
        z.wartosc_sprzedazy,
        ROUND(AVG(z.wartosc_sprzedazy) OVER (PARTITION BY z.ID_Oddzial_Wydania), 2) AS srednia_w_oddziale,
        ROUND(z.wartosc_sprzedazy - AVG(z.wartosc_sprzedazy) OVER (PARTITION BY z.ID_Oddzial_Wydania), 2) AS roznica
    FROM (
        SELECT
            w.ID_Oddzial_Wydania,
            w.ID_Pracownik_Wydania,
            w.STATUS_WYPOZYCZENIA,
            SUM(w.Cena_Doba) AS wartosc_sprzedazy
        FROM p_72_Wypozyczenia w
        GROUP BY w.ID_Oddzial_Wydania, w.ID_Pracownik_Wydania, w.STATUS_WYPOZYCZENIA
    ) z
) analiza
LEFT JOIN p_72_Oddzial sa ON analiza.ID_Oddzial_Wydania = sa.ID_Oddzial
LEFT JOIN p_72_Pracownik p ON analiza.ID_Pracownik_Wydania = p.ID_Pracownik
ORDER BY sa.Nazwa_Oddzialu, analiza.roznica DESC;
