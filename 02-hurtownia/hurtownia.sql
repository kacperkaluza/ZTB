-- Data Warehouse Schema for Car Rental System
-- Star Schema Design
-- Naming Convention: h_72_ prefix

-- Dimension: Time
CREATE TABLE h_72_czas (
    id_czas         NUMBER(8) NOT NULL,
    data            DATE NOT NULL,
    dzien           NUMBER(2),
    miesiac         NUMBER(2),
    rok             NUMBER(4),
    kwartal         NUMBER(1),
    dzien_tygodnia  VARCHAR2(20),
    czy_weekend     NUMBER(1),
    CONSTRAINT h_72_czas_pk PRIMARY KEY (id_czas)
);

-- Dimension: Client (Denormalized)
CREATE TABLE h_72_klient (
    id_klient_dw    NUMBER(8) NOT NULL,
    id_klient_src   NUMBER(8),
    imie            VARCHAR2(50),
    nazwisko        VARCHAR2(80),
    pesel           VARCHAR2(11),
    miasto          VARCHAR2(80),
    wojewodztwo     VARCHAR2(80),
    panstwo         VARCHAR2(80),
    CONSTRAINT h_72_klient_pk PRIMARY KEY (id_klient_dw)
);

-- Dimension: Car (Denormalized)
CREATE TABLE h_72_samochod (
    id_samochod_dw  NUMBER(5) NOT NULL,
    id_samochod_src NUMBER(5),
    marka           VARCHAR2(50),
    model           VARCHAR2(80),
    kategoria       VARCHAR2(50),
    kolor           VARCHAR2(30),
    typ_paliwa      VARCHAR2(30),
    rok_produkcji   NUMBER(4),
    CONSTRAINT h_72_samochod_pk PRIMARY KEY (id_samochod_dw)
);

-- Dimension: Branch (Denormalized)
CREATE TABLE h_72_oddzial (
    id_oddzial_dw   NUMBER(3) NOT NULL,
    id_oddzial_src  NUMBER(3),
    nazwa_oddzialu  VARCHAR2(80),
    miasto          VARCHAR2(80),
    wojewodztwo     VARCHAR2(80),
    CONSTRAINT h_72_oddzial_pk PRIMARY KEY (id_oddzial_dw)
);

-- Dimension: Employee (Denormalized)
CREATE TABLE h_72_pracownik (
    id_pracownik_dw  NUMBER(4) NOT NULL,
    id_pracownik_src NUMBER(4),
    imie             VARCHAR2(50),
    nazwisko         VARCHAR2(80),
    stanowisko       VARCHAR2(60),
    CONSTRAINT h_72_pracownik_pk PRIMARY KEY (id_pracownik_dw)
);

-- Fact Table: Rentals
CREATE TABLE h_72_wypozyczenie (
    id_wypozyczenia_dw      NUMBER(10) NOT NULL,
    id_klient_dw            NUMBER(8) NOT NULL,
    id_samochod_dw          NUMBER(5) NOT NULL,
    id_oddzial_wydania_dw   NUMBER(3) NOT NULL,
    id_oddzial_odbioru_dw   NUMBER(3) NOT NULL,
    id_pracownik_wydania_dw  NUMBER(4) NOT NULL,
    id_pracownik_odbioru_dw  NUMBER(4) NOT NULL,
    id_data_wydania         NUMBER(8) NOT NULL,
    id_data_zwrotu          NUMBER(8),
    
    -- Measures
    cena_doba               NUMBER(8,2),
    liczba_dni              NUMBER(4,0),
    koszt_netto             NUMBER(12,2),
    koszt_brutto            NUMBER(12,2),
    kaucja                  NUMBER(10,2),
    rabat_procent           NUMBER(5,2),
    rabat_kwota             NUMBER(10,2),
    dystans_km              NUMBER(8,1),
    kara_za_opoznienie      NUMBER(10,2),
    koszt_ubezpieczenia     NUMBER(10,2),
    koszt_paliwa            NUMBER(10,2),

    CONSTRAINT h_72_wypozyczenie_pk PRIMARY KEY (id_wypozyczenia_dw),
    CONSTRAINT fk_h_klient FOREIGN KEY (id_klient_dw) REFERENCES h_72_klient(id_klient_dw),
    CONSTRAINT fk_h_samochod FOREIGN KEY (id_samochod_dw) REFERENCES h_72_samochod(id_samochod_dw),
    CONSTRAINT fk_h_oddzial_wyd FOREIGN KEY (id_oddzial_wydania_dw) REFERENCES h_72_oddzial(id_oddzial_dw),
    CONSTRAINT fk_h_oddzial_odb FOREIGN KEY (id_oddzial_odbioru_dw) REFERENCES h_72_oddzial(id_oddzial_dw),
    CONSTRAINT fk_h_pracownik_wyd FOREIGN KEY (id_pracownik_wydania_dw) REFERENCES h_72_pracownik(id_pracownik_dw),
    CONSTRAINT fk_h_pracownik_odb FOREIGN KEY (id_pracownik_odbioru_dw) REFERENCES h_72_pracownik(id_pracownik_dw),
    CONSTRAINT fk_h_data_wyd FOREIGN KEY (id_data_wydania) REFERENCES h_72_czas(id_czas),
    CONSTRAINT fk_h_data_zwr FOREIGN KEY (id_data_zwrotu) REFERENCES h_72_czas(id_czas)
);
