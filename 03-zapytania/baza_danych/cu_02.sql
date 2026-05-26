-- CUBE 02
-- Pokazuje szacowany zysk w podziale na pracownikow, typy paliwa i typy ubezpieczen

SELECT
    NVL(p.Nazwisko, 'RAZEM PRACOWNIK') AS pracownik,
    NVL(pal.Nazwa_Paliwa, 'RAZEM TYP PALIWA') AS typ_paliwa,
    NVL(tu.Nazwa_Typu, 'RAZEM TYP UBEZPIECZENIA') AS typ_ubezpieczenia,
    ROUND(d.szacowany_zysk, 2) AS zysk_z_transakcji
FROM (
    SELECT
        w.ID_Pracownik_Wydania,
        sam.ID_Typu_Paliwa,
        ub.ID_Typu_Ubezpieczenia,
        -- Szacowany zysk (15% z ceny za dobe)
        SUM(w.Cena_Doba * 0.15) AS szacowany_zysk
    FROM p_72_Wypozyczenia w
    JOIN p_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    JOIN p_72_Ubezpieczenie ub ON w.ID_Ubezpieczenie = ub.ID_Ubezpieczenie
    GROUP BY CUBE (w.ID_Pracownik_Wydania, sam.ID_Typu_Paliwa, ub.ID_Typu_Ubezpieczenia)
) d
LEFT JOIN p_72_Pracownik p ON d.ID_Pracownik_Wydania = p.ID_Pracownik
LEFT JOIN p_72_Typ_Paliwa pal ON d.ID_Typu_Paliwa = pal.ID_Typu_Paliwa
LEFT JOIN p_72_Typ_Ubezpieczenia tu ON d.ID_Typu_Ubezpieczenia = tu.ID_Typu_Ubezpieczenia
ORDER BY pracownik, typ_paliwa, typ_ubezpieczenia;
