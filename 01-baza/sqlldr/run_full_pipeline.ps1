$ErrorActionPreference = 'Stop'

$container = 'ztb-oracle-db'
$user = 'system'
$password = 'ZtbOracle123!'
$service = 'FREE'
$sqlldr = '/opt/oracle/product/26ai/dbhomeFree/bin/sqlldr'

$baseDir = $PSScriptRoot
$reportDir = Join-Path $baseDir 'report'
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

$csvDir = Join-Path $baseDir 'csv'
$ctlDir = Join-Path $baseDir 'ctl'

$containerBase = '/tmp/sqlldr'
$containerSql = "$containerBase/sql"
$containerReport = "$containerBase/report"
$containerCsv = "$containerBase/csv"
$containerCtl = "$containerBase/ctl"
$containerLog = "$containerBase/log"

$order = @(
  'p_72_panstwo',
  'p_72_wojewodztwo',
  'p_72_miasto',
  'p_72_ulica',
  'p_72_oddzial',
  'p_72_stanowisko',
  'p_72_pracownik',
  'p_72_kategoria',
  'p_72_kolor',
  'p_72_marka',
  'p_72_model',
  'p_72_typ_paliwa',
  'p_72_typ_skrzyni',
  'p_72_samochod',
  'p_72_typ_ubezpieczenia',
  'p_72_ubezpieczenie',
  'p_72_klient',
  'p_72_wypozyczenia'
)

$cleanupSql = @"
DELETE FROM p_72_wypozyczenia;
DELETE FROM p_72_samochod;
DELETE FROM p_72_pracownik;
DELETE FROM p_72_oddzial;
DELETE FROM p_72_ulica;
DELETE FROM p_72_miasto;
DELETE FROM p_72_wojewodztwo;
DELETE FROM p_72_panstwo;
DELETE FROM p_72_model;
DELETE FROM p_72_marka;
DELETE FROM p_72_kategoria;
DELETE FROM p_72_kolor;
DELETE FROM p_72_typ_paliwa;
DELETE FROM p_72_typ_skrzyni;
DELETE FROM p_72_ubezpieczenie;
DELETE FROM p_72_typ_ubezpieczenia;
DELETE FROM p_72_stanowisko;
DELETE FROM p_72_klient;
COMMIT;
EXIT;
"@

$reportSql = @"
SET FEEDBACK OFF
SET MARKUP CSV ON DELIMITER , QUOTE ON
SPOOL /tmp/sqlldr/report/counts_actual.csv
SELECT 'P_72_PANSTWO' AS tabela, COUNT(*) AS cnt FROM p_72_panstwo
UNION ALL SELECT 'P_72_WOJEWODZTWO', COUNT(*) FROM p_72_wojewodztwo
UNION ALL SELECT 'P_72_MIASTO', COUNT(*) FROM p_72_miasto
UNION ALL SELECT 'P_72_ULICA', COUNT(*) FROM p_72_ulica
UNION ALL SELECT 'P_72_ODDZIAL', COUNT(*) FROM p_72_oddzial
UNION ALL SELECT 'P_72_STANOWISKO', COUNT(*) FROM p_72_stanowisko
UNION ALL SELECT 'P_72_PRACOWNIK', COUNT(*) FROM p_72_pracownik
UNION ALL SELECT 'P_72_KATEGORIA', COUNT(*) FROM p_72_kategoria
UNION ALL SELECT 'P_72_KOLOR', COUNT(*) FROM p_72_kolor
UNION ALL SELECT 'P_72_MARKA', COUNT(*) FROM p_72_marka
UNION ALL SELECT 'P_72_MODEL', COUNT(*) FROM p_72_model
UNION ALL SELECT 'P_72_TYP_PALIWA', COUNT(*) FROM p_72_typ_paliwa
UNION ALL SELECT 'P_72_TYP_SKRZYNI', COUNT(*) FROM p_72_typ_skrzyni
UNION ALL SELECT 'P_72_SAMOCHOD', COUNT(*) FROM p_72_samochod
UNION ALL SELECT 'P_72_TYP_UBEZPIECZENIA', COUNT(*) FROM p_72_typ_ubezpieczenia
UNION ALL SELECT 'P_72_UBEZPIECZENIE', COUNT(*) FROM p_72_ubezpieczenie
UNION ALL SELECT 'P_72_KLIENT', COUNT(*) FROM p_72_klient
UNION ALL SELECT 'P_72_WYPOZYCZENIA', COUNT(*) FROM p_72_wypozyczenia
ORDER BY tabela;
SPOOL OFF

