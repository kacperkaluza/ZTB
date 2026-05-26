-- ROLLUP 01
-- Pokazuje laczny przychod netto w podziale na wojewodztwa, marki i typy paliwa

SELECT
    NVL(woj.Nazwa_Wojewodztwa, 'RAZEM WOJEWODZTWO') AS wojewodztwo,
    NVL(m.Nazwa_Marki, 'RAZEM MARKA') AS marka,
    NVL(tp.Nazwa_Paliwa, 'RAZEM TYP PALIWA') AS typ_paliwa,
    ROUND(d.laczny_przychod_netto, 2) AS laczny_przychod_netto
FROM (
    SELECT
        mi.ID_Wojewodztwo,
        mod.ID_Marka,
        sam.ID_Typu_Paliwa,
        SUM(w.Cena_Doba) AS laczny_przychod_netto
    FROM p_72_Wypozyczenia w
    JOIN p_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    JOIN p_72_Model mod ON sam.ID_Model = mod.ID_Model
    JOIN p_72_Oddzial s ON w.ID_Oddzial_Wydania = s.ID_Oddzial
    JOIN p_72_Ulica u ON s.ID_Ulica = u.ID_Ulica
    JOIN p_72_Miasto mi ON u.ID_Miasta = mi.ID_Miasta
    GROUP BY ROLLUP (mi.ID_Wojewodztwo, mod.ID_Marka, sam.ID_Typu_Paliwa)
) d
LEFT JOIN p_72_Wojewodztwo woj ON d.ID_Wojewodztwo = woj.ID_Wojewodztwo
LEFT JOIN p_72_Marka m ON d.ID_Marka = m.ID_Marka
LEFT JOIN p_72_Typ_Paliwa tp ON d.ID_Typu_Paliwa = tp.ID_Typu_Paliwa
ORDER BY wojewodztwo, marka, typ_paliwa;
