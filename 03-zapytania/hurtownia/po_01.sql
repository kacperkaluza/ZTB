-- PARTYCJONOWANIE OBLICZENIOWE 01
-- Pokazuje przychod ze sprzedazy modeli w odniesieniu do sredniej sprzedazy w danym oddziale
-- Replicated for Star Schema DWH (h_72_)

SELECT
    mo.Nazwa_Modelu AS nazwa_modelu,
    sa.Nazwa_Oddzialu AS nazwa_oddzialu,
    analiza.id_pracownika,
    p.Nazwisko AS pracownik,
    analiza.wartosc_sprzedazy,
    analiza.srednia_w_oddziale,
    analiza.roznica
FROM (
    SELECT
        z.ID_Model,
        z.ID_Oddzial_Wydania,
        z.id_pracownika,
        z.wartosc_sprzedazy,
        ROUND(AVG(z.wartosc_sprzedazy) OVER (PARTITION BY z.ID_Oddzial_Wydania), 2) AS srednia_w_oddziale,
        ROUND(z.wartosc_sprzedazy - AVG(z.wartosc_sprzedazy) OVER (PARTITION BY z.ID_Oddzial_Wydania), 2) AS roznica
    FROM (
        SELECT
            sam.ID_Model,
            w.ID_Oddzial_Wydania,
            w.ID_Pracownik_Wydania AS id_pracownika,
            SUM(w.Cena_Doba) AS wartosc_sprzedazy
        FROM h_72_Wypozyczenia w
        JOIN h_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
        GROUP BY sam.ID_Model, w.ID_Oddzial_Wydania, w.ID_Pracownik_Wydania
    ) z
) analiza
LEFT JOIN (SELECT DISTINCT ID_Model, Nazwa_Modelu FROM h_72_Samochod) mo ON analiza.ID_Model = mo.ID_Model
LEFT JOIN h_72_Oddzial sa ON analiza.ID_Oddzial_Wydania = sa.ID_Oddzial
LEFT JOIN h_72_Pracownik p ON analiza.id_pracownika = p.ID_Pracownik
ORDER BY sa.Nazwa_Oddzialu, analiza.roznica DESC;
