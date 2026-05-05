@echo off
setlocal

set DB_USER=system
set DB_PASS=ZtbOracle123!
set DB_SERVICE=FREE

echo Loading data into Oracle Database...

sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_panstwo.ctl log=csv/p_72_panstwo.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_wojewodztwo.ctl log=csv/p_72_wojewodztwo.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_miasto.ctl log=csv/p_72_miasto.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_ulica.ctl log=csv/p_72_ulica.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_oddzial.ctl log=csv/p_72_oddzial.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_stanowisko.ctl log=csv/p_72_stanowisko.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_pracownik.ctl log=csv/p_72_pracownik.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_kategoria.ctl log=csv/p_72_kategoria.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_kolor.ctl log=csv/p_72_kolor.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_marka.ctl log=csv/p_72_marka.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_model.ctl log=csv/p_72_model.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_typ_paliwa.ctl log=csv/p_72_typ_paliwa.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_typ_skrzyni.ctl log=csv/p_72_typ_skrzyni.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_samochod.ctl log=csv/p_72_samochod.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_typ_ubezpieczenia.ctl log=csv/p_72_typ_ubezpieczenia.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_ubezpieczenie.ctl log=csv/p_72_ubezpieczenie.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_klient.ctl log=csv/p_72_klient.log
sqlldr %DB_USER%/%DB_PASS%@%DB_SERVICE% control=ctl/p_72_wypozyczenia.ctl log=csv/p_72_wypozyczenia.log

echo Data loading completed.
pause
