-- PARTYCJONOWANIE OBLICZENIOWE 02
-- Pokazuje udzial procentowy wkladu klienta w calkowitym przychodzie oddzialu

SELECT
    k.Imie || ' ' || k.Nazwisko AS klient,
    s.Nazwa_Oddzialu AS oddzial_wydania,
    analiza.wklad_klienta,
    analiza.razem,
    analiza.udzial_procentowy
FROM (
    SELECT
        z.ID_Klient,
        z.ID_Oddzial_Wydania,
        z.wklad_klienta,
        SUM(z.wklad_klienta) OVER () AS razem,
        ROUND(100 * z.wklad_klienta / SUM(z.wklad_klienta) OVER (), 2) AS udzial_procentowy
    FROM (
        SELECT
            w.ID_Klient,
            w.ID_Oddzial_Wydania,
            SUM(w.Cena_Doba) AS wklad_klienta
        FROM p_72_Wypozyczenia w
        GROUP BY w.ID_Klient, w.ID_Oddzial_Wydania
    ) z
) analiza
LEFT JOIN p_72_Klient k ON analiza.ID_Klient = k.ID_Klient
LEFT JOIN p_72_Oddzial s ON analiza.ID_Oddzial_Wydania = s.ID_Oddzial
ORDER BY analiza.udzial_procentowy DESC, klient, oddzial_wydania, wklad_klienta DESC;
