# Pełny przewodnik po ExifTool i PowerShell

Za każdym razem, gdy robisz zdjęcie, aparat zapisuje w pliku nie tylko sam obraz, ale także informacje serwisowe: model aparatu i obiektywu, datę i godzinę wykonania zdjęcia, czas naświetlania, przysłonę, ISO, współrzędne GPS. Dane te nazywane są **EXIF (Exchangeable Image File Format)**.

Chociaż PowerShell ma wbudowane narzędzia do odczytu niektórych metadanych, są one ograniczone. Aby uzyskać dostęp do **wszystkich** informacji, potrzebne jest specjalistyczne narzędzie. W tym artykule używam **ExifTool**.

**ExifTool** to darmowe, wieloplatformowe narzędzie o otwartym kodzie źródłowym, napisane przez Phila Harveya. Jest to złoty standard do odczytu, zapisu i edycji metadanych w szerokiej gamie formatów plików (obrazy, audio, wideo, PDF itp.). ExifTool zna tysiące tagów od setek producentów urządzeń, co czyni go najbardziej wszechstronnym narzędziem w swojej klasie.

### Pobieranie i prawidłowa konfiguracja

Zanim zaczniesz pisać kod, musisz przygotować samo narzędzie.

1.  Przejdź na **oficjalną stronę ExifTool: [https://exiftool.org/](https://exiftool.org/)**. Na stronie głównej znajdź i pobierz **"Windows Executable"**.

2.  **Zmiana nazwy (Krok krytyczny!):** Pobrany plik będzie nosił nazwę `exiftool(-k).exe`. To nie przypadek.

Zmień jego nazwę na **`exiftool.exe`**, aby **wyłączyć tryb "pauzy"**, który jest przeznaczony dla użytkowników uruchamiających program podwójnym kliknięciem myszy.
>

3.  **Przechowywanie:** Masz dwie główne opcje przechowywania `exiftool.exe`.
    *   **Opcja 1 (Prosta): W tym samym folderze co Twój skrypt.** To najłatwiejsza droga. Twój skrypt PowerShell zawsze będzie mógł znaleźć narzędzie, ponieważ znajduje się obok. Idealne dla przenośnych skryptów, które przenosisz z komputera na komputer.
    *   **Opcja 2 (Zalecana do częstego użytku): W folderze ze zmiennej systemowej `PATH`.** Zmienna `PATH` — to lista katalogów, w których Windows i PowerShell automatycznie szukają plików wykonywalnych.
    Możesz utworzyć folder (np. `C:\Tools`), umieścić tam `exiftool.exe` i dodać `C:\Tools` do zmiennej systemowej `PATH`.
    Następnie będziesz mógł wywoływać `exiftool.exe` z dowolnego folderu w dowolnej konsoli.


Skrypty do dodania do $PATH:
Dodawanie katalogu do PATH dla OBECNEGO UŻYTKOWNIKA
Dodawanie katalogu do SYSTEMOWEGO PATH dla WSZYSTKICH UŻYTKOWNIKÓW

---

## PowerShell i programy zewnętrzne

Aby skutecznie korzystać z ExifTool, musisz wiedzieć, jak PowerShell uruchamia zewnętrzne pliki `.exe`.
Prawidłowym i najbardziej niezawodnym sposobem uruchamiania programów zewnętrznych jest **operator wywołania `&` (ampersand)**.
PowerShell zgłosi błąd, jeśli ścieżka do programu zawiera spacje. Na przykład `C:\My Tools\exiftool.exe`.
`&` (ampersand)** mówi PowerShell: "Tekst, który następuje po mnie w cudzysłowach, to ścieżka do pliku wykonywalnego. Uruchom go, a wszystko, co następuje dalej, to jego argumenty".

```powershell
# Prawidłowa składnia
& "C:\Path With Spaces\program.exe" "argument 1" "argument 2"
```

Zawsze używaj `&`, gdy pracujesz ze ścieżkami do programów w zmiennych lub ścieżkami, które mogą zawierać spacje.

---

## Praktyczne sztuczki: ExifTool + PowerShell

Teraz połączmy naszą wiedzę.

### Przykład nr 1: Podstawowe wyodrębnianie i interaktywny podgląd

Najprostszym sposobem na uzyskanie wszystkich danych ze zdjęcia i ich zbadanie jest zażądanie ich w formacie JSON i przekazanie do `Out-ConsoleGridView`.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. Uruchamiamy exiftool z przełącznikiem -json dla ustrukturyzowanego wyjścia
# 2. Konwertujemy tekst JSON na obiekt PowerShell
#    Wywołujemy exiftool.exe bezpośrednio, bez zmiennej i operatora wywołania &.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 3. Przekształcamy "szeroki" obiekt w wygodną tabelę "Parametr-Wartość"
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 4. Wyświetlamy wynik w interaktywnym oknie do analizy
$reportData | Out-ConsoleGridView -Title "Metadane pliku: $($photoPath | Split-Path -Leaf)"
```

Ten kod otworzy interaktywne okno, w którym będziesz mógł sortować dane według nazwy parametru lub wartości, a także filtrować je, po prostu zaczynając wpisywać tekst. Jest to niezwykle wygodne do szybkiego wyszukiwania potrzebnych informacji.

### Przykład nr 2: Tworzenie czystego raportu i wysyłanie na różne "urządzenia"

`Out-ConsoleGridView` to dopiero początek. Przetworzone dane możesz wysłać w dowolne miejsce, używając innych cmdletów `Out-*`.

Załóżmy, że mamy dane w zmiennej `$reportData` z poprzedniego przykładu.

#### **A) Wysyłanie do pliku CSV dla Excela**
```powershell
$reportData | Export-Csv -Path "C:\Reports\photo_exif.csv" -NoTypeInformation -Encoding UTF8
```
Polecenie `Export-Csv` tworzy idealnie ustrukturyzowany plik, który można otworzyć w Excelu lub Arkuszach Google.

#### **B) Wysyłanie do pliku tekstowego**
```powershell
# Aby uzyskać ładne formatowanie, najpierw użyj Format-Table
$reportData | Format-Table -AutoSize | Out-File -FilePath "C:\Reports\photo_exif.txt"
```
Polecenie `Out-File` zapisze do pliku dokładną tekstową kopię tego, co widzisz w konsoli.

#### **C) Wysyłanie do schowka**
Chcesz szybko wkleić dane do wiadomości e-mail lub czatu? Użyj `Out-Clipboard`.
```powershell
$reportData | Format-Table -AutoSize | Out-String | Out-Clipboard
```

Teraz możesz nacisnąć `Ctrl+V` w dowolnym edytorze tekstu i wkleić starannie sformatowaną tabelę.

### Przykład nr 3: Uzyskiwanie konkretnych danych do wykorzystania w skrypcie

Często nie potrzebujesz całego raportu, a jedynie jednej lub dwóch wartości. Ponieważ `$exifObject` jest zwykłym obiektem PowerShell, możesz łatwo odwoływać się do jego właściwości.

```powershell

$photoPath = "D:\Photos\IMG_1234.JPG"

# Wywołujemy exiftool.exe bezpośrednio po nazwie.
# PowerShell automatycznie znajdzie go w jednym z folderów wymienionych w PATH.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 1. Tworzymy jeden obiekt PowerShell z czytelnymi nazwami właściwości.
#    To podobne do tworzenia ustrukturyzowanego rekordu.
$reportObject = [PSCustomObject]@{
    "Kamera"           = $exifObject.Model
    "Data wykonania"      = $exifObject.DateTimeOriginal
    "Czułość" = $exifObject.ISO
    "Nazwa pliku"        = $exifObject.FileName # Dodaj nazwę pliku dla kontekstu
}

# 2. Wyświetlamy ten obiekt w interaktywnym oknie.
#    Out-GridView automatycznie utworzy kolumny z nazw właściwości.
$reportObject | Out-ConsoleGridView -Title "Metadane pliku: $($photoPath | Split-Path -Leaf)"
```

To podejście jest podstawą każdej poważnej automatyzacji, takiej jak zmiana nazw plików na podstawie daty wykonania zdjęcia, sortowanie zdjęć według modelu aparatu lub dodawanie znaków wodnych z informacjami o czasie naświetlania.

### Przykład nr 4: Zbiorcze wyodrębnianie metadanych z folderu

Czasami trzeba przeanalizować nie jedno zdjęcie, ale cały folder z obrazami.

```powershell
# Podaj tylko folder ze zdjęciami.
$photoFolder = "D:\Photos"

# Wywołujemy exiftool.exe bezpośrednio. Zmienna dla ścieżki i operator & nie są potrzebne.
$allExif = exiftool.exe -json "$photoFolder\*.jpg" | ConvertFrom-Json

# Przekształcamy w wygodną formę
$report = foreach ($photo in $allExif) {
    [PSCustomObject]@{
        # --- Podstawowe dane o pliku i aparacie ---
        FileName       = $photo.FileName
        DateTime       = $photo.DateTimeOriginal
        CameraMake     = $photo.Make                 # Producent (np. "Canon", "SONY")
        CameraModel    = $photo.Model                 # Model aparatu (np. "EOS R5")
        LensModel      = $photo.LensID                # Pełna nazwa modelu obiektywu
        
        # --- Parametry fotografowania (ekspozycja) ---
        ISO            = $photo.ISO
        ShutterSpeed   = $photo.ShutterSpeed
        Aperture       = $photo.Aperture
        FocalLength    = $photo.FocalLength           # Ogniskowa (np. "50.0 mm")
        ExposureMode   = $photo.ExposureProgram       # Tryb fotografowania (np. "Manual", "Aperture Priority")
        Flash          = $photo.Flash                 # Informacje o tym, czy lampa błyskowa zadziałała
        
        # --- GPS i dane obrazu ---
        GPSPosition    = $photo.GPSPosition           # Współrzędne GPS w postaci jednego ciągu (jeśli istnieją)
        Dimensions     = "$($photo.ImageWidth)x$($photo.ImageHeight)" # Rozmiary obrazu w pikselach
    }
}

# Wyświetlamy dane w interaktywnej tabeli w KONSOLI
$report | Out-ConsoleGridView -Title "Raport zbiorczy dla folderu: $photoFolder"
```

💡 Otrzymujesz schludną tabelę dla całego folderu od razu.

---

### Przykład nr 5: Rekurencyjne wyszukiwanie w podfolderach

ExifTool potrafi sam wyszukiwać pliki we wszystkich podfolderach, używając przełącznika `-r`.

```powershell
& $exifToolPath -r -json "D:\Photos" | ConvertFrom-Json |
    Select-Object FileName, Model, DateTimeOriginal |
    Export-Csv "C:\Reports\all_photos_recursive.csv" -NoTypeInformation -Encoding UTF8
```

---

### Przykład nr 6: Zmiana nazw plików według daty wykonania zdjęcia

Jest to jeden z najpopularniejszych scenariuszy automatyzacji — pliki otrzymują nazwy według daty/godziny wykonania zdjęcia.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# Zmień nazwę na format RRRR-MM-DD_GG-MM-SS.jpg
& $exifToolPath -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```

💡 *ExifTool automatycznie wstawi rozszerzenie oryginalnego pliku za pomocą `%%e`.*

---

### Przykład nr 7: Wyodrębnianie tylko współrzędnych GPS

Przydatne, jeśli chcesz zbudować mapę na podstawie swoich zdjęć.

```powershell
# 1. Podaj ścieżkę do folderu ze zdjęciami
$photoFolder = "E:\DCIM\Camera"

# 2. Wymień tagi, których potrzebujemy: nazwa pliku i trzy tagi GPS.
#    To sprawia, że zapytanie jest znacznie szybsze, niż gdybyśmy pobierali wszystkie tagi.
$tagsToExtract = @(
    "-SourceFile", # SourceFile jest lepsze niż FileName, ponieważ zazwyczaj zawiera pełną ścieżkę
    "-GPSLatitude",
    "-GPSLongitude",
    "-GPSAltitude"
)

# 3. Wywołujemy exiftool.exe bezpośrednio (ponieważ jest w PATH).
#    Przełącznik -r wyszukuje pliki we wszystkich podfolderach.
#    Wynik od razu konwertujemy z JSON.
$allExifData = exiftool.exe -r -json $tagsToExtract $photoFolder | ConvertFrom-Json

# 4. Filtrujemy wyniki: pozostawiamy TYLKO te obiekty, które mają szerokość i długość geograficzną.
$filesWithGps = $allExifData | Where-Object { $_.GPSLatitude -and $_.GPSLongitude }

# 5. Sprawdzamy, czy w ogóle znaleziono pliki z danymi GPS
if ($filesWithGps) {
    # 6. Tworzymy ładny raport z przefiltrowanych danych.
    #    Używamy Select-Object do zmiany nazw kolumn i formatowania.
    $report = $filesWithGps | Select-Object @{Name="Nazwa pliku"; Expression={Split-Path $_.SourceFile -Leaf}},
                                             @{Name="Szerokość geograficzna"; Expression={$_.GPSLatitude}},
                                             @{Name="Długość geograficzna"; Expression={$_.GPSLongitude}},
                                             @{Name="Wysokość"; Expression={if ($_.GPSAltitude) { "$($_.GPSAltitude) m" } else { "N/A" }}}
    
    # 7. Wyświetlamy końcowy raport w interaktywnej tabeli konsoli.
    $report | Out-ConsoleGridView -Title "Pliki z danymi GPS w folderze: $photoFolder"

} else {
    # Jeśli nic nie znaleziono, uprzejmie o tym informujemy.
    Write-Host "Nie znaleziono plików z danymi GPS w folderze '$photoFolder'." -ForegroundColor Yellow
}
```

---

### Przykład nr 8: Masowe usuwanie wszystkich danych GPS (dla prywatności)

```powershell
# Usuń wszystkie tagi GPS z JPG i PNG
& $exifToolPath -r -overwrite_original -gps:all= "D:\Photos"
```

💡 *Ta operacja jest nieodwracalna, dlatego przed jej wykonaniem wykonaj kopię zapasową.*

---

### Przykład nr 9: Konwersja czasu wykonania zdjęcia na czas lokalny

Czasami zdjęcia są robione w innej strefie czasowej. ExifTool może przesunąć datę.

```powershell
# Przesuń czas o +3 godziny
& $exifToolPath "-AllDates+=3:0:0" "D:\Photos\IMG_*.JPG"
```

---

### Przykład nr 10: Uzyskiwanie listy wszystkich unikalnych modeli aparatów w folderze

```powershell
$models = & $exifToolPath -r -Model -s3 "D:\Photos" | Sort-Object -Unique
$models | ForEach-Object { Write-Host "Model: $_" }
```

---

### Przykład nr 11: Wyświetlanie tylko potrzebnych tagów w formie tabelarycznej

```powershell
& $exifToolPath -T -Model -DateTimeOriginal -ISO -Aperture -ShutterSpeed "D:\Photos\IMG_1234.JPG"
```

`-T` wyświetla dane w formacie tabelarycznym, oddzielone tabulatorami — wygodne do dalszej obróbki.

---

### Przykład nr 12: Sprawdzanie obecności GPS w dużej tablicy plików

```powershell
$files = & $exifToolPath -r -if "$gpslatitude" -p '$FileName' "D:\Photos"
Write-Host "Pliki z GPS:"
$files
```

---

### Przykład nr 13: Kopiowanie metadanych z jednego pliku do drugiego

```powershell
# 1. Wybierz plik referencyjny
$sourceFile = Get-ChildItem "D:\Photos" -Filter "*.jpg" | Out-ConsoleGridView -Title "Wybierz PLIK REFERENCYJNY"

# 2. Jeśli plik referencyjny został wybrany, wybierz pliki docelowe
if ($sourceFile) {
    $targetFiles = Get-ChildItem "D:\Photos\New" -Filter "*.jpg" | Out-ConsoleGridView -Title "Wybierz PLIKI DOCELOWE do kopiowania metadanych" -OutputMode Multiple
    
    # 3. Jeśli cele zostały wybrane, wykonaj kopiowanie
    if ($targetFiles) {
        & exiftool.exe -TagsFromFile $sourceFile.FullName ($targetFiles.FullName)
        Write-Host "Metadane skopiowane z $($sourceFile.Name) do $($targetFiles.Count) plików."
    }
}
```

---

### Przykład nr 14: Zapisywanie oryginalnych metadanych do oddzielnego pliku JSON przed zmianą

```powershell
$backupPath = "C:\Reports\metadata_backup.json"
& $exifToolPath -r -json "D:\Photos" | Out-File -Encoding UTF8 $backupPath
```

---

### Przykład nr 15: Użycie PowerShell do automatycznego sortowania zdjęć według daty

```powershell
$photos = Get-ChildItem "D:\Photos" -Filter *.jpg -Recurse
foreach ($photo in $photos) {
    $meta = & $exifToolPath -json $photo.FullName | ConvertFrom-Json
    $date = Get-Date $meta.DateTimeOriginal -ErrorAction SilentlyContinue
    if ($date) {
        $targetFolder = "D:\Sorted\{0:yyyy}\{0:MM}" -f $date
        if (-not (Test-Path $targetFolder)) { New-Item -Path $targetFolder -ItemType Directory }
        Move-Item $photo.FullName -Destination $targetFolder
    }
}
```

---


### Przykład 16: Wyszukiwanie wszystkich unikalnych modeli aparatów w kolekcji

Chociaż można to zrobić w jednej linii, wyświetlanie w `GridView` pozwala od razu skopiować potrzebną nazwę modelu.

```powershell
# Przełącznik -s3 wyświetla tylko wartości, -Model - nazwę tagu
$uniqueModels = & exiftool.exe -r -Model -s3 "D:\Photos" | Sort-Object -Unique

# Wyświetl w GridView dla łatwego przeglądania i kopiowania
$uniqueModels | Out-ConsoleGridView -Title "Unikalne modele aparatów w kolekcji"
```
