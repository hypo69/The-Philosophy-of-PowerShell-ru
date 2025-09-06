# Guida Completa a ExifTool e PowerShell

Ogni volta che scatti una fotografia, la tua fotocamera non registra solo l'immagine stessa nel file, ma anche informazioni di servizio: il modello della fotocamera e dell'obiettivo, la data e l'ora dello scatto, la velocità dell'otturatore, l'apertura, l'ISO, le coordinate GPS. Questi dati sono chiamati **EXIF (Exchangeable Image File Format)**.

Sebbene PowerShell abbia strumenti integrati per leggere alcuni metadati, questi sono limitati. Per accedere a **tutte** le informazioni, è necessario uno strumento specializzato. In questo articolo utilizzerò **ExifTool**.

**ExifTool** è un'utilità gratuita, multipiattaforma e open source, scritta da Phil Harvey. È lo standard d'oro per la lettura, la scrittura e la modifica dei metadati in un'ampia varietà di formati di file (immagini, audio, video, PDF e altro). ExifTool conosce migliaia di tag da centinaia di produttori di dispositivi, il che lo rende lo strumento più completo della sua categoria.

### Download e Configurazione Corretta

Prima di scrivere il codice, è necessario preparare l'utilità stessa.

1.  Visita il **sito ufficiale di ExifTool: [https://exiftool.org/](https://exiftool.org/)**. Sulla pagina principale, trova e scarica **"Windows Executable"**.

2.  **Rinominazione (Passo Critico!):** Il file scaricato si chiamerà `exiftool(-k).exe`. Non è un caso.

Rinominalo in **`exiftool.exe`** per **disabilitare la modalità "pausa"**, che è progettata per gli utenti che avviano il programma con un doppio clic.
>

3.  **Archiviazione:** Hai due opzioni principali su dove archiviare `exiftool.exe`.
    *   **Opzione 1 (Semplice): Nella stessa cartella del tuo script.** Questo è il percorso più facile. Il tuo script PowerShell sarà sempre in grado di trovare l'utilità, poiché si trova accanto ad essa. Ideale per script portatili che sposti da un computer all'altro.
    *   **Opzione 2 (Consigliata per uso frequente): In una cartella inclusa nella variabile di sistema `PATH`.** La variabile `PATH` è un elenco di directory in cui Windows e PowerShell cercano automaticamente i file eseguibili. Puoi creare una cartella (ad esempio, `C:\Tools`), inserirvi `exiftool.exe` e aggiungere `C:\Tools` alla variabile di sistema `PATH`. Dopodiché, potrai richiamare `exiftool.exe` da qualsiasi cartella in qualsiasi console.

Script per aggiungere a $PATH:
Aggiungere una directory a PATH per l'UTENTE CORRENTE
Aggiungere una directory a PATH di SISTEMA per TUTTI GLI UTENTI

---

## PowerShell e Programmi Esterni

Per utilizzare ExifTool in modo efficace, è necessario sapere come PowerShell avvia i file `.exe` esterni.
Il modo corretto e più affidabile per avviare programmi esterni è l'**operatore di chiamata `&` (e commerciale)**.
PowerShell genererà un errore se il percorso del programma contiene spazi. Ad esempio, `C:\My Tools\exiftool.exe`.
`&` (e commerciale)** dice a PowerShell: "Il testo che mi segue tra virgolette è il percorso di un file eseguibile. Avvialo, e tutto ciò che segue sono i suoi argomenti".

```powershell
# Sintassi corretta
& "C:\Path With Spaces\program.exe" "argomento 1" "argomento 2"
```

Usa sempre `&` quando lavori con percorsi di programmi in variabili o percorsi che potrebbero contenere spazi.

---

## Trucchi Pratici: ExifTool + PowerShell

Ora uniamo le nostre conoscenze.

### Esempio №1: Estrazione Base e Visualizzazione Interattiva

Il modo più semplice per ottenere tutti i dati da una foto e studiarli è richiederli in formato JSON e passarli a `Out-ConsoleGridView`.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. Avviamo exiftool con l'opzione -json per un output strutturato
# 2. Convertiamo il testo JSON in un oggetto PowerShell
#    Chiamiamo exiftool.exe direttamente, senza variabile e operatore di chiamata &.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 3. Trasformiamo l'oggetto "ampio" in una comoda tabella "Parametro-Valore"
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 4. Visualizziamo il risultato in una finestra interattiva per l'analisi
$reportData | Out-ConsoleGridView -Title "Metadati del file: $($photoPath | Split-Path -Leaf)"
```

Questo codice aprirà una finestra interattiva dove potrai ordinare i dati per nome del parametro o valore, e anche filtrarli, semplicemente iniziando a digitare il testo. Questo è incredibilmente comodo per trovare rapidamente le informazioni desiderate.

### Esempio №2: Creazione di un Report Pulito e Invio a Diversi "Dispositivi"

`Out-ConsoleGridView` è solo l'inizio. Puoi indirizzare i dati elaborati ovunque, usando altri cmdlet `Out-*`.

Supponiamo di avere i dati nella variabile `$reportData` dall'esempio precedente.

#### **A) Invio a un file CSV per Excel**
```powershell
$reportData | Export-Csv -Path "C:\Reports\photo_exif.csv" -NoTypeInformation -Encoding UTF8
```
Il comando `Export-Csv` crea un file perfettamente strutturato che può essere aperto in Excel o Google Sheets.

#### **B) Invio a un file di testo**
```powershell
# Per una formattazione pulita, usiamo prima Format-Table
$reportData | Format-Table -AutoSize | Out-File -FilePath "C:\Reports\photo_exif.txt"
```
Il comando `Out-File` salverà nel file una copia testuale esatta di ciò che vedi nella console.

#### **C) Invio agli appunti**
Vuoi incollare rapidamente i dati in un'e-mail o in una chat? Usa `Out-Clipboard`.
```powershell
$reportData | Format-Table -AutoSize | Out-String | Out-Clipboard
```

Ora puoi premere `Ctrl+V` in qualsiasi editor di testo e incollare una tabella formattata in modo ordinato.

### Esempio №3: Ottenere Dati Specifici per l'Uso in uno Script

Spesso non hai bisogno dell'intero report, ma solo di uno o due valori. Poiché `$exifObject` è un normale oggetto PowerShell, puoi facilmente accedere alle sue proprietà.

```powershell

$photoPath = "D:\Photos\IMG_1234.JPG"

# Chiamiamo exiftool.exe direttamente per nome.
# PowerShell lo troverà automaticamente in una delle cartelle elencate in PATH.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 1. Creiamo un oggetto PowerShell con nomi di proprietà comprensibili.
#    Questo è simile alla creazione di un record strutturato.
$reportObject = [PSCustomObject]@{
    "Fotocamera"       = $exifObject.Model
    "Data Scatto"      = $exifObject.DateTimeOriginal
    "Sensibilità"      = $exifObject.ISO
    "Nome File"        = $exifObject.FileName # Aggiungiamo il nome del file per contesto
}

# 2. Visualizziamo questo oggetto in una finestra interattiva.
#    Out-GridView creerà automaticamente le colonne dai nomi delle proprietà.
$reportObject | Out-ConsoleGridView -Title "Metadati del file: $(Split-Path $photoPath -Leaf)"
```

Questo approccio è la base per qualsiasi automazione seria, come la ridenominazione di file basata sulla data di scatto, l'ordinamento delle foto per modello di fotocamera o l'aggiunta di filigrane con informazioni sull'esposizione.

### Esempio №4: Estrazione Batch di Metadati da una Cartella

A volte è necessario analizzare non una singola foto, ma un'intera cartella di immagini.

```powershell
# Specifichiamo solo la cartella con le foto.
$photoFolder = "D:\Photos"

# Chiamiamo exiftool.exe direttamente. Non sono necessarie variabili per il percorso e l'operatore &.
$allExif = exiftool.exe -json "$photoFolder\*.jpg" | ConvertFrom-Json

# Trasformiamo in un formato comodo
$report = foreach ($photo in $allExif) {
    [PSCustomObject]@{
        # --- Dati principali su file e fotocamera ---
        FileName       = $photo.FileName
        DateTime       = $photo.DateTimeOriginal
        CameraMake     = $photo.Make                 # Produttore (es. "Canon", "SONY")
        CameraModel    = $photo.Model                 # Modello fotocamera (es. "EOS R5")
        LensModel      = $photo.LensID                # Nome completo del modello dell'obiettivo
        
        # --- Parametri di scatto (esposizione) ---
        ISO            = $photo.ISO
        ShutterSpeed   = $photo.ShutterSpeed
        Aperture       = $photo.Aperture
        FocalLength    = $photo.FocalLength           # Lunghezza focale (es. "50.0 mm")
        ExposureMode   = $photo.ExposureProgram       # Modalità di scatto (es. "Manuale", "Priorità di Apertura")
        Flash          = $photo.Flash                 # Informazioni sull'attivazione del flash
        
        # --- GPS e dati immagine ---
        GPSPosition    = $photo.GPSPosition           # Coordinate GPS come singola stringa (se presenti)
        Dimensions     = "$($photo.ImageWidth)x$($photo.ImageHeight)" # Dimensioni dell'immagine in pixel
    }
}

# Visualizziamo i dati in una tabella interattiva nella CONSOLE
$report | Out-ConsoleGridView -Title "Report riassuntivo per la cartella: $photoFolder"
```

💡 Ottieni una tabella ordinata per l'intera cartella in una volta sola.

---

### Esempio №5: Ricerca Ricorsiva nelle Sottocartelle

ExifTool può cercare file in tutte le sottocartelle usando l'opzione `-r`.

```powershell
& $exifToolPath -r -json "D:\Photos" | ConvertFrom-Json |
    Select-Object FileName, Model, DateTimeOriginal |
    Export-Csv "C:\Reports\all_photos_recursive.csv" -NoTypeInformation -Encoding UTF8
```

---

### Esempio №6: Ridenominazione dei File per Data di Scatto

Questo è uno degli scenari di automazione più popolari: i file vengono rinominati in base alla data/ora di scatto.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# Rinominiamo nel formato YYYY-MM-DD_HH-MM-SS.jpg
& $exifToolPath -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```

💡 *Questa azione è irreversibile, quindi esegui un backup prima di procedere.*

---

### Esempio №7: Estrazione delle Sole Coordinate GPS

Utile se vuoi costruire una mappa dalle tue foto.

```powershell
# 1. Specifica il percorso della cartella con le tue foto
$photoFolder = "E:\DCIM\Camera"

# 2. Elenchiamo i tag di cui abbiamo bisogno: nome del file e tre tag GPS.
#    Questo rende la query molto più veloce rispetto all'estrazione di tutti i tag.
$tagsToExtract = @(
    "-SourceFile", # SourceFile è meglio di FileName, poiché di solito contiene il percorso completo
    "-GPSLatitude",
    "-GPSLongitude",
    "-GPSAltitude"
)

# 3. Chiamiamo exiftool.exe direttamente (poiché è in PATH).
#    L'opzione -r cerca i file in tutte le sottocartelle.
#    Il risultato viene immediatamente convertito da JSON.
$allExifData = exiftool.exe -r -json $tagsToExtract $photoFolder | ConvertFrom-Json

# 4. Filtriamo i risultati: manteniamo SOLO gli oggetti che hanno latitudine e longitudine.
$filesWithGps = $allExifData | Where-Object { $_.GPSLatitude -and $_.GPSLongitude }

# 5. Controlliamo se sono stati trovati file con dati GPS
if ($filesWithGps) {
    # 6. Creiamo un bel report dai dati filtrati.
    #    Usiamo Select-Object per rinominare le colonne e formattare.
    $report = $filesWithGps | Select-Object @{Name="Nome File"; Expression={Split-Path $_.SourceFile -Leaf}},
                                             @{Name="Latitudine"; Expression={$_.GPSLatitude}},
                                             @{Name="Longitudine"; Expression={$_.GPSLongitude}},
                                             @{Name="Altitudine"; Expression={if ($_.GPSAltitude) { "$($_.GPSAltitude) m" } else { "N/A" }}}
    
    # 7. Visualizziamo il report finale in una tabella interattiva della console.
    $report | Out-ConsoleGridView -Title "File con dati GPS nella cartella: $photoFolder"

} else {
    # Se non viene trovato nulla, lo comunichiamo gentilmente.
    Write-Host "File con dati GPS nella cartella '$photoFolder' non trovati." -ForegroundColor Yellow
}
```

---

### Esempio №8: Eliminazione Massiva di Tutti i Dati GPS (per la Privacy)

```powershell
# Eliminiamo tutti i tag GPS da JPG e PNG
& $exifToolPath -r -overwrite_original -gps:all= "D:\Photos"
```

💡 *Questa azione è irreversibile, quindi esegui un backup prima di procedere.*

---

### Esempio №9: Conversione dell'Ora di Scatto all'Ora Locale

A volte le foto vengono scattate in un fuso orario diverso. ExifTool può spostare la data.

```powershell
# Spostiamo l'ora di +3 ore
& $exifToolPath "-AllDates+=3:0:0" "D:\Photos\IMG_*.JPG"
```

---

### Esempio №10: Ottenere un Elenco di Tutti i Modelli di Fotocamera Unici in una Cartella

```powershell
$models = & $exifToolPath -r -Model -s3 "D:\Photos" | Sort-Object -Unique
$models | ForEach-Object { Write-Host "Modello: $_" }
```

---

### Esempio №11: Visualizzazione Solo dei Tag Necessari in Formato Tabellare

```powershell
& $exifToolPath -T -Model -DateTimeOriginal -ISO -Aperture -ShutterSpeed "D:\Photos\IMG_1234.JPG"
```

`-T` produce un output in formato tabellare, separato da tabulazioni — comodo per l'ulteriore elaborazione.

---

### Esempio №12: Controllo della Presenza di GPS in un Grande Array di File

```powershell
$files = & $exifToolPath -r -if "$gpslatitude" -p '$FileName' "D:\Photos"
Write-Host "File con GPS:"
$files
```

---

### Esempio №13: Copia di Metadati da un File all'Altro

```powershell
# 1. Selezioniamo il file di riferimento
$sourceFile = Get-ChildItem "D:\Photos" -Filter "*.jpg" | Out-ConsoleGridView -Title "Seleziona il file di RIFERIMENTO"

# 2. Se il riferimento è stato selezionato, selezioniamo i file di destinazione
if ($sourceFile) {
    $targetFiles = Get-ChildItem "D:\Photos\New" -Filter "*.jpg" | Out-ConsoleGridView -Title "Seleziona i file di DESTINAZIONE per la copia dei metadati" -OutputMode Multiple
    
    # 3. Se le destinazioni sono state selezionate, eseguiamo la copia
    if ($targetFiles) {
        & exiftool.exe -TagsFromFile $sourceFile.FullName ($targetFiles.FullName)
        Write-Host "Metadati copiati da $($sourceFile.Name) a $($targetFiles.Count) file."
    }
}
```

---

### Esempio №14: Salvataggio dei Metadati Originali in un JSON Separato Prima della Modifica

```powershell
$backupPath = "C:\Reports\metadata_backup.json"
& $exifToolPath -r -json "D:\Photos" | Out-File -Encoding UTF8 $backupPath
```

---

### Esempio №15: Utilizzo di PowerShell per l'Ordinamento Automatico delle Foto per Data

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

### Esempio 16: Trovare Tutti i Modelli di Fotocamera Unici in una Collezione

Sebbene questo possa essere fatto con una singola riga, l'output in `GridView` consente di copiare immediatamente il nome del modello desiderato.

```powershell
# L'opzione -s3 visualizza solo i valori, -Model il nome del tag
$uniqueModels = & exiftool.exe -r -Model -s3 "D:\Photos" | Sort-Object -Unique

# Visualizziamo in GridView per una comoda visualizzazione e copia
$uniqueModels | Out-ConsoleGridView -Title "Modelli di fotocamera unici nella collezione"
```