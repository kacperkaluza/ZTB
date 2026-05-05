-- =============================================================================
-- ro_03.sql — ROLLUP: Przychody wg hierarchii czasowej z ubezpieczeniami
-- =============================================================================
-- Pytanie biznesowe:
--   Jak rozklada sie przychod, koszt transportu i kaucja w czasie
--   (Rok → Kwartal → Miesiac), z dodatkowym podzialem na typ ubezpieczenia?
--   Pozwala to zidentyfikowac sezonowe trendy przychodowe
--   oraz popularnosc poszczegolnych typow ubezpieczen w czasie.
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Ubezpieczenie → Typ_Ubezpieczenia
--   2) Wypozyczenia → Pracownik (wydania) → Stanowisko
--   3) Wypozyczenia → Oddzial (wydania)
--
-- Miary: Koszt_Transportu, Kaucja, Cena_Doba
-- =============================================================================

SELECT
    EXTRACT(YEAR FROM w.Data_Wydania)                               AS rok,
    TO_CHAR(w.Data_Wydania, 'Q')                                    AS kwartal,
    EXTRACT(MONTH FROM w.Data_Wydania)                              AS miesiac,
    tu.ID_Typu_Ubezpieczenia,
    MIN(tu.Nazwa_Typu)                                              AS typ_ubezpieczenia,
    st.ID_Stanowisko,
    MIN(st.Nazwa_Stanowiska)                                        AS Nazwa_Stanowiska,
    COUNT(*)                                                        AS liczba_wypozyczen,
    SUM(w.Cena_Doba)                                                AS suma_stawek_dziennych,
    SUM(w.Koszt_Transportu)                                         AS suma_kosztow_transportu,
    SUM(w.Kaucja)                                                   AS suma_kaucji,
    ROUND(AVG(w.Cena_Doba), 2)                                      AS srednia_stawka_dzienna,
    ROUND(AVG(w.Koszt_Transportu), 2)                               AS sredni_koszt_transportu
FROM
    p_72_Wypozyczenia w
    JOIN p_72_Ubezpieczenie    ub ON w.ID_Ubezpieczenie        = ub.ID_Ubezpieczenie
    JOIN p_72_Typ_Ubezpieczenia tu ON ub.ID_Typu_Ubezpieczenia = tu.ID_Typu_Ubezpieczenia
    JOIN p_72_Pracownik        pr ON w.ID_Pracownik_Wydania    = pr.ID_Pracownik
    JOIN p_72_Stanowisko       st ON pr.ID_Stanowisko          = st.ID_Stanowisko
    JOIN p_72_Oddzial          odd ON w.ID_Oddzial_Wydania     = odd.ID_Oddzial
WHERE
    w.Data_Wydania IS NOT NULL
GROUP BY
    ROLLUP(
        EXTRACT(YEAR FROM w.Data_Wydania),
        TO_CHAR(w.Data_Wydania, 'Q'),
        EXTRACT(MONTH FROM w.Data_Wydania),
        tu.ID_Typu_Ubezpieczenia,
        st.ID_Stanowisko
    )
ORDER BY
    rok                      NULLS LAST,
    kwartal                  NULLS LAST,
    miesiac                  NULLS LAST,
    tu.ID_Typu_Ubezpieczenia NULLS LAST,
    st.ID_Stanowisko         NULLS LAST;
