-- ROLLUP 01
-- Pokazuje laczny przychod netto w podziale na wojewodztwa, marki i typy paliwa
-- Replicated for Star Schema DWH (h_72_)

SELECT
    NVL(woj.Nazwa_Wojewodztwa, 'RAZEM WOJEWODZTWO') AS wojewodztwo,
    NVL(m.Nazwa_Marki, 'RAZEM MARKA') AS marka,
    NVL(tp.Nazwa_Paliwa, 'RAZEM TYP PALIWA') AS typ_paliwa,
    ROUND(d.laczny_przychod_netto, 2) AS laczny_przychod_netto
FROM (
    SELECT
        o.ID_Wojewodztwo,
        sam.ID_Marka,
        sam.ID_Typu_Paliwa,
        SUM(w.Cena_Doba) AS laczny_przychod_netto
    FROM h_72_Wypozyczenia w
    JOIN h_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    JOIN h_72_Oddzial o ON w.ID_Oddzial_Wydania = o.ID_Oddzial
    GROUP BY ROLLUP (o.ID_Wojewodztwo, sam.ID_Marka, sam.ID_Typu_Paliwa)
) d
LEFT JOIN (SELECT DISTINCT ID_Wojewodztwo, Nazwa_Wojewodztwa FROM h_72_Oddzial) woj ON d.ID_Wojewodztwo = woj.ID_Wojewodztwo
LEFT JOIN (SELECT DISTINCT ID_Marka, Nazwa_Marki FROM h_72_Samochod) m ON d.ID_Marka = m.ID_Marka
LEFT JOIN (SELECT DISTINCT ID_Typu_Paliwa, Nazwa_Paliwa FROM h_72_Samochod) tp ON d.ID_Typu_Paliwa = tp.ID_Typu_Paliwa
ORDER BY wojewodztwo, marka, typ_paliwa, laczny_przychod_netto DESC;
