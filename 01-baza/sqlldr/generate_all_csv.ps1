$ErrorActionPreference = 'Stop'

$counts = [ordered]@{
  p_72_panstwo           = 10
  p_72_wojewodztwo       = 90
  p_72_miasto            = 500
  p_72_ulica             = 1000
  p_72_oddzial           = 300
  p_72_stanowisko        = 20
  p_72_pracownik         = 800
  p_72_kategoria         = 30
  p_72_kolor             = 50
  p_72_marka             = 80
  p_72_model             = 400
  p_72_typ_paliwa        = 10
  p_72_typ_skrzyni       = 6
  p_72_samochod          = 1500
  p_72_typ_ubezpieczenia = 12
  p_72_ubezpieczenie     = 1200
  p_72_klient            = 2000
  p_72_wypozyczenia      = 100000
}

$outDir = Join-Path $PSScriptRoot 'csv'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-Writer {
  param([string]$FileName)
  $path = Join-Path $outDir $FileName
  return [System.IO.StreamWriter]::new($path, $false, [System.Text.UTF8Encoding]::new($false))
}

function Dec2 {
  param([double]$Value)
  return ([math]::Round($Value, 0)).ToString()
}

function DateIso {
  param([datetime]$Value)
  return $Value.ToString('yyyy-MM-dd')
}

$panstwa = @('Polska','Niemcy','Czechy','Slowacja','Litwa','Austria','Francja','Hiszpania','Wlochy','Holandia')
$wojBase = @(
  'Dolnoslaskie','Kujawsko-Pomorskie','Lubelskie','Lubuskie','Lodzkie','Malopolskie','Mazowieckie','Opolskie',
  'Podkarpackie','Podlaskie','Pomorskie','Slaskie','Swietokrzyskie','Warminsko-Mazurskie','Wielkopolskie','Zachodniopomorskie',
  'Bayern','Sachsen','Brandenburg','Hessen','Saarland','Bohemia','Moravia','Burgenland','Tirol','Galicia','Lombardia','Toscana','Andalucia','Catalunya'
)
$miastaBase = @(
  'Warszawa','Krakow','Wroclaw','Poznan','Gdansk','Lodz','Szczecin','Lublin','Bydgoszcz','Katowice',
  'Bialystok','Rzeszow','Olsztyn','Opole','Kielce','Torun','Gliwice','Zielona Gora','Plock','Radom',
  'Monachium','Berlin','Drezno','Lipsk','Praga','Brno','Wieden','Graz','Paryz','Lyon',
  'Madryt','Barcelona','Mediolan','Rzym','Amsterdam','Rotterdam','Bratyslawa','Wilno','Bruksela','Hamburg'
)
$uliceBase = @(
  'Dluga','Krotka','Szkolna','Polna','Lesna','Kosciuszki','Mickiewicza','Slowackiego','Kolejowa','Rynek',
  'Lipowa','Szeroka','Wiosenna','Jesienna','Akacjowa','Brzozowa','Sadowa','Spokojna','Ogrodowa','Parkowa',
  'Jagiellonska','Morska','Sloneczna','Kwiatowa','Poprzeczna','Glowna','Nadbrzezna','Wodna','Targowa','Dworcowa'
)
$imionaM = @('Jan','Piotr','Pawel','Marek','Lukasz','Michal','Krzysztof','Andrzej','Tomasz','Mateusz','Jakub','Dawid')
$imionaK = @('Anna','Katarzyna','Magdalena','Agnieszka','Joanna','Ewa','Monika','Aleksandra','Karolina','Natalia','Marta','Zofia')
$nazwiska = @('Nowak','Kowalski','Wisniewski','Wojcik','Kowalczyk','Kaminski','Lewandowski','Zielinski','Szymanski','Wozniak','Dabrowski','Kozlowski')

# 1) P_72_PANSTWO
$sw = New-Writer 'p_72_panstwo.csv'
for ($i = 1; $i -le $counts.p_72_panstwo; $i++) {
  $sw.WriteLine("$i,$($panstwa[$i-1])")
}
$sw.Dispose()

# 2) P_72_WOJEWODZTWO
$sw = New-Writer 'p_72_wojewodztwo.csv'
for ($i = 1; $i -le $counts.p_72_wojewodztwo; $i++) {
  $idPanstwa = (($i - 1) % $counts.p_72_panstwo) + 1
  $base = $wojBase[($i - 1) % $wojBase.Count]
  $name = if ($i -le $wojBase.Count) { $base } else { "$base Region $i" }
  $sw.WriteLine("$i,$idPanstwa,$name")
}
$sw.Dispose()

