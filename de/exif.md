# Vollständige Anleitung zu ExifTool und PowerShell

Jedes Mal, wenn Sie ein Foto aufnehmen, speichert Ihre Kamera nicht nur das Bild selbst in der Datei, sondern auch Dienstinformationen: Kameramodell und Objektiv, Aufnahmedatum und -zeit, Belichtungszeit, Blende, ISO, GPS-Koordinaten. Diese Daten werden **EXIF (Exchangeable Image File Format)** genannt.

Obwohl PowerShell integrierte Mittel zum Lesen einiger Metadaten bietet, sind diese begrenzt. Um auf **alle** Informationen zugreifen zu können, ist ein spezialisiertes Tool erforderlich. In diesem Artikel verwende ich **ExifTool**.

**ExifTool** ist ein kostenloses, plattformübergreifendes Open-Source-Dienstprogramm, das von Phil Harvey geschrieben wurde. Es ist der Goldstandard zum Lesen, Schreiben und Bearbeiten von Metadaten in einer Vielzahl von Dateiformaten (Bilder, Audio, Video, PDF und andere). ExifTool kennt Tausende von Tags von Hunderten von Geräteherstellern, was es zum umfassendsten Tool seiner Klasse macht.

### Herunterladen und korrekte Einrichtung

Bevor Sie Code schreiben, müssen Sie das Dienstprogramm selbst vorbereiten.

1.  Besuchen Sie die **offizielle ExifTool-Website: [https://exiftool.org/](https://exiftool.org/)**. Suchen und laden Sie auf der Startseite die **"Windows Executable"** herunter.

2.  **Umbenennen (Kritischer Schritt!):** Die heruntergeladene Datei heißt `exiftool(-k).exe`. Das ist kein Zufall.

Benennen Sie sie in **`exiftool.exe`** um, um den **"Pause-Modus" zu deaktivieren**, der für Benutzer gedacht ist, die das Programm per Doppelklick starten.
>

3.  **Speicherort:** Sie haben zwei Hauptoptionen, wo Sie `exiftool.exe` speichern können.
    *   **Option 1 (Einfach): Im selben Ordner wie Ihr Skript.** Dies ist der einfachste Weg. Ihr PowerShell-Skript kann das Dienstprogramm immer finden, da es sich daneben befindet. Ideal für portable Skripte, die Sie von Computer zu Computer übertragen.
    *   **Option 2 (Empfohlen für häufigen Gebrauch): In einem Ordner der Systemvariablen `PATH`.** Die Variable `PATH` ist eine Liste von Verzeichnissen, in denen Windows und PowerShell automatisch nach ausführbaren Dateien suchen.
    Sie können einen Ordner erstellen (z. B. `C:\Tools`), `exiftool.exe` dort ablegen und `C:\Tools` zur Systemvariablen `PATH` hinzufügen.
    Danach können Sie `exiftool.exe` von jedem Ordner in jeder Konsole aufrufen.

Skripte zum Hinzufügen zum $PATH:
Hinzufügen eines Verzeichnisses zum PATH für den AKTUELLEN BENUTZER
Hinzufügen eines Verzeichnisses zum SYSTEM-PATH für ALLE BENUTZER

---

## PowerShell und externe Programme

Um ExifTool effektiv nutzen zu können, müssen Sie wissen, wie PowerShell externe `.exe`-Dateien startet.
Die korrekte und zuverlässigste Methode zum Starten externer Programme ist der **Aufrufoperator `&` (Ampersand)**.
PowerShell gibt einen Fehler aus, wenn der Pfad zum Programm Leerzeichen enthält. Zum Beispiel `C:\My Tools\exiftool.exe`.
`&` (Ampersand)** sagt PowerShell: "Der Text, der mir in Anführungszeichen folgt, — ist der Pfad zu einer ausführbaren Datei. Starte sie, und alles, was danach kommt, — sind ihre Argumente."

```powershell
# Korrekte Syntax
& "C:\Path With Spaces\program.exe" "Argument 1" "Argument 2"
```

Verwenden Sie immer `&`, wenn Sie mit Programmpfaden in Variablen oder Pfaden arbeiten, die Leerzeichen enthalten können.

---

## Praktische Tricks: ExifTool + PowerShell

Nun verbinden wir unser Wissen.

### Beispiel Nr. 1: Grundlegende Extraktion und interaktive Anzeige

Der einfachste Weg, alle Daten aus einem Foto zu erhalten und zu untersuchen, besteht darin, sie im JSON-Format anzufordern und an `Out-ConsoleGridView` zu übergeben.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. Starten Sie exiftool mit dem -json-Schlüssel für eine strukturierte Ausgabe
# 2. Konvertieren Sie den JSON-Text in ein PowerShell-Objekt
#    Rufen Sie exiftool.exe direkt auf, ohne Variable und Aufrufoperator &.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 3. Wandeln Sie das "breite" Objekt in eine praktische "Parameter-Wert"-Tabelle um
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 4. Zeigen Sie das Ergebnis in einem interaktiven Fenster zur Analyse an
$reportData | Out-ConsoleGridView -Title "Metadaten der Datei: $($photoPath | Split-Path -Leaf)"
```

Dieser Code öffnet ein interaktives Fenster, in dem Sie die Daten nach Parameternamen oder Werten sortieren und filtern können, indem Sie einfach Text eingeben. Dies ist unglaublich praktisch, um schnell die benötigten Informationen zu finden.

### Beispiel Nr. 2: Erstellen eines sauberen Berichts und Senden an verschiedene "Geräte"

`Out-ConsoleGridView` ist nur der Anfang. Sie können die verarbeiteten Daten mit anderen `Out-*`-Cmdlets überallhin senden.

Angenommen, wir haben Daten in der Variablen `$reportData` aus dem vorherigen Beispiel.

#### **A) Senden an eine CSV-Datei für Excel**
```powershell
$reportData | Export-Csv -Path "C:\Reports\photo_exif.csv" -NoTypeInformation -Encoding UTF8
```
Der Befehl `Export-Csv` erstellt eine perfekt strukturierte Datei, die in Excel oder Google Tabellen geöffnet werden kann.

#### **B) Senden an eine Textdatei**
```powershell
# Für eine schöne Formatierung verwenden Sie zuerst Format-Table
$reportData | Format-Table -AutoSize | Out-File -FilePath "C:\Reports\photo_exif.txt"
```
Der Befehl `Out-File` speichert eine exakte Textkopie dessen, was Sie in der Konsole sehen, in der Datei.

#### **C) Senden in die Zwischenablage**
Möchten Sie Daten schnell in eine E-Mail oder einen Chat einfügen? Verwenden Sie `Out-Clipboard`.
```powershell
$reportData | Format-Table -AutoSize | Out-String | Out-Clipboard
```

Jetzt können Sie `Strg+V` in jedem Texteditor drücken und eine sauber formatierte Tabelle einfügen.

### Beispiel Nr. 3: Abrufen spezifischer Daten zur Verwendung in einem Skript

Oft benötigen Sie nicht den gesamten Bericht, sondern nur ein oder zwei Werte. Da `$exifObject` ein normales PowerShell-Objekt ist, können Sie einfach auf seine Eigenschaften zugreifen.

```powershell

$photoPath = "D:\Photos\IMG_1234.JPG"

# Rufen Sie exiftool.exe direkt nach Namen auf.
# PowerShell findet es automatisch in einem der im PATH aufgelisteten Ordner.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 1. Erstellen Sie ein PowerShell-Objekt mit verständlichen Eigenschaftsnamen.
#    Dies ähnelt dem Erstellen eines strukturierten Datensatzes.
$reportObject = [PSCustomObject]@{
    "Kamera"           = $exifObject.Model
    "Aufnahmedatum"      = $exifObject.DateTimeOriginal
    "Empfindlichkeit" = $exifObject.ISO
    "Dateiname"        = $exifObject.FileName # Dateiname für den Kontext hinzufügen
}

# 2. Zeigen Sie dieses Objekt in einem interaktiven Fenster an.
#    Out-GridView erstellt automatisch Spalten aus den Eigenschaftsnamen.
$reportObject | Out-ConsoleGridView -Title "Metadaten der Datei: $(Split-Path $photoPath -Leaf)"
```

Dieser Ansatz ist die Grundlage für jede ernsthafte Automatisierung, wie das Umbenennen von Dateien basierend auf dem Aufnahmedatum, das Sortieren von Fotos nach Kameramodell oder das Hinzufügen von Wasserzeichen mit Belichtungsinformationen.

### Beispiel Nr. 4: Stapelweise Metadatenextraktion aus einem Ordner

Manchmal muss nicht nur ein Foto, sondern ein ganzer Ordner mit Bildern analysiert werden.

```powershell
# Geben Sie nur den Ordner mit den Fotos an.
$photoFolder = "D:\Photos"

# Rufen Sie exiftool.exe direkt auf. Eine Variable für den Pfad und der Operator & sind nicht erforderlich.
$allExif = exiftool.exe -json "$photoFolder\*.jpg" | ConvertFrom-Json

# In eine praktische Ansicht umwandeln
$report = foreach ($photo in $allExif) {
    [PSCustomObject]@{
        # --- Grundlegende Datei- und Kameradaten ---
        FileName       = $photo.FileName
        DateTime       = $photo.DateTimeOriginal
        CameraMake     = $photo.Make                 # Hersteller (z.B. "Canon", "SONY")
        CameraModel    = $photo.Model                 # Kameramodell (z.B. "EOS R5")
        LensModel      = $photo.LensID                # Vollständiger Name des Objektivmodells
        
        # --- Aufnahmeeinstellungen (Belichtung) ---
        ISO            = $photo.ISO
        ShutterSpeed   = $photo.ShutterSpeed
        Aperture       = $photo.Aperture
        FocalLength    = $photo.FocalLength           # Brennweite (z.B. "50.0 mm")
        ExposureMode   = $photo.ExposureProgram       # Aufnahmemodus (z.B. "Manual", "Aperture Priority")
        Flash          = $photo.Flash                 # Informationen, ob der Blitz ausgelöst wurde
        
        # --- GPS und Daten изображения ---
        GPSPosition    = $photo.GPSPosition           # GPS-Koordinaten als einzelne Zeichenfolge (falls vorhanden)
        Dimensions     = "$($photo.ImageWidth)x$($photo.ImageHeight)" # Bildabmessungen in Pixeln
    }
}

# Zeigen Sie die Daten in einer interaktiven Tabelle in der KONSOLE an
$report | Out-ConsoleGridView -Title "Zusammenfassender Bericht für Ordner: $photoFolder"
```

💡 Sie erhalten sofort eine übersichtliche Tabelle für den gesamten Ordner.

---

### Beispiel Nr. 5: Rekursive Suche in Unterordnern

ExifTool kann selbst Dateien in allen Unterordnern suchen, wenn der Schlüssel `-r` verwendet wird.

```powershell
& $exifToolPath -r -json "D:\Photos" | ConvertFrom-Json |
    Select-Object FileName, Model, DateTimeOriginal |
    Export-Csv "C:\Reports\all_photos_recursive.csv" -NoTypeInformation -Encoding UTF8
```

---

### Beispiel Nr. 6: Umbenennen von Dateien nach Aufnahmedatum

Dies ist eines der beliebtesten Automatisierungsszenarien – Dateien erhalten Namen nach Aufnahmedatum/-zeit.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# Umbenennen in das Format YYYY-MM-DD_HH-MM-SS.jpg
& $exifToolPath -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```

💡 *Diese Aktion ist irreversibel, erstellen Sie daher vor der Ausführung ein Backup.*

---

### Beispiel Nr. 7: Nur GPS-Koordinaten extrahieren

Nützlich, wenn Sie eine Karte Ihrer Fotos erstellen möchten.

```powershell
# 1. Geben Sie den Pfad zu Ihrem Fotoordner an
$photoFolder = "E:\DCIM\Camera"

# 2. Listen Sie die Tags auf, die wir benötigen: Dateiname und drei GPS-Tags.
#    Dies macht die Abfrage viel schneller, als wenn wir alle Tags abrufen würden.
$tagsToExtract = @(
    "-SourceFile", # SourceFile ist besser als FileName, da es normalerweise den vollständigen Pfad enthält
    "-GPSLatitude",
    "-GPSLongitude",
    "-GPSAltitude"
)

# 3. Rufen Sie exiftool.exe direkt auf (da es im PATH ist).
#    Der Schlüssel -r sucht Dateien in allen Unterordnern.
#    Das Ergebnis wird sofort aus JSON konvertiert.
$allExifData = exiftool.exe -r -json $tagsToExtract $photoFolder | ConvertFrom-Json

# 4. Filtern Sie die Ergebnisse: оставляем ТОЛЬКО те объекты, у которых есть широта и долгота.
$filesWithGps = $allExifData | Where-Object { $_.GPSLatitude -and $_.GPSLongitude }

# 5. Проверяем, нашлись ли вообще файлы с GPS-данными
if ($filesWithGps) {
    # 6. Создаем красивый отчет из отфильтрованных данных.
    #    Используем Select-Object для переименования колонок и форматирования.
    $report = $filesWithGps | Select-Object @{Name="Dateiname"; Expression={Split-Path $_.SourceFile -Leaf}},
                                             @{Name="Breitengrad"; Expression={$_.GPSLatitude}},
                                             @{Name="Längengrad"; Expression={$_.GPSLongitude}},
                                             @{Name="Höhe"; Expression={if ($_.GPSAltitude) { "$($_.GPSAltitude) m" } else { "N/A" }}}
    
    # 7. Выводим итоговый отчет в интерактивную консольную таблицу.
    $report | Out-ConsoleGridView -Title "Dateien с GPS-Daten im Ordner: $photoFolder"

} else {
    # Если ничего не найдено, вежливо сообщаем об этом.
    Write-Host "Dateien с GPS-Daten im Ordner '$photoFolder' wurden nicht gefunden." -ForegroundColor Yellow
}
```

---

### Beispiel Nr. 8: Massenlöschung всех GPS-данных (для приватности)

```powershell
# Удалим все GPS-теги из JPG и PNG
& $exifToolPath -r -overwrite_original -gps:all= "D:\Photos"
```

💡 *Diese Aktion ist irreversibel, erstellen Sie daher vor der Ausführung ein Backup.*

---

### Beispiel Nr. 9: Konvertierung der Aufnahmezeit in die lokale Zeit

Иногда фото сняты в другом часовом поясе. ExifTool может сместить дату.

```powershell
# Смещаем время на +3 часа
& $exifToolPath "-AllDates+=3:0:0" "D:\Photos\IMG_*.JPG"
```

---

### Beispiel Nr. 10: Получение списка всех уникальных моделей камер в папке

```powershell
$models = & $exifToolPath -r -Model -s3 "D:\Photos" | Sort-Object -Unique
$models | ForEach-Object { Write-Host "Модель: $_" }
```

---

### Beispiel Nr. 11: Вывод только нужных тегов в табличном виде

```powershell
& $exifToolPath -T -Model -DateTimeOriginal -ISO -Aperture -ShutterSpeed "D:\Photos\IMG_1234.JPG"
```

`-T` gibt die Ausgabe im tabellarischen Format, durch Tabulatoren getrennt, aus – praktisch für die weitere Verarbeitung.

---

### Beispiel Nr. 12: Проверка наличия GPS в большом массиве файлов

```powershell
$files = & $exifToolPath -r -if "$gpslatitude" -p '$FileName' "D:\Photos"
Write-Host "Файлы с GPS:"
$files
```

---

### Beispiel Nr. 13: Копирование метаданных с одного файла на другой

```powershell
# 1. Выбираем эталонный файл
$sourceFile = Get-ChildItem "D:\Photos" -Filter "*.jpg" | Out-ConsoleGridView -Title "Выберите ЭТАЛОННЫЙ файл"

# 2. Если эталон выбран, выбираем целевые файлы
if ($sourceFile) {
    $targetFiles = Get-ChildItem "D:\Photos\New" -Filter "*.jpg" | Out-ConsoleGridView -Title "Выберите ЦЕЛЕВЫЕ файлы для копирования метаданных" -OutputMode Multiple
    
    # 3. Если цели выбраны, выполняем копирование
    if ($targetFiles) {
        & exiftool.exe -TagsFromFile $sourceFile.FullName ($targetFiles.FullName)
        Write-Host "Метаданные скопированы с $($sourceFile.Name) на $($targetFiles.Count) файлов."
    }
}
```

---

### Пример №14: Сохранение исходных метаданных в отдельный JSON перед изменением

```powershell
$backupPath = "C:\Reports\metadata_backup.json"
& $exifToolPath -r -json "D:\Photos" | Out-File -Encoding UTF8 $backupPath
```

---

### Пример №15: Использование PowerShell для автоматической сортировки фото по дате

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

### Пример 16: Поиск всех уникальных моделей камер в коллекции

Obwohl dies in einer Zeile erledigt werden kann, ermöglicht die Ausgabe in `GridView` das sofortige Kopieren des gewünschten Modellnamens.

```powershell
# Der Schlüssel -s3 gibt nur Werte aus, -Model - den Namen des Tags
$uniqueModels = & exiftool.exe -r -Model -s3 "D:\Photos" | Sort-Object -Unique

# Ausgabe in GridView zur einfachen Anzeige und zum Kopieren
$uniqueModels | Out-ConsoleGridView -Title "Eindeutige Kameramodelle in der Sammlung"
```