-- CUBE 01
-- Pokazuje szacowany zysk w podziale na modele samochodow, miasta i typy paliwa
-- Replicated for Star Schema DWH (h_72_)

SELECT
    NVL(mod.Nazwa_Modelu, 'RAZEM MODEL') AS model,
    NVL(m.Nazwa_Miasta, 'RAZEM MIASTO') AS miasto,
    NVL(tp.Nazwa_Paliwa, 'RAZEM TYP PALIWA') AS typ_paliwa,
    ROUND(d.szacowany_zysk, 2) AS szacowany_zysk
FROM (
    SELECT
        sam.ID_Model,
        o.ID_Miasta,
        sam.ID_Typu_Paliwa,
        -- Szacowany zysk jako 15% z ceny za dobe
        SUM(w.Cena_Doba * 0.15) AS szacowany_zysk
    FROM h_72_Wypozyczenia w
    JOIN h_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    JOIN h_72_Oddzial o ON w.ID_Oddzial_Wydania = o.ID_Oddzial
    GROUP BY CUBE (sam.ID_Model, o.ID_Miasta, sam.ID_Typu_Paliwa)
) d
LEFT JOIN (SELECT DISTINCT ID_Model, Nazwa_Modelu FROM h_72_Samochod) mod ON d.ID_Model = mod.ID_Model
LEFT JOIN (SELECT DISTINCT ID_Miasta, Nazwa_Miasta FROM h_72_Oddzial) m ON d.ID_Miasta = m.ID_Miasta
LEFT JOIN (SELECT DISTINCT ID_Typu_Paliwa, Nazwa_Paliwa FROM h_72_Samochod) tp ON d.ID_Typu_Paliwa = tp.ID_Typu_Paliwa
ORDER BY model, miasto, typ_paliwa;
