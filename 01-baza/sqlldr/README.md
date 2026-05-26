# SQL*Loader

## Opis
Katalog zawiera podkatalogi: 
- csv — pliki csv z danymi
- ctl — pliki ctl z instrukcjami dla SQL*Loadera
- sql — pliki sql z zapytaniami

## Generowanie danych
Skrypt w pythonie do generowania plikow csv i ctl 

## Zaladowanie danych 
Z racji iz korzystalismy z Dockerowego Oracle, SQL*Loader jest w Dockerze. Trzeba go skopiowac do kontenera. 
Dlatego jest to troche bardziej skoplikowane niz korzystanie z lokalnego SQL*Loadera. Lub wirtualki linuxa.
Tutaj opisze jak wykorzystac sqlldr w dockerze zrobiony przez nas:

### Uruchom skrypt:
Najpierw upewnij się że docker jest uruchomiony:

```bash
docker ps
```

Nastepnie uruchom skrypt, który kopiuje pliki do kontenera i uruchamia sqlldr:

```bash
./0-sqlldr-docker.sh
```