# 3) P_72_MIASTO
$sw = New-Writer 'p_72_miasto.csv'
for ($i = 1; $i -le $counts.p_72_miasto; $i++) {
  $idWoj = (($i - 1) % $counts.p_72_wojewodztwo) + 1
  $base = $miastaBase[($i - 1) % $miastaBase.Count]
  $suffix = [int](($i - 1) / $miastaBase.Count) + 1
  $name = if ($suffix -eq 1) { $base } else { "$base-$suffix" }
  $sw.WriteLine("$i,$idWoj,$name")
}
$sw.Dispose()

# 4) P_72_ULICA
$sw = New-Writer 'p_72_ulica.csv'
for ($i = 1; $i -le $counts.p_72_ulica; $i++) {
  $idMiasta = (($i - 1) % $counts.p_72_miasto) + 1
  $base = $uliceBase[($i - 1) % $uliceBase.Count]
  $nr = [int](($i - 1) / $uliceBase.Count) + 1
  $name = "$base $nr"
  $sw.WriteLine("$i,$idMiasta,$name")
}
$sw.Dispose()

# 5) P_72_ODDZIAL
$sw = New-Writer 'p_72_oddzial.csv'
for ($i = 1; $i -le $counts.p_72_oddzial; $i++) {
  $city = $miastaBase[($i - 1) % $miastaBase.Count]
  $idUlica = (($i - 1) % $counts.p_72_ulica) + 1
  $kod = ('{0:00}-{1:000}' -f (($i * 7) % 100), (($i * 19) % 1000))
  $telefon = '5{0:D8}' -f $i
  $email = "oddzial$i@ztb-rental.pl"
  $numerBudynku = (($i % 140) + 1)
  $sw.WriteLine("$i,Oddzial $city,$telefon,$email,08:00-18:00,$numerBudynku,$idUlica,$kod")
}
$sw.Dispose()

# 6) P_72_STANOWISKO
$stanowiska = @(
  'Doradca klienta','Specjalista ds. flot','Koordynator oddzialu','Mechanik','Mlodszy mechanik','Kierownik oddzialu',
  'Specjalista ds. szkod','Analityk operacyjny','Asystent biura','Kontroler jakosci','Pracownik myjni','Specjalista IT',
  'Ksiegowy','Specjalista ds. windykacji','Pracownik call center','Specjalista ds. umow','Pracownik lotniskowy','Inspektor techniczny',
  'Specjalista ds. zakupow','Koordynator serwisu'
)
$sw = New-Writer 'p_72_stanowisko.csv'
for ($i = 1; $i -le $counts.p_72_stanowisko; $i++) {
  $stawka = Dec2 (26 + ($i * 2.35))
  $sw.WriteLine("$i,$($stanowiska[$i-1]),Opis stanowiska $i,$stawka")
}
$sw.Dispose()

# 7) P_72_PRACOWNIK
$sw = New-Writer 'p_72_pracownik.csv'
$startEmp = [datetime]'2018-01-01'
for ($i = 1; $i -le $counts.p_72_pracownik; $i++) {
  $idOddzial = (($i - 1) % $counts.p_72_oddzial) + 1
  $idStan = (($i - 1) % $counts.p_72_stanowisko) + 1
  $isFemale = ($i % 2 -eq 0)
  $imie = if ($isFemale) { $imionaK[($i - 1) % $imionaK.Count] } else { $imionaM[($i - 1) % $imionaM.Count] }
  $nazw = $nazwiska[($i - 1) % $nazwiska.Count]
  $pesel = '{0:D11}' -f (50000000000 + $i)
  $telefon = '6{0:D8}' -f $i
  $mail = ('{0}.{1}.{2}@ztb-rental.pl' -f $imie.ToLower(), $nazw.ToLower(), $i)
  $date = DateIso ($startEmp.AddDays($i % 2400))
  $sw.WriteLine("$i,$idOddzial,$idStan,$imie,$nazw,$pesel,$telefon,$mail,$date")
}
$sw.Dispose()

# 8) P_72_KATEGORIA
$kategorie = @('Mini','Economy','Compact','Sedan','Kombi','SUV','Crossover','Van','Premium','Luxury','Electric','Hybrid','Business','Family','Sport')
$sw = New-Writer 'p_72_kategoria.csv'
for ($i = 1; $i -le $counts.p_72_kategoria; $i++) {
  $kat = $kategorie[($i - 1) % $kategorie.Count]
  $stawka = Dec2 (85 + ($i * 6.8))
  $sw.WriteLine("$i,$kat,Segment $kat - wariant $i,$stawka")
}
$sw.Dispose()

