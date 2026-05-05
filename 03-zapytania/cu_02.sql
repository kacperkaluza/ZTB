-- =============================================================================
-- cu_02.sql — CUBE: Wielowymiarowa analiza: Typ_Ubezpieczenia × Status × Kolor
-- =============================================================================
-- Pytanie biznesowe:
--   Jak rozklada sie srednia kaucja i laczny koszt transportu
--   w kazdej kombinacji: typu ubezpieczenia, statusu wypozyczenia i koloru?
--
-- Sciezki slownikowe (>=3):
--   1) Wypozyczenia → Ubezpieczenie → Typ_Ubezpieczenia
--   2) Wypozyczenia → Samochod → Kolor
--   3) Wypozyczenia → Klient
--
-- Miary: Kaucja, Koszt_Transportu, Status_Wypozyczenia (wymiar inline)
-- =============================================================================

SELECT
    tu.ID_Typu_Ubezpieczenia,
    MIN(tu.Nazwa_Typu)                                              AS typ_ubezpieczenia,
    w.Status_Wypozyczenia,
    kol.ID_Kolor,
    MIN(kol.Nazwa_Koloru)                                           AS Nazwa_Koloru,
    COUNT(*)                                                        AS liczba_wypozyczen,
    SUM(w.Kaucja)                                                   AS suma_kaucji,
    ROUND(AVG(w.Kaucja), 2)                                         AS srednia_kaucja,
    SUM(w.Koszt_Transportu)                                         AS suma_kosztow_transportu,
    ROUND(AVG(w.Koszt_Transportu), 2)                               AS sredni_koszt_transportu,
    ROUND(AVG(ub.Kwota_Pokrycia), 2)                                AS srednia_kwota_pokrycia
FROM
    p_72_Wypozyczenia w
    JOIN p_72_Ubezpieczenie    ub  ON w.ID_Ubezpieczenie        = ub.ID_Ubezpieczenie
    JOIN p_72_Typ_Ubezpieczenia tu ON ub.ID_Typu_Ubezpieczenia = tu.ID_Typu_Ubezpieczenia
    JOIN p_72_Samochod         sam ON w.ID_Samochod              = sam.ID_Samochod
    JOIN p_72_Kolor            kol ON sam.ID_Kolor               = kol.ID_Kolor
    JOIN p_72_Klient           kl  ON w.ID_Klient                = kl.ID_Klient
GROUP BY
    CUBE(tu.ID_Typu_Ubezpieczenia, w.Status_Wypozyczenia, kol.ID_Kolor)
ORDER BY
    tu.ID_Typu_Ubezpieczenia NULLS LAST,
    w.Status_Wypozyczenia    NULLS LAST,
    kol.ID_Kolor             NULLS LAST;
