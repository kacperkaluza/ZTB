-- ROLLUP 02
-- Pokazuje laczna kwote podatku VAT w podziale na lata, typy paliwa, typy ubezpieczen i pracownikow

SELECT
    NVL(TO_CHAR(d.rok), 'RAZEM LATA') AS rok_wydania,
    NVL(pal.Nazwa_Paliwa, 'RAZEM TYP PALIWA') AS typ_paliwa,
    NVL(tu.Nazwa_Typu, 'RAZEM TYP UBEZPIECZENIA') AS typ_ubezpieczenia,
    NVL(TO_CHAR(d.ID_Pracownik_Wydania), ' ') AS id_pracownika,
    NVL(p.Nazwisko, 'RAZEM PRACOWNIK') AS pracownik,
    ROUND(d.laczna_kwota_vat, 2) AS laczna_kwota_vat
FROM (
    SELECT
        TO_NUMBER(TO_CHAR(w.Data_Wydania, 'YYYY')) AS rok,
        sam.ID_Typu_Paliwa,
        ub.ID_Typu_Ubezpieczenia,
        w.ID_Pracownik_Wydania,
        -- Obliczamy kwote VAT (23% z ceny za dobe)
        SUM(w.Cena_Doba * 0.23) AS laczna_kwota_vat
    FROM p_72_Wypozyczenia w
    JOIN p_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    JOIN p_72_Ubezpieczenie ub ON w.ID_Ubezpieczenie = ub.ID_Ubezpieczenie
    GROUP BY ROLLUP (TO_NUMBER(TO_CHAR(w.Data_Wydania, 'YYYY')), sam.ID_Typu_Paliwa, ub.ID_Typu_Ubezpieczenia, w.ID_Pracownik_Wydania)
) d
LEFT JOIN p_72_Typ_Paliwa pal ON d.ID_Typu_Paliwa = pal.ID_Typu_Paliwa
LEFT JOIN p_72_Typ_Ubezpieczenia tu ON d.ID_Typu_Ubezpieczenia = tu.ID_Typu_Ubezpieczenia
LEFT JOIN p_72_Pracownik p ON d.ID_Pracownik_Wydania = p.ID_Pracownik
ORDER BY rok_wydania, typ_paliwa, typ_ubezpieczenia, pracownik, laczna_kwota_vat DESC;
