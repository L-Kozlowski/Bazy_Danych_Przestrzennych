# CHANGELOG
# DATA UTOWRZENIA/SKOŃCZENIA 12 12 2021r
# OPIS:
# Skrytpt pobiera ze strony agh  plik Customers_Nov2021.zip
# rozpakowuje go oraz porownuje z pobranym manualnie plikiem Customers_old.csv
# zduplikowane wiersze odrzuca do pliku Customers_Nov2021.bad_${TIMESTAMP}. 
# tworzy nową baze w postgresie z nową tabela 
# zweryfikowana tabele bez duplikatów przenosi do katalogu PROCESSED dodając prefix ${TIMESTAMP}_ i uzupełnia rekordy w nowo powstałej tabeli w postgresie 
# wysyła raportującego maila o nazwie CUSTOMERS LOAD - ${TIMESTAMP}
# uruchamia kwerende która wyszukuje klientów w promieniu 50 km od zadanego punktu i zapisuje do nowej tabeli BEST_CUSTOMERS_${NUMERINDEKSU},
# tabele BEST_CUSTOMERS_${NUMERINDEKSU} eksportuje do csv, pakuje a następnie wysyła maila z załączoną spakowaną tabelą
# Po każdym kroku do pliku log w katalogu  PROCESSED jest zapisywana linijka informująca o wykonaniu zadania


# -----------------------inicjowanie zmiennych----------------------

$mypath = split-Path $MyInvocation.MyCommand.Path -Parent

cd $mypath

$TIMESTAMP  = Get-Date
$TIMESTAMP = $TIMESTAMP.ToString("MMddyyyy")
$numer_indexu = 401715
$adres = "https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip"
$log = "cw8_$TIMESTAMP.log"
$haslo = "agh"
$sql_username = "postgres"
$sql_hostname = "localhost"
$sql_haslo  = "1234"
$env:PGPASSWORD="$sql_haslo";
$prywatne_haslo_email = "NALEŻY ZMIENIĆ NA SWOEJ HASLO"
$nadawca = “lukiko321@gmail.com”
$odbiorca = “lukiko321@gmail.com”
$serwer_smtp = “smtp.gmail.com”


# -----------------------pobranie pliku----------------------

Invoke-WebRequest -Uri "$adres"  -OutFile  "$mypath\Customers_Nov2021.zip"

if(!(Test-Path -Path "./PROCESSED")){
New-Item  -Name "PROCESSED" -ItemType "directory" 
}

New-Item -Type file -Path "./PROCESSED/$log" -Force

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - Download Step - Successful" > "./PROCESSED/$log "


# -----------------------rozpakowanie pliku-----------------------

Expand-7Zip -ArchiveFileName "$mypath\Customers_Nov2021.zip" -Password "$haslo" -TargetPath "$mypath"
$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - Expand-7Zip Step - Successful" >> "./PROCESSED/$log "


#-----------------------walidacja-----------------------

$cust_new = Import-Csv -Path .\Customers_Nov2021.csv
$cust_old = Import-Csv -Path .\Customers_old.csv
$lenght_new = ($cust_new | Measure-Object).Count
$lenght_old = ($cust_old | Measure-Object).Count

$new_arr = @()

"" > Customers_Nov2021.bad_$TIMESTAMP
for (($i = 0); $i -lt $lenght_new; $i++)
{
$warunek = $true
    for (($j = 0); $j -lt $lenght_old; $j++)
    {
        if ($cust_new[$i].email -eq  $cust_old[$j].email)
        {
            $cust_new[$i] >> Customers_Nov2021.bad_$TIMESTAMP
            $warunek = $false
        }
    }
    if ($warunek){
        $new_arr = $new_arr + $cust_new[$i]
    }
    
}
$lenght_new_arr = ($new_arr | Measure-Object).Count
$lenght_duplicate = $lenght_new - $lenght_new_arr

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - validation - Successful" >> "./PROCESSED/$log "


# -----------------------tworzenie nowej tabeli i bazy danych -----------------------

 psql -d postgres -U "$sql_username" --host="$sql_hostname" --port=5432 ` -c "drop database IF EXISTS postgresql"

 psql -d postgres -U "$sql_username" --host="$sql_hostname" --port=5432 `
--command='CREATE DATABASE postgresql;' `
--command='\c postgresql' `
--command='CREATE TABLE IF NOT EXISTS customers_401715(first_name VARCHAR(50), last_name VARCHAR(50), email VARCHAR(200), lat FLOAT, long FLOAT);'

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - Crete table - Successful" >> "./PROCESSED/$log "


# ----------------------- ładowanie danch do tabeli -----------------------

