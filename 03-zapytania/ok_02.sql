-- OKNA 02
-- Pokazuje porownanie kwartalne przychodow oddzialow, pracownikow i statusow z kwartalem poprzednim, nastepnym oraz skrajnosciami

SELECT
    sa.Nazwa_Oddzialu AS nazwa_oddzialu,
    p.Nazwisko AS pracownik,
    analiza.STATUS_WYPOZYCZENIA AS status_wypozyczenia,
    analiza.rok,
    analiza.kwartal,
    analiza.poprzedni_kwartal,
    analiza.obecna,
    analiza.nastepny_kwartal,
    analiza.najlepszy_kwartal,
    analiza.najgorszy_kwartal
FROM (
    SELECT
        d.ID_Oddzial_Wydania,
        d.ID_Pracownik_Wydania,
        d.STATUS_WYPOZYCZENIA,
        d.rok,
        d.kwartal,
        d.wartosc AS obecna,
        LAG(d.wartosc, 1) OVER (
            PARTITION BY d.ID_Oddzial_Wydania, d.ID_Pracownik_Wydania, d.STATUS_WYPOZYCZENIA
            ORDER BY d.rok, d.kwartal
        ) AS poprzedni_kwartal,
        LEAD(d.wartosc, 1) OVER (
            PARTITION BY d.ID_Oddzial_Wydania, d.ID_Pracownik_Wydania, d.STATUS_WYPOZYCZENIA
            ORDER BY d.rok, d.kwartal
        ) AS nastepny_kwartal,
        FIRST_VALUE(d.wartosc) OVER (
            PARTITION BY d.ID_Oddzial_Wydania, d.ID_Pracownik_Wydania, d.STATUS_WYPOZYCZENIA
            ORDER BY d.wartosc DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS najlepszy_kwartal,
        LAST_VALUE(d.wartosc) OVER (
            PARTITION BY d.ID_Oddzial_Wydania, d.ID_Pracownik_Wydania, d.STATUS_WYPOZYCZENIA
            ORDER BY d.wartosc DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS najgorszy_kwartal
    FROM (
        SELECT
            w.ID_Oddzial_Wydania,
            w.ID_Pracownik_Wydania,
            w.STATUS_WYPOZYCZENIA,
            TO_NUMBER(TO_CHAR(w.Data_Wydania, 'YYYY')) AS rok,
            TO_NUMBER(TO_CHAR(w.Data_Wydania, 'Q')) AS kwartal,
            SUM(w.Cena_Doba) AS wartosc
        FROM p_72_Wypozyczenia w
        GROUP BY w.ID_Oddzial_Wydania, w.ID_Pracownik_Wydania, w.STATUS_WYPOZYCZENIA,
                 TO_NUMBER(TO_CHAR(w.Data_Wydania, 'YYYY')), TO_NUMBER(TO_CHAR(w.Data_Wydania, 'Q'))
    ) d
) analiza
LEFT JOIN p_72_Oddzial sa ON analiza.ID_Oddzial_Wydania = sa.ID_Oddzial
LEFT JOIN p_72_Pracownik p ON analiza.ID_Pracownik_Wydania = p.ID_Pracownik
ORDER BY sa.Nazwa_Oddzialu, p.Nazwisko, analiza.rok, analiza.kwartal;
