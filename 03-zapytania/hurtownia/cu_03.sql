-- CUBE 03
-- Pokazuje szacowany zysk w podziale na kategorie pojazdow, marki samochodow i pracownikow
-- Replicated for Star Schema DWH (h_72_)

SELECT
    NVL(kat.Nazwa_Kategorii, 'RAZEM KATEGORIA') AS kategoria_pojazdu,
    NVL(m.Nazwa_Marki, 'RAZEM MARKA') AS marka,
    NVL(TO_CHAR(d.ID_Pracownik_Wydania), ' ') AS id_pracownika,
    NVL(p.Nazwisko, 'RAZEM PRACOWNIK') AS pracownik,
    ROUND(d.wypracowany_zysk, 2) AS wypracowany_zysk
FROM (
    SELECT
        sam.ID_Kategoria,
        sam.ID_Marka,
        w.ID_Pracownik_Wydania,
        -- Szacowany zysk (15% z ceny za dobe)
        SUM(w.Cena_Doba * 0.15) AS wypracowany_zysk
    FROM h_72_Wypozyczenia w
    JOIN h_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    GROUP BY CUBE (sam.ID_Kategoria, sam.ID_Marka, w.ID_Pracownik_Wydania)
) d
LEFT JOIN (SELECT DISTINCT ID_Kategoria, Nazwa_Kategorii FROM h_72_Samochod) kat ON d.ID_Kategoria = kat.ID_Kategoria
LEFT JOIN (SELECT DISTINCT ID_Marka, Nazwa_Marki FROM h_72_Samochod) m ON d.ID_Marka = m.ID_Marka
LEFT JOIN h_72_Pracownik p ON d.ID_Pracownik_Wydania = p.ID_Pracownik
ORDER BY kategoria_pojazdu, marka, pracownik;
