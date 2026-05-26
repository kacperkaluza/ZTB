-- CUBE 03
-- Pokazuje szacowany zysk w podziale na kategorie pojazdow, marki samochodow i pracownikow

SELECT
    NVL(kat.Nazwa_Kategorii, 'RAZEM KATEGORIA') AS kategoria_pojazdu,
    NVL(m.Nazwa_Marki, 'RAZEM MARKA') AS marka,
    NVL(TO_CHAR(d.ID_Pracownik_Wydania), ' ') AS id_pracownika,
    NVL(p.Nazwisko, 'RAZEM PRACOWNIK') AS pracownik,
    ROUND(d.wypracowany_zysk, 2) AS wypracowany_zysk
FROM (
    SELECT
        sam.ID_Kategoria,
        mod.ID_Marka,
        w.ID_Pracownik_Wydania,
        -- Szacowany zysk (15% z ceny za dobe)
        SUM(w.Cena_Doba * 0.15) AS wypracowany_zysk
    FROM p_72_Wypozyczenia w
    JOIN p_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    JOIN p_72_Model mod ON sam.ID_Model = mod.ID_Model
    GROUP BY CUBE (sam.ID_Kategoria, mod.ID_Marka, w.ID_Pracownik_Wydania)
) d
LEFT JOIN p_72_Kategoria kat ON d.ID_Kategoria = kat.ID_Kategoria
LEFT JOIN p_72_Marka m ON d.ID_Marka = m.ID_Marka
LEFT JOIN p_72_Pracownik p ON d.ID_Pracownik_Wydania = p.ID_Pracownik
ORDER BY kategoria_pojazdu, marka, pracownik;