# 9) P_72_KOLOR
$kolory = @('Bialy','Czarny','Srebrny','Grafitowy','Niebieski','Granatowy','Czerwony','Bordowy','Zielony','Oliwkowy','Brazowy','Bezowy','Zolty','Pomaranczowy','Fioletowy','Turkusowy','Szary')
$sw = New-Writer 'p_72_kolor.csv'
for ($i = 1; $i -le $counts.p_72_kolor; $i++) {
  $kolor = $kolory[($i - 1) % $kolory.Count]
  $name = if ($i -le $kolory.Count) { $kolor } else { "$kolor Metalic $i" }
  $sw.WriteLine("$i,$name")
}
$sw.Dispose()

# 10) P_72_MARKA
$marki = @('Toyota','Volkswagen','Skoda','Kia','Hyundai','Ford','Opel','Renault','Peugeot','Citroen','Fiat','Nissan','Mazda','Honda','Suzuki','Volvo','BMW','Audi','Mercedes','Dacia','Seat','Cupra','Jeep','Lexus','Mini','Alfa Romeo','Mitsubishi','Subaru','Land Rover','Tesla','Porsche','Jaguar','Chevrolet','Chrysler','Saab','Infiniti','Acura','Smart','DS','Abarth')
$sw = New-Writer 'p_72_marka.csv'
for ($i = 1; $i -le $counts.p_72_marka; $i++) {
  $brand = if ($i -le $marki.Count) { $marki[$i-1] } else { "MarkaAuto $i" }
  $sw.WriteLine("$i,$brand")
}
$sw.Dispose()

# 11) P_72_MODEL
$modelBase = @('Corolla','Yaris','Auris','Golf','Passat','Octavia','Fabia','Ceed','Sportage','Tucson','Focus','Astra','Clio','Megane','208','308','Tipo','Qashqai','CX-5','Civic','V40','X1','A4','C200','Duster','Ateca','Model 3','Model Y','E-Pace','Cayenne')
$sw = New-Writer 'p_72_model.csv'
for ($i = 1; $i -le $counts.p_72_model; $i++) {
  $idMarka = (($i - 1) % $counts.p_72_marka) + 1
  $base = $modelBase[($i - 1) % $modelBase.Count]
  $name = "$base-$i"
  $sw.WriteLine("$i,$name,$idMarka")
}
$sw.Dispose()

# 12) P_72_TYP_PALIWA
$paliwa = @('Benzyna','Diesel','LPG','CNG','Elektryczny','Hybrid','Plug-in Hybrid','Wodor','Biodiesel','Ethanol')
$sw = New-Writer 'p_72_typ_paliwa.csv'
for ($i = 1; $i -le $counts.p_72_typ_paliwa; $i++) {
  $sw.WriteLine("$i,$($paliwa[$i-1])")
}
$sw.Dispose()

# 13) P_72_TYP_SKRZYNI
$skrzynie = @('Manual 5','Manual 6','Automat 6','Automat 8','CVT','DCT')
$sw = New-Writer 'p_72_typ_skrzyni.csv'
for ($i = 1; $i -le $counts.p_72_typ_skrzyni; $i++) {
  $sw.WriteLine("$i,$($skrzynie[$i-1])")
}
$sw.Dispose()

# 14) P_72_SAMOCHOD
$rejPrefix = @('KR','WA','GD','PO','WR','LU','BI','RZ','SC','OP')
$sw = New-Writer 'p_72_samochod.csv'
for ($i = 1; $i -le $counts.p_72_samochod; $i++) {
  $idOddzial = (($i - 1) % $counts.p_72_oddzial) + 1
  $idPaliwa = (($i - 1) % $counts.p_72_typ_paliwa) + 1
  $idKolor = (($i - 1) % $counts.p_72_kolor) + 1
  $idKat = (($i - 1) % $counts.p_72_kategoria) + 1
  $idModel = (($i - 1) % $counts.p_72_model) + 1
  $idSkrz = (($i - 1) % $counts.p_72_typ_skrzyni) + 1
  $rej = '{0}{1:D5}' -f $rejPrefix[($i - 1) % $rejPrefix.Count], $i
  $vin = 'ZTB{0:D14}' -f $i
  $rok = 2010 + ($i % 16)
  $przebieg = 5000 + (($i * 131) % 280000)
  $pojemnosc = 999 + (($i * 11) % 3000)
  $moc = 70 + ($i % 240)
  $sw.WriteLine("$i,$idOddzial,$idPaliwa,$idKolor,$idKat,$idModel,$idSkrz,$rej,$vin,$rok,$przebieg,$pojemnosc,$moc")
}
$sw.Dispose()

# 15) P_72_TYP_UBEZPIECZENIA
$typyUbez = @('OC Basic','OC Plus','AC Standard','AC Premium','Assistance Basic','Assistance Full','NNW Kierowca','NNW Pasazer','Szyby','Opony','Auto Zastepcze','Ochrona Prawna')
$sw = New-Writer 'p_72_typ_ubezpieczenia.csv'
for ($i = 1; $i -le $counts.p_72_typ_ubezpieczenia; $i++) {
  $sw.WriteLine("$i,$($typyUbez[$i-1]),Pakiet $($typyUbez[$i-1])")
}
$sw.Dispose()

