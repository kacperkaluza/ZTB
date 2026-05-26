-- ZTB Project - Pure Star Schema Data Warehouse DDL Specifications
-- Prefix: h_72_
-- Target Engine: Oracle Database 23ai
-- Designed for direct recreation in Oracle SQL Developer Data Modeler
-- STRICT POLICY: 5 Flat Dimensions + 1 Central Fact Table. Keeps ONLY active query columns.

---------------------------------------------------------
-- 1. PURE FLAT DIMENSIONS
---------------------------------------------------------

-- Dimension: h_72_Klient (Client - Flat)
CREATE TABLE h_72_Klient 
( 
    ID_Klient NUMBER(8) NOT NULL, 
    Imie      VARCHAR2(50), 
    Nazwisko  VARCHAR2(80) 
);

ALTER TABLE h_72_Klient 
    ADD CONSTRAINT h_72_Klient_PK PRIMARY KEY ( ID_Klient );


-- Dimension: h_72_Samochod (Car - Flat / Denormalized)
CREATE TABLE h_72_Samochod 
( 
    ID_Samochod         NUMBER(5) NOT NULL, 
    ID_Model            NUMBER(5) NOT NULL, 
    ID_Marka            NUMBER(3) NOT NULL, 
    ID_Kategoria        NUMBER(2) NOT NULL, 
    ID_Typu_Paliwa      NUMBER(2) NOT NULL, 
    Nazwa_Modelu        VARCHAR2(80), 
    Nazwa_Marki         VARCHAR2(50), 
    Nazwa_Paliwa        VARCHAR2(30), 
    Nazwa_Kategorii     VARCHAR2(50) 
);

ALTER TABLE h_72_Samochod 
    ADD CONSTRAINT h_72_Samochod_PK PRIMARY KEY ( ID_Samochod );


-- Dimension: h_72_Oddzial (Branch / Address - Flat / Denormalized)
CREATE TABLE h_72_Oddzial 
( 
    ID_Oddzial        NUMBER(3) NOT NULL, 
    ID_Miasta         NUMBER(5) NOT NULL, 
    ID_Wojewodztwo    NUMBER(2) NOT NULL, 
    ID_Panstwa        NUMBER(3) NOT NULL, 
    Nazwa_Oddzialu    VARCHAR2(80), 
    Nazwa_Miasta      VARCHAR2(80), 
    Nazwa_Wojewodztwa VARCHAR2(80), 
    Nazwa_Panstwa     VARCHAR2(80) 
);

ALTER TABLE h_72_Oddzial 
    ADD CONSTRAINT h_72_Oddzial_PK PRIMARY KEY ( ID_Oddzial );


-- Dimension: h_72_Pracownik (Employee / Position - Flat / Denormalized)
CREATE TABLE h_72_Pracownik 
( 
    ID_Pracownik     NUMBER(4) NOT NULL, 
    ID_Stanowisko    NUMBER(2) NOT NULL, 
    Nazwisko         VARCHAR2(80), 
    Nazwa_Stanowiska VARCHAR2(60) 
);

ALTER TABLE h_72_Pracownik 
    ADD CONSTRAINT h_72_Pracownik_PK PRIMARY KEY ( ID_Pracownik );


-- Dimension: h_72_Ubezpieczenie (Insurance / Type - Flat / Denormalized)
CREATE TABLE h_72_Ubezpieczenie 
( 
    ID_Ubezpieczenie      NUMBER(8) NOT NULL, 
    ID_Typu_Ubezpieczenia NUMBER(2) NOT NULL, 
    Nazwa_Typu            VARCHAR2(80) 
);

ALTER TABLE h_72_Ubezpieczenie 
    ADD CONSTRAINT h_72_Ubezpieczenie_PK PRIMARY KEY ( ID_Ubezpieczenie );


---------------------------------------------------------
-- 2. CENTRAL FACT TABLE
---------------------------------------------------------

-- Fact: h_72_Wypozyczenia (Car Rental Facts)
CREATE TABLE h_72_Wypozyczenia 
( 
    ID_Samochod          NUMBER(5) NOT NULL, 
    ID_Klient            NUMBER(8) NOT NULL, 
    ID_Oddzial_Wydania   NUMBER(3) NOT NULL, 
    ID_Pracownik_Wydania NUMBER(4) NOT NULL, 
    ID_Ubezpieczenie     NUMBER(8) NOT NULL, 
    Status_Wypozyczenia  VARCHAR2(50), 
    Data_Wydania         DATE NOT NULL, 
    Cena_Doba            NUMBER(8,2) 
);

ALTER TABLE h_72_Wypozyczenia 
    ADD CONSTRAINT h_72_Wypozyczenia_PK PRIMARY KEY 
    ( 
        ID_Samochod, 
        ID_Klient, 
        ID_Oddzial_Wydania, 
        ID_Pracownik_Wydania, 
        ID_Ubezpieczenie, 
        Data_Wydania 
    );


---------------------------------------------------------
-- 3. FOREIGN KEY CONSTRAINTS
---------------------------------------------------------

ALTER TABLE h_72_Wypozyczenia 
    ADD CONSTRAINT h_72_Wyp_Samochod_FK FOREIGN KEY ( ID_Samochod ) 
    REFERENCES h_72_Samochod ( ID_Samochod );

ALTER TABLE h_72_Wypozyczenia 
    ADD CONSTRAINT h_72_Wyp_Klient_FK FOREIGN KEY ( ID_Klient ) 
    REFERENCES h_72_Klient ( ID_Klient );

ALTER TABLE h_72_Wypozyczenia 
    ADD CONSTRAINT h_72_Wyp_Odd_Wyd_FK FOREIGN KEY ( ID_Oddzial_Wydania ) 
    REFERENCES h_72_Oddzial ( ID_Oddzial );

ALTER TABLE h_72_Wypozyczenia 
    ADD CONSTRAINT h_72_Wyp_Prac_Wyd_FK FOREIGN KEY ( ID_Pracownik_Wydania ) 
    REFERENCES h_72_Pracownik ( ID_Pracownik );

ALTER TABLE h_72_Wypozyczenia 
    ADD CONSTRAINT h_72_Wyp_Ubezpieczenie_FK FOREIGN KEY ( ID_Ubezpieczenie ) 
    REFERENCES h_72_Ubezpieczenie ( ID_Ubezpieczenie );


---------------------------------------------------------
-- 4. BITMAP INDEXES (For high-speed Star Transformations)
---------------------------------------------------------

CREATE BITMAP INDEX h_72_Wyp_Samochod_IDX ON h_72_Wypozyczenia ( ID_Samochod );
CREATE BITMAP INDEX h_72_Wyp_Klient_IDX ON h_72_Wypozyczenia ( ID_Klient );
CREATE BITMAP INDEX h_72_Wyp_Odd_Wyd_IDX ON h_72_Wypozyczenia ( ID_Oddzial_Wydania );
CREATE BITMAP INDEX h_72_Wyp_Prac_Wyd_IDX ON h_72_Wypozyczenia ( ID_Pracownik_Wydania );
CREATE BITMAP INDEX h_72_Wyp_Ubezpieczenie_IDX ON h_72_Wypozyczenia ( ID_Ubezpieczenie );