for (($i = 0); $i -lt $lenght_new_arr; $i++)
{
    $name = "'" +  $new_arr[$i].first_name + "'"
    $last =  "'" + $new_arr[$i].last_name  + "'"
    $email = "'" + $new_arr[$i].email + "'" 
    $lat  =  $new_arr[$i].lat
    $lon = $new_arr[$i].long
    psql -d postgresql -U "$sql_username" --host="$sql_hostname" --port=5432 `
    -c "INSERT INTO customers_401715(first_name, last_name, email, lat, long) VALUES($name,$last, $email, $lat, $lon)" 
    }

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - input into table - Successful" >> "./PROCESSED/$log "


# -----------------------przeniesienie przetworzonego pliku-----------------------

$new_arr > PROCESSED/${TIMESTAMP}_Customers_Nov2021.csv
$new_arr | Export-Csv -Path "PROCESSED/${TIMESTAMP}_Customers_Nov2021.csv"  -NoTypeInformation 

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - crete csv after validation - Successful" >> "./PROCESSED/$log "


# -----------------------wylanie maila-----------------------

$temat = "CUSTOMERS LOAD - $TIMESTAMP"
$tresc = “liczba wierszy w pliku pobranym z internetu: $lenght_new
liczba poprawnych wierszy (po czyszczeniu): $lenght_new_arr
liczba duplikatów w pliku wejściowym: $lenght_duplicate
ilość danych załadowanych do tabeli CUSTOMERS_$numer_indexu.”

$Message = new-object Net.Mail.MailMessage 
$smtp = new-object Net.Mail.SmtpClient("$serwer_smtp", 587) 
$smtp.Credentials = New-Object System.Net.NetworkCredential("$nadawca", "$prywatne_haslo_email"); 
$smtp.EnableSsl = $true 
$smtp.Timeout = 400000  
$Message.From = "$nadawca" 
$Message.To.Add("$odbiorca") 
$Message.Subject = "$temat"
$Message.Body = "$tresc"
$smtp.Send($Message)

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - send email - Successful" >> "./PROCESSED/$log "


# ----------------------- uruchomienie kwerendy-----------------------

$kwerenda = "CREATE TABLE BEST_CUSTOMERS_$numer_indexu AS
SELECT *
FROM customers_$numer_indexu as c
WHERE
		ST_DistanceSpheroid( 
			ST_Point( 41.39988501005976, -75.67329768604034 ), 
			ST_POINT(c.lat, c.long),
			'SPHEROID[`"WGS 84`",6378137,298.257223563]')*0.0003048 < 50"
 

New-Item -Type file -Value $kwerenda -Path "./zapytanie.sql" -Force

psql -d postgresql -U "$sql_username" --host="$sql_hostname" --port=5432 ` -c "CREATE EXTENSION postgis" 


psql -d postgresql -U "$sql_username" --host="$sql_hostname" --port=5432 --file="zapytanie.sql" 


$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - new table BEST_CUSTOMERS_$numer_indexu  - Successful" >> "./PROCESSED/$log "


# i-----------------------	wyeksportuje zawartość tabeli BEST_CUSTOMERS_${NUMERINDEKSU} -----------------------

$BEST_CUSTOMERS =  psql -d postgresql -U "$sql_username" --host="$sql_hostname" --port=5432 ` -c "SELECT * FROM BEST_CUSTOMERS_$numer_indexu" 

$bst_lenght = $BEST_CUSTOMERS.Length 


$array = @()
for (($i = 2); $i -lt $bst_lenght - 2 ; $i++)
{
$object = New-Object -TypeName PSObject
$object | Add-Member -Name 'first_name' -MemberType Noteproperty -Value  $BEST_CUSTOMERS[$i].Split( "|")[0].replace(" ", "")
$object | Add-Member -Name 'last_name' -MemberType Noteproperty -Value  $BEST_CUSTOMERS[$i].Split( "|")[1].replace(" ", "")
$object | Add-Member -Name 'email' -MemberType Noteproperty -Value  $BEST_CUSTOMERS[$i].Split( "|")[2].replace(" ", "")
$object | Add-Member -Name 'lat' -MemberType Noteproperty -Value  $BEST_CUSTOMERS[$i].Split( "|")[3].replace(" ", "")
$object | Add-Member -Name 'long' -MemberType Noteproperty -Value  $BEST_CUSTOMERS[$i].Split( "|")[4].replace(" ", "")
$array += $object
}

$array | Export-Csv -Path "BEST_CUSTOMERS_$numer_indexu.csv "  -NoTypeInformation 

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - export BEST_CUSTOMERS_$numer_indexu to csv  - Successful" >> "./PROCESSED/$log "


# j.-----------------------	skompresuje wyeksportowany plik csv-----------------------

Compress-Archive -Path  "BEST_CUSTOMERS_$numer_indexu.csv " -DestinationPath "./BEST_CUSTOMERS_$numer_indexu" -Force;

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - Compress-Archive BEST_CUSTOMERS_$numer_indexu  - Successful" >> "./PROCESSED/$log "


# -----------------------wylanie maila-----------------------

$ilosc_wierszy = $array.Length
$temat = "BEST_CUSTOMERS_$numer_indexu - $TIMESTAMP"
$tresc = “Data utworzenia: $TIMESTAMP,
ilosć wierszy: $ilosc_wierszy”

$Message = new-object Net.Mail.MailMessage 
$smtp = new-object Net.Mail.SmtpClient("$serwer_smtp", 587) 
$smtp.Credentials = New-Object System.Net.NetworkCredential("$nadawca", "$prywatne_haslo_email"); 
$smtp.EnableSsl = $true 
$smtp.Timeout = 400000  
$Message.From = "$nadawca" 
$Message.To.Add("$odbiorca") 
$Message.Attachments.Add("$pwd\BEST_CUSTOMERS_$numer_indexu.zip") 
$Message.Subject = "$temat"
$Message.Body = "$tresc"
$smtp.Send($Message)

$date = Get-Date –format ‘dd_MM_yyyy-HH_mm_ss’
$date + " - send email - Successful" >> "./PROCESSED/$log "

