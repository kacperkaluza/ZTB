-- OKNA 03
-- Pokazuje miesieczna zmiane przychodow pracownika (MoM) w ramach oddzialu i statusu
-- Replicated for Star Schema DWH (h_72_)

SELECT
    sa.Nazwa_Oddzialu AS nazwa_oddzialu,
    analiza.id_pracownika,
    p.Nazwisko AS pracownik,
    p.Nazwa_Stanowiska AS stanowisko,
    analiza.STATUS_WYPOZYCZENIA AS status_wypozyczenia,
    analiza.miesiac,
    analiza.sprzedaz,
    analiza.sprzedaz_poprzednio,
    analiza.zmiana
FROM (
    SELECT
        z.ID_Oddzial_Wydania AS id_salon,
        z.ID_Pracownik_Wydania AS id_pracownika,
        z.STATUS_WYPOZYCZENIA,
        z.miesiac,
        z.sprzedaz,
        LAG(z.sprzedaz, 1) OVER (
            PARTITION BY z.ID_Oddzial_Wydania, z.ID_Pracownik_Wydania, z.STATUS_WYPOZYCZENIA
            ORDER BY z.miesiac
        ) AS sprzedaz_poprzednio,
        z.sprzedaz - LAG(z.sprzedaz, 1) OVER (
            PARTITION BY z.ID_Oddzial_Wydania, z.ID_Pracownik_Wydania, z.STATUS_WYPOZYCZENIA
            ORDER BY z.miesiac
        ) AS zmiana
    FROM (
        SELECT
            w.ID_Oddzial_Wydania,
            w.ID_Pracownik_Wydania,
            w.STATUS_WYPOZYCZENIA,
            TO_CHAR(w.Data_Wydania, 'YYYY-MM') AS miesiac,
            SUM(w.Cena_Doba) AS sprzedaz
        FROM h_72_Wypozyczenia w
        GROUP BY w.ID_Oddzial_Wydania, w.ID_Pracownik_Wydania, w.STATUS_WYPOZYCZENIA, TO_CHAR(w.Data_Wydania, 'YYYY-MM')
    ) z
) analiza
LEFT JOIN h_72_Oddzial sa ON analiza.id_salon = sa.ID_Oddzial
LEFT JOIN h_72_Pracownik p ON analiza.id_pracownika = p.ID_Pracownik
ORDER BY sa.Nazwa_Oddzialu, p.Nazwisko, analiza.miesiac;
