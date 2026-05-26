-- ROLLUP 03
-- Pokazuje srednia cene netto w podziale na panstwa, kategorie pojazdow i klientow
-- Replicated for Star Schema DWH (h_72_)

SELECT
    NVL(pan.Nazwa_Panstwa, 'RAZEM PANSTWO') AS panstwo,
    NVL(kat.Nazwa_Kategorii, 'RAZEM KATEGORIA') AS kategoria_pojazdu,
    NVL(TO_CHAR(d.ID_Klient), ' ') AS id_klienta,
    NVL(k.Nazwisko, 'RAZEM KLIENT') AS klient,
    ROUND(d.srednia_cena, 2) AS srednia_cena_netto
FROM (
    SELECT
        o.ID_Panstwa,
        sam.ID_Kategoria,
        w.ID_Klient,
        AVG(w.Cena_Doba) AS srednia_cena
    FROM h_72_Wypozyczenia w
    JOIN h_72_Oddzial o ON w.ID_Oddzial_Wydania = o.ID_Oddzial
    JOIN h_72_Samochod sam ON w.ID_Samochod = sam.ID_Samochod
    GROUP BY ROLLUP (o.ID_Panstwa, sam.ID_Kategoria, w.ID_Klient)
) d
LEFT JOIN (SELECT DISTINCT ID_Panstwa, Nazwa_Panstwa FROM h_72_Oddzial) pan ON d.ID_Panstwa = pan.ID_Panstwa
LEFT JOIN (SELECT DISTINCT ID_Kategoria, Nazwa_Kategorii FROM h_72_Samochod) kat ON d.ID_Kategoria = kat.ID_Kategoria
LEFT JOIN h_72_Klient k ON d.ID_Klient = k.ID_Klient
ORDER BY panstwo, kategoria_pojazdu, klient, srednia_cena_netto DESC;
