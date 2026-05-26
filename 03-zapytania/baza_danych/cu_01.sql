-- CUBE 01
-- Pokazuje szacowany zysk w podziale na modele samochodow, miasta i typy paliwa

SELECT
    NVL(mod.Nazwa_Modelu, 'RAZEM MODEL') AS model,
    NVL(m.Nazwa_Miasta, 'RAZEM MIASTO') AS miasto,
    NVL(tp.Nazwa_Paliwa, 'RAZEM TYP PALIWA') AS typ_paliwa,
    ROUND(d.szacowany_zysk, 2) AS szacowany_zysk
FROM (
    SELECT
        sam.ID_Model,
        mi.ID_Miasta,
        sam.ID_Typu_Paliwa,
        -- Szacowany zysk jako 15% z ceny za dobe
        SUM(w.Cena_Doba * 0.15) AS szacowany_zysk
    FROM p_72_Wypozyczenia w
    JOIN p_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    JOIN p_72_Oddzial o ON w.ID_Oddzial_Wydania = o.ID_Oddzial
    JOIN p_72_Ulica u ON o.ID_Ulica = u.ID_Ulica
    JOIN p_72_Miasto mi ON u.ID_Miasta = mi.ID_Miasta
    GROUP BY CUBE (sam.ID_Model, mi.ID_Miasta, sam.ID_Typu_Paliwa)
) d
LEFT JOIN p_72_Model mod ON d.ID_Model = mod.ID_Model
LEFT JOIN p_72_Miasto m ON d.ID_Miasta = m.ID_Miasta
LEFT JOIN p_72_Typ_Paliwa tp ON d.ID_Typu_Paliwa = tp.ID_Typu_Paliwa
ORDER BY model, miasto, typ_paliwa;