# 16) P_72_UBEZPIECZENIE
$sw = New-Writer 'p_72_ubezpieczenie.csv'
$dateStart = [datetime]'2025-01-01'
for ($i = 1; $i -le $counts.p_72_ubezpieczenie; $i++) {
  $idTyp = (($i - 1) % $counts.p_72_typ_ubezpieczenia) + 1
  $nr = 'POL-{0:00000000}' -f $i
  $dOd = $dateStart.AddDays($i % 365)
  $dDo = $dOd.AddDays(365)
  $kwota = Dec2 (10000 + (($i * 59) % 120000))
  $skladka = Dec2 (220 + (($i * 7) % 1900))
  $sw.WriteLine("$i,$idTyp,$nr,$(DateIso $dOd),$(DateIso $dDo),$kwota,$skladka")
}
$sw.Dispose()

# 17) P_72_KLIENT
$sw = New-Writer 'p_72_klient.csv'
$dateReg = [datetime]'2021-01-01'
for ($i = 1; $i -le $counts.p_72_klient; $i++) {
  $isFemale = ($i % 2 -eq 1)
  $imie = if ($isFemale) { $imionaK[($i - 1) % $imionaK.Count] } else { $imionaM[($i - 1) % $imionaM.Count] }
  $nazw = $nazwiska[($i * 3) % $nazwiska.Count]
  $pesel = '{0:D11}' -f (70000000000 + $i)
  $telefon = '7{0:D8}' -f $i
  $mail = ('{0}.{1}.{2}@mail.com' -f $imie.ToLower(), $nazw.ToLower(), $i)
  $dowod = 'ABA{0:000000}' -f $i
  $pj = 'PL{0:0000000}' -f $i
  $kat = @('B','B+E','C','A','D')[($i - 1) % 5]
  $dWaz = DateIso (([datetime]'2030-01-01').AddDays(($i % 1500)))
  $dReg = DateIso ($dateReg.AddDays($i % 1800))
  $sw.WriteLine("$i,$imie,$nazw,$pesel,$telefon,$mail,$dowod,$pj,$kat,$dWaz,$dReg")
}
$sw.Dispose()

# 18) P_72_WYPOZYCZENIA
$statusy = @('NOWE','AKTYWNE','ZAKONCZONE','ANULOWANE')
$sw = New-Writer 'p_72_wypozyczenia.csv'
$wStart = [datetime]'2024-01-01'
for ($i = 1; $i -le $counts.p_72_wypozyczenia; $i++) {
  $idSam = (($i - 1) % $counts.p_72_samochod) + 1
  $idKli = (($i - 1) % $counts.p_72_klient) + 1
  $idWyd = (($i - 1) % $counts.p_72_oddzial) + 1
  $idOdb = ($i % $counts.p_72_oddzial) + 1
  $idUbez = (($i - 1) % $counts.p_72_ubezpieczenie) + 1
  $idPO = (($i - 1) % $counts.p_72_pracownik) + 1
  $idPW = ($i % $counts.p_72_pracownik) + 1
  $status = $statusy[($i - 1) % $statusy.Count]
  $wyd = $wStart.AddDays($i % 700)
  $plan = $wyd.AddDays(2 + ($i % 10))
  $fakt = if ($status -eq 'ZAKONCZONE') { DateIso ($plan.AddDays($i % 3)) } else { '' }
  $kosztT = Dec2 ( ($i * 3) % 650 )
  $pStart = 10000 + (($i * 97) % 210000)
  $pFin = if ($status -eq 'ZAKONCZONE') { $pStart + (40 + ($i % 600)) } else { '' }
  $pLimit = 400 + (($i * 9) % 2400)
  $cDoba = Dec2 (95 + (($i * 2) % 330))
  $rabat = Dec2 (($i % 25))
  $kaucja = Dec2 (500 + (($i * 13) % 2500))
  $uwagi = "Rezerwacja $i"
  $sw.WriteLine("$idSam,$idKli,$idWyd,$idOdb,$idUbez,$idPO,$idPW,$status,$uwagi,$(DateIso $wyd),$(DateIso $plan),$fakt,$kosztT,$pStart,$pFin,$pLimit,$cDoba,$rabat,$kaucja")
}
$sw.Dispose()

$total = ($counts.Values | Measure-Object -Sum).Sum
Write-Host "Generated CSV files in: $outDir"
Write-Host "Total rows across all tables: $total"
($counts.GetEnumerator() | ForEach-Object { '{0},{1}' -f $_.Key, $_.Value }) | Set-Content -Path (Join-Path $outDir 'counts_expected.csv') -Encoding utf8