SPOOL /tmp/sqlldr/report/total_rows.csv
SELECT
  (SELECT COUNT(*) FROM p_72_panstwo)+
  (SELECT COUNT(*) FROM p_72_wojewodztwo)+
  (SELECT COUNT(*) FROM p_72_miasto)+
  (SELECT COUNT(*) FROM p_72_ulica)+
  (SELECT COUNT(*) FROM p_72_oddzial)+
  (SELECT COUNT(*) FROM p_72_stanowisko)+
  (SELECT COUNT(*) FROM p_72_pracownik)+
  (SELECT COUNT(*) FROM p_72_kategoria)+
  (SELECT COUNT(*) FROM p_72_kolor)+
  (SELECT COUNT(*) FROM p_72_marka)+
  (SELECT COUNT(*) FROM p_72_model)+
  (SELECT COUNT(*) FROM p_72_typ_paliwa)+
  (SELECT COUNT(*) FROM p_72_typ_skrzyni)+
  (SELECT COUNT(*) FROM p_72_samochod)+
  (SELECT COUNT(*) FROM p_72_typ_ubezpieczenia)+
  (SELECT COUNT(*) FROM p_72_ubezpieczenie)+
  (SELECT COUNT(*) FROM p_72_klient)+
  (SELECT COUNT(*) FROM p_72_wypozyczenia) AS total_rows
FROM dual;
SPOOL OFF
EXIT;
"@

$cleanupPath = Join-Path $baseDir 'cleanup_all.sql'
$reportPath = Join-Path $baseDir 'report_counts.sql'

[System.IO.File]::WriteAllText($cleanupPath, $cleanupSql, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText($reportPath, $reportSql, [System.Text.UTF8Encoding]::new($false))

try {
  Write-Host 'Generating CSV dataset...'
  & (Join-Path $baseDir 'generate_all_csv.ps1')

  Write-Host 'Preparing container SQL/report directories...'
  docker exec $container bash -lc "mkdir -p $containerSql $containerReport $containerCsv $containerCtl $containerLog"

  Write-Host 'Preparing control files...'
  & (Join-Path $baseDir 'generate_all_ctl.ps1')

  Write-Host 'Copying SQL helper scripts...'
  docker cp $cleanupPath "$container`:$containerSql/cleanup_all.sql"
  docker cp $reportPath "$container`:$containerSql/report_counts.sql"

  Write-Host 'Copying CSV files to container...'
  Get-ChildItem -Path $csvDir -Filter '*.csv' -File | ForEach-Object {
    if ($_.Name -ne 'counts_expected.csv') {
      $tmp = [System.IO.Path]::GetTempFileName()
      $raw = [System.IO.File]::ReadAllText($_.FullName)
      [System.IO.File]::WriteAllText($tmp, $raw.Replace("`r`n", "`n"), [System.Text.UTF8Encoding]::new($false))
      docker cp $tmp "$container`:$containerCsv/$($_.Name)"
      Remove-Item $tmp -Force
    }
  }

  Write-Host 'Copying CTL files to container...'
  Get-ChildItem -Path $ctlDir -Filter '*.ctl' -File | ForEach-Object {
    docker cp $_.FullName "$container`:$containerCtl/$($_.Name)"
  }

  Write-Host 'Cleaning target tables...'
  docker exec $container bash -lc "sqlplus -s $user/$password@$service @$containerSql/cleanup_all.sql"
  if ($LASTEXITCODE -ne 0) {
    throw "Cleanup failed (exit code $LASTEXITCODE)."
  }

  Write-Host 'Running SQL*Loader for all tables...'
  foreach ($name in $order) {
    Write-Host "Loading $name ..."
    docker exec $container bash -lc "NLS_NUMERIC_CHARACTERS='.,' $sqlldr $user/$password@$service control=$containerCtl/$name.ctl log=$containerLog/$name.log bad=$containerLog/$name.bad"
    if ($LASTEXITCODE -ne 0) {
      throw "SQL*Loader failed for $name (exit code $LASTEXITCODE). Check $containerLog/$name.log"
    }
  }

  Write-Host 'Generating CSV verification report...'
  docker exec $container bash -lc "sqlplus -s $user/$password@$service @$containerSql/report_counts.sql"
  if ($LASTEXITCODE -ne 0) {
    throw "Report generation failed (exit code $LASTEXITCODE)."
  }

  Write-Host 'Copying report files to workspace...'
  docker cp "$container`:$containerReport/counts_actual.csv" (Join-Path $reportDir 'counts_actual.csv')
  docker cp "$container`:$containerReport/total_rows.csv" (Join-Path $reportDir 'total_rows.csv')

  Write-Host 'Pipeline completed successfully.'
  Write-Host ('Report: ' + (Join-Path $reportDir 'counts_actual.csv'))
  Write-Host ('Report: ' + (Join-Path $reportDir 'total_rows.csv'))
}
finally {
  if (Test-Path $cleanupPath) { Remove-Item $cleanupPath -Force }
  if (Test-Path $reportPath) { Remove-Item $reportPath -Force }
}
