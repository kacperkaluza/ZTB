@echo off
SET DB_CONN=system/ZtbOracle123!@localhost:1521/FREE

if not exist "log" mkdir "log"
if not exist "bad" mkdir "bad"

REM === Tabele główne ===
	sqlldr %DB_CONN% control=\ctl\p_72_panstwo.ctl log=\log\p_72_panstwo.log bad=\bad\p_72_panstwo.bad data=\csv\p_72_panstwo.csv
	sqlldr %DB_CONN% control=\ctl\p_72_wojewodztwo.ctl log=\log\p_72_wojewodztwo.log bad=\bad\p_72_wojewodztwo.bad data=\csv\p_72_wojewodztwo.csv
	sqlldr %DB_CONN% control=\ctl\p_72_miasto.ctl log=\log\p_72_miasto.log bad=\bad\p_72_miasto.bad data=\csv\p_72_miasto.csv
	sqlldr %DB_CONN% control=\ctl\p_72_ulica.ctl log=\log\p_72_ulica.log bad=\bad\p_72_ulica.bad data=\csv\p_72_ulica.csv
	sqlldr %DB_CONN% control=\ctl\p_72_oddzial.ctl log=\log\p_72_oddzial.log bad=\bad\p_72_oddzial.bad data=\csv\p_72_oddzial.csv
	sqlldr %DB_CONN% control=\ctl\p_72_stanowisko.ctl log=\log\p_72_stanowisko.log bad=\bad\p_72_stanowisko.bad data=\csv\p_72_stanowisko.csv
	sqlldr %DB_CONN% control=\ctl\p_72_pracownik.ctl log=\log\p_72_pracownik.log bad=\bad\p_72_pracownik.bad data=\csv\p_72_pracownik.csv
	sqlldr %DB_CONN% control=\ctl\p_72_kategoria.ctl log=\log\p_72_kategoria.log bad=\bad\p_72_kategoria.bad data=\csv\p_72_kategoria.csv
	sqlldr %DB_CONN% control=\ctl\p_72_kolor.ctl log=\log\p_72_kolor.log bad=\bad\p_72_kolor.bad data=\csv\p_72_kolor.csv
	sqlldr %DB_CONN% control=\ctl\p_72_marka.ctl log=\log\p_72_marka.log bad=\bad\p_72_marka.bad data=\csv\p_72_marka.csv
	sqlldr %DB_CONN% control=\ctl\p_72_model.ctl log=\log\p_72_model.log bad=\bad\p_72_model.bad data=\csv\p_72_model.csv
	sqlldr %DB_CONN% control=\ctl\p_72_typ_paliwa.ctl log=\log\p_72_typ_paliwa.log bad=\bad\p_72_typ_paliwa.bad data=\csv\p_72_typ_paliwa.csv
	sqlldr %DB_CONN% control=\ctl\p_72_typ_skrzyni.ctl log=\log\p_72_typ_skrzyni.log bad=\bad\p_72_typ_skrzyni.bad data=\csv\p_72_typ_skrzyni.csv
	sqlldr %DB_CONN% control=\ctl\p_72_samochod.ctl log=\log\p_72_samochod.log bad=\bad\p_72_samochod.bad data=\csv\p_72_samochod.csv
	sqlldr %DB_CONN% control=\ctl\p_72_typ_ubezpieczenia.ctl log=\log\p_72_typ_ubezpieczenia.log bad=\bad\p_72_typ_ubezpieczenia.bad data=\csv\p_72_typ_ubezpieczenia.csv
	sqlldr %DB_CONN% control=\ctl\p_72_ubezpieczenie.ctl log=\log\p_72_ubezpieczenie.log bad=\bad\p_72_ubezpieczenie.bad data=\csv\p_72_ubezpieczenie.csv
	sqlldr %DB_CONN% control=\ctl\p_72_klient.ctl log=\log\p_72_klient.log bad=\bad\p_72_klient.bad data=\csv\p_72_klient.csv
	sqlldr %DB_CONN% control=\ctl\p_72_wypozyczenia.ctl log=\log\p_72_wypozyczenia.log bad=\bad\p_72_wypozyczenia.bad data=\csv\p_72_wypozyczenia.csv



	
echo.
echo === WSZYSTKIE DANE ZALADOWANE ===
pause