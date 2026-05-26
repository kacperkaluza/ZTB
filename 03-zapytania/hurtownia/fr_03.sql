-- RANKINGI 03
-- Pokazuje ranking popularnosci typow paliw wg liczby wypozyczen w ramach oddzialu i statusu
-- Replicated for Star Schema DWH (h_72_)

SELECT
    d.ranga AS pozycja_popularnosci, 
    s.Nazwa_Oddzialu AS oddzial_wydania,
    d.STATUS_WYPOZYCZENIA AS status_wypozyczenia,
    pal.Nazwa_Paliwa AS typ_paliwa,
    d.wolumen AS liczba_wypozyczen
FROM (
    SELECT
        RANK() OVER (PARTITION BY z.ID_Oddzial_Wydania, z.STATUS_WYPOZYCZENIA ORDER BY z.wolumen DESC) AS ranga,
        z.ID_Oddzial_Wydania,
        z.STATUS_WYPOZYCZENIA,
        z.ID_Typu_Paliwa,
        z.wolumen
    FROM (
        SELECT
            w.ID_Oddzial_Wydania,
            w.STATUS_WYPOZYCZENIA,
            sam.ID_Typu_Paliwa,
            COUNT(*) AS wolumen
        FROM h_72_Wypozyczenia w
        JOIN h_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
        GROUP BY w.ID_Oddzial_Wydania, w.STATUS_WYPOZYCZENIA, sam.ID_Typu_Paliwa
    ) z
) d
LEFT JOIN h_72_Oddzial s ON d.ID_Oddzial_Wydania = s.ID_Oddzial
LEFT JOIN (SELECT DISTINCT ID_Typu_Paliwa, Nazwa_Paliwa FROM h_72_Samochod) pal ON d.ID_Typu_Paliwa = pal.ID_Typu_Paliwa
ORDER BY d.ID_Oddzial_Wydania, d.STATUS_WYPOZYCZENIA, d.ranga, typ_paliwa, liczba_wypozyczen DESC;
