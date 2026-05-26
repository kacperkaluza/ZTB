-- ROLLUP 03
-- Pokazuje srednia cene netto w podziale na panstwa, kategorie pojazdow i klientow

SELECT
    NVL(pan.Nazwa_Panstwa, 'RAZEM PANSTWO') AS panstwo,
    NVL(kat.Nazwa_Kategorii, 'RAZEM KATEGORIA') AS kategoria_pojazdu,
    NVL(TO_CHAR(d.ID_Klient), ' ') AS id_klienta,
    NVL(k.Nazwisko, 'RAZEM KLIENT') AS klient,
    ROUND(d.srednia_cena, 2) AS srednia_cena_netto
FROM (
    SELECT
        woj.ID_Panstwa,
        sam.ID_Kategoria,
        w.ID_Klient,
        AVG(w.Cena_Doba) AS srednia_cena
    FROM p_72_Wypozyczenia w
    JOIN p_72_Oddzial s ON w.ID_Oddzial_Wydania = s.ID_Oddzial
    JOIN p_72_Ulica u ON s.ID_Ulica = u.ID_Ulica
    JOIN p_72_Miasto mi ON u.ID_Miasta = mi.ID_Miasta
    JOIN p_72_Wojewodztwo woj ON mi.ID_Wojewodztwo = woj.ID_Wojewodztwo
    JOIN p_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    GROUP BY ROLLUP (woj.ID_Panstwa, sam.ID_Kategoria, w.ID_Klient)
) d
LEFT JOIN p_72_Panstwo pan ON d.ID_Panstwa = pan.ID_Panstwa
LEFT JOIN p_72_Kategoria kat ON d.ID_Kategoria = kat.ID_Kategoria
LEFT JOIN p_72_Klient k ON d.ID_Klient = k.ID_Klient
ORDER BY panstwo, kategoria_pojazdu, klient;
