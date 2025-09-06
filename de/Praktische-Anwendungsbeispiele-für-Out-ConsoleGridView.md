### **Praktische Anwendungsbeispiele für Out-ConsoleGridView**

Im vorherigen Kapitel haben wir `Out-ConsoleGridView` kennengelernt – ein leistungsstarkes Tool für die interaktive Arbeit mit Daten direkt im Terminal. Falls Sie nicht wissen, worum es geht, empfehle ich, zuerst den Artikel zu lesen.
Dieser Artikel ist vollständig diesem Tool gewidmet. Ich werde die Theorie nicht wiederholen, sondern direkt zur Praxis übergehen und 10 Szenarien zeigen, in denen dieses Cmdlet einem Systemadministrator oder fortgeschrittenen Benutzer viel Zeit sparen kann.

`Out-ConsoleGridView` ist nicht nur ein "Viewer". Es ist ein **interaktiver Objektfilter** mitten in Ihrer Pipeline.

**Voraussetzungen:**
*   PowerShell 7.2 oder neuer.
*   Installiertes Modul `Microsoft.PowerShell.ConsoleGuiTools`. Falls Sie es noch nicht installiert haben:
    ```powershell
    Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
    ```

---

### 10 praktische Beispiele

#### Beispiel 1: Interaktives Beenden von Prozessen

Klassische Aufgabe: Mehrere "hängende" oder unnötige Prozesse finden und beenden.

```powershell
# Prozesse im interaktiven Modus auswählen
$procsToStop = Get-Process | Sort-Object -Property CPU -Descending | Out-ConsoleGridView -OutputMode Multiple

# Wenn etwas ausgewählt wurde, die Objekte zum Beenden übergeben
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```

(https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  `Get-Process` ruft alle laufenden Prozesse ab.
2.  `Sort-Object` ordnet sie nach CPU-Auslastung, sodass die "ressourcenhungrigsten" oben stehen.
3.  `Out-ConsoleGridView` zeigt die Tabelle an. Sie können `chrome` oder `notepad` eingeben, um die Liste sofort zu filtern und die gewünschten Prozesse mit der `Leertaste` auszuwählen.
4.  Nach dem Drücken von `Enter` gelangen die ausgewählten Prozess-**Objekte** in die Variable `$procsToStop` und werden an `Stop-Process` übergeben.

#### Beispiel 2: Verwalten von Windows-Diensten

Mehrere Dienste, die mit einer Anwendung (z.B. SQL Server) verbunden sind, müssen schnell neu gestartet werden.

```powershell
$services = Get-Service | Out-ConsoleGridView -OutputMode Multiple -Title "Wählen Sie Dienste zum Neustart aus"

if ($services) {
    $services | Restart-Service -WhatIf
}
```

(https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Sie erhalten eine Liste aller Dienste.
2.  Innerhalb von `Out-ConsoleGridView` geben Sie `sql` in den Filter ein und sehen sofort alle Dienste, die mit SQL Server zusammenhängen.
3.  Sie wählen die gewünschten aus und drücken `Enter`. Die Objekte der ausgewählten Dienste werden zum Neustart übergeben.

#### Beispiel 3: Bereinigen des "Downloads"-Ordners von großen Dateien

Mit der Zeit füllt sich der "Downloads"-Ordner mit unnötigen Dateien. Finden und löschen wir die größten davon.

```powershell

# --- SCHRITT 1: Pfad zum 'Downloads'-Verzeichnis konfigurieren
$DownloadsPath = "E:\Users\user\Downloads" # <--- ÄNDERN SIE DIESE ZEILE AUF IHREN PFAD
===========================================================================

# Überprüfung: Wenn der Pfad nicht angegeben ist oder der Ordner nicht existiert - beenden.
if ([string]::IsNullOrEmpty($DownloadsPath) -or (-not (Test-Path -Path $DownloadsPath))) {
    Write-Error "Der 'Downloads'-Ordner wurde unter dem angegebenen Pfad nicht gefunden: '$DownloadsPath'. Bitte überprüfen Sie den Pfad im KONFIGURATIONSBLOCK am Anfang des Skripts."
    return
}

# --- SCHRITT 2: Benutzer informieren und Daten sammeln ---
Write-Host "Beginne mit dem Scannen des Ordners '$DownloadsPath'. Dies kann einige Zeit dauern..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $DownloadsPath -File -Recurse -ErrorAction SilentlyContinue | 
    Sort-Object -Property Length -Descending

# --- SCHRITT 3: Überprüfung auf Dateien und Aufruf des interaktiven Fensters ---
if ($files) {
    Write-Host "Scan abgeschlossen. $($files.Count) Dateien gefunden. Öffne Auswahlfenster..." -ForegroundColor Green
    
    $filesToShow = $files | Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime
    
    $filesToDelete = $filesToShow | Out-ConsoleGridView -OutputMode Multiple -Title "Wählen Sie Dateien zum Löschen aus '$DownloadsPath'"

    # --- SCHRITT 4: Benutzerwahl verarbeiten ---
    if ($filesToDelete) {
        Write-Host "Die folgenden Dateien werden gelöscht:" -ForegroundColor Yellow
        $filesToDelete | Format-Table -AutoSize
        
        $filesToDelete.FullName | Remove-Item -WhatIf -Verbose
    } else {
        Write-Host "Vorgang abgebrochen. Keine Datei ausgewählt." -ForegroundColor Yellow
    }
} else {
    Write-Host "Im Ordner '$DownloadsPath' wurden keine Dateien gefunden." -ForegroundColor Yellow
}
```
[Clear-DownloadsFolder.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/scripts/Clear-DownloadsFolder.ps1)

[Inhalt Downloads](https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Wir erhalten alle Dateien, sortieren sie nach Größe und erstellen mit `Select-Object` eine praktische Spalte `SizeMB`.
2.  In `Out-ConsoleGridView` sehen Sie eine sortierte Liste, in der Sie alte und große `.iso`- oder `.zip`-Dateien leicht auswählen können.
3.  Nach der Auswahl werden ihre vollständigen Pfade an `Remove-Item` übergeben.

#### Beispiel 4: Hinzufügen von Benutzern zu einer Active Directory-Gruppe

Ein unverzichtbares Werkzeug für AD-Administratoren.

```powershell
# Benutzer aus der Marketing-Abteilung abrufen
$users = Get-ADUser -Filter 'Department -eq "Marketing"' -Properties DisplayName

# Interaktiv auswählen, wer hinzugefügt werden soll
$usersToAdd = $users | Select-Object Name, DisplayName | Out-ConsoleGridView -OutputMode Multiple

if ($usersToAdd) {
    Add-ADGroupMember -Identity "Marketing-Global-Group" -Members $usersToAdd -WhatIf
}
```

Anstatt Benutzernamen manuell einzugeben, erhalten Sie eine praktische Liste, in der Sie die gewünschten Mitarbeiter schnell nach Nachnamen oder Login finden und auswählen können.

---

#### Beispiel 5: Herausfinden, welche Programme gerade das Internet nutzen

Eine häufige Aufgabe: "Welches Programm verlangsamt das Internet?" oder "Wer sendet Daten wohin?". Mit `Out-ConsoleGridView` erhalten Sie eine anschauliche und interaktive Antwort.

**Innerhalb der Tabelle:**
*   **Geben Sie `chrome` oder `msedge` ein** in das Filterfeld, um alle aktiven Verbindungen Ihres Browsers zu sehen.
*   **Geben Sie eine IP-Adresse ein** (z.B. `151.101.1.69` aus der Spalte `RemoteAddress`), um zu sehen, welche anderen Prozesse mit demselben Server verbunden sind.

```powershell
# Alle aktiven TCP-Verbindungen abrufen
$connections = Get-NetTCPConnection -State Established | 
    Select-Object RemoteAddress, RemotePort, OwningProcess, @{Name="ProcessName"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

# In einer interaktiven Tabelle zur Analyse ausgeben
$connections | Out-ConsoleGridView -Title "Aktive Internetverbindungen"
```

1.  `Get-NetTCPConnection -State Established` sammelt alle etablierten Netzwerkverbindungen.
2.  Mit `Select-Object` erstellen wir einen praktischen Bericht: Wir fügen den Prozessnamen (`ProcessName`) zu seiner ID (`OwningProcess`) hinzu, um zu verstehen, welches Programm die Verbindung hergestellt hat.
3.  `Out-ConsoleGridView` zeigt Ihnen ein Live-Bild der Netzwerkaktivität.

[Net](https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

### Beispiel 6: Analyse von Softwareinstallationen und Updates

Wir suchen nach Ereignissen der Quelle **"MsiInstaller"**. Diese ist für die Installation, Aktualisierung und Deinstallation der meisten Programme (im `.msi`-Format) sowie für viele Komponenten von Windows-Updates zuständig.

```powershell
# Suche nach den 100 letzten Ereignissen des Windows-Installers (MsiInstaller)
# Diese Ereignisse sind auf jedem System vorhanden
$installEvents = Get-WinEvent -ProviderName 'MsiInstaller' -MaxEvents 100

# Wenn Ereignisse gefunden wurden, diese in einer praktischen Form ausgeben
if ($installEvents) {
    $installEvents | 
        # Nur das Nützlichste auswählen: Zeit, Nachricht und Ereignis-ID
        # ID 11707 - erfolgreiche Installation, ID 11708 - fehlgeschlagene Installation
        Select-Object TimeCreated, Id, Message |
        Out-ConsoleGridView -Title "Installationsprotokoll (MsiInstaller)"
} else {
    Write-Warning "Keine Ereignisse von 'MsiInstaller' gefunden. Das ist sehr ungewöhnlich."
}
```

**Innerhalb der Tabelle:**
*   Sie können die Liste nach dem Programmnamen filtern (z.B. `Edge` oder `Office`), um die gesamte Update-Historie zu sehen.
*   Sie können nach `Id` sortieren, um fehlgeschlagene Installationen (`11708`) zu finden.

---

#### Beispiel 7: Interaktive Deinstallation von Programmen

```powershell
# Registrierungspfade, wo Informationen über installierte Programme gespeichert sind
$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Daten aus der Registrierung sammeln, Systemkomponenten ohne Namen entfernen
$installedPrograms = Get-ItemProperty $registryPaths | 
    Where-Object { $_.DisplayName -and $_.UninstallString } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

# Wenn Programme gefunden wurden, in einer interaktiven Tabelle ausgeben
if ($installedPrograms) {
    $programsToUninstall = $installedPrograms | Out-ConsoleGridView -OutputMode Multiple -Title "Wählen Sie Programme zum Deinstallieren aus"
    
    if ($programsToUninstall) {
        Write-Host "Die folgenden Programme werden deinstalliert:" -ForegroundColor Yellow
        $programsToUninstall | Format-Table -AutoSize
        
        # Dieser Block ist komplexer, da Uninstall-Package hier nicht funktioniert.
        # Wir starten den Deinstallationsbefehl aus der Registrierung.
        foreach ($program in $programsToUninstall) {
            # Das ursprüngliche Programmobjekt mit der Deinstallationszeichenfolge finden
            $fullProgramInfo = Get-ItemProperty $registryPaths | Where-Object { $_.DisplayName -eq $program.DisplayName }
            
            if ($fullProgramInfo.UninstallString) {
                Write-Host "Starte Deinstaller für '$($program.DisplayName)'..." -ForegroundColor Yellow
                # ACHTUNG: Dies startet den Standard-GUI-Deinstaller des Programms.
                # WhatIf funktioniert hier nicht, seien Sie vorsichtig.
                # cmd.exe /c $fullProgramInfo.UninstallString
            }
        }
        Write-Warning "Um Programme wirklich zu deinstallieren, kommentieren Sie die Zeile 'cmd.exe /c ...' im Skript aus."
    }
} else {
    Write-Warning "Installierte Programme konnten in der Registrierung nicht gefunden werden."
}
```

---

Sie haben absolut Recht. Das Beispiel mit Active Directory ist für einen normalen Benutzer nicht geeignet und erfordert eine spezielle Umgebung.

Lassen Sie uns es durch ein viel universelleres und verständlicheres Szenario ersetzen, das die Leistungsfähigkeit der Verknüpfung von `Out-ConsoleGridView` perfekt demonstriert und für jeden Benutzer nützlich sein wird.

---

#### Beispiel 8: Verketten (Chaining) von `Out-ConsoleGridView`

Dies ist die mächtigste Technik. Die Ausgabe einer interaktiven Sitzung wird zum Input für eine andere. **Aufgabe:** Wählen Sie einen Ihrer Projektordner aus und wählen Sie dann bestimmte Dateien daraus aus, um ein ZIP-Archiv zu erstellen.

```powershell
# --- SCHRITT 1: Universell den "Dokumente"-Ordner finden ---
$SearchPath = [System.Environment]::GetFolderPath('MyDocuments')

# --- SCHRITT 2: Interaktiv einen Ordner aus dem angegebenen Ort auswählen ---
$selectedFolder = Get-ChildItem -Path $SearchPath -Directory | 
    Out-ConsoleGridView -Title "Wählen Sie einen Ordner zum Archivieren aus"

if ($selectedFolder) {
    # --- SCHRITT 3: Wenn ein Ordner ausgewählt wurde, dessen Dateien abrufen und auswählen, welche archiviert werden sollen ---
    $filesToArchive = Get-ChildItem -Path $selectedFolder.FullName -File | 
        Out-ConsoleGridView -OutputMode Multiple -Title "Wählen Sie Dateien für das Archiv aus '$($selectedFolder.Name)'"

    if ($filesToArchive) {
        # --- SCHRITT 4: Aktion mit universellen Pfaden ausführen ---
        $archiveName = "Archive-$($selectedFolder.Name)-$(Get-Date -Format 'yyyy-MM-dd').zip"
        
        # UNIVERSELLER WEG, UM DEN PFAD ZUM DESKTOP ZU ERHALTEN
        $desktopPath = [System.Environment]::GetFolderPath('Desktop')
        $destinationPath = Join-Path -Path $desktopPath -ChildPath $archiveName
        
        # Archiv erstellen
        Compress-Archive -Path $filesToArchive.FullName -DestinationPath $destinationPath -WhatIf
        
        Write-Host "Das Archiv '$archiveName' wird auf Ihrem Desktop unter dem Pfad '$destinationPath' erstellt." -ForegroundColor Green
    }
}
```

1.  Das erste `Out-ConsoleGridView` zeigt Ihnen eine Liste der Ordner in Ihren "Dokumenten". Sie können den gewünschten schnell finden, indem Sie einen Teil seines Namens eingeben, und **einen** Ordner auswählen.
2.  Wenn ein Ordner ausgewählt wurde, öffnet das Skript sofort ein **zweites** `Out-ConsoleGridView`, das bereits die **Dateien innerhalb** dieses Ordners anzeigt.
3.  Sie wählen **eine oder mehrere** Dateien mit der `Leertaste` aus und drücken `Enter`.
4.  Das Skript nimmt die ausgewählten Dateien und erstellt daraus ein ZIP-Archiv auf Ihrem Desktop.

Dies verwandelt eine komplexe, mehrstufige Aufgabe (Ordner finden, Dateien darin finden, deren Pfade kopieren, Archivierungsbefehl ausführen) in einen intuitiven, interaktiven Prozess in zwei Schritten.

#### Beispiel 9: Verwalten optionaler Windows-Komponenten

```powershell
# --- Beispiel 9: Verwalten optionaler Windows-Komponenten ---

# Nur aktivierte Komponenten abrufen
$features = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }

$featuresToDisable = $features | Select-Object FeatureName, DisplayName | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Wählen Sie Komponenten zum Deaktivieren aus"

if ($featuresToDisable) {
    # BENUTZER VOR UNUMKEHRBARKEIT WARNEN
    Write-Host "ACHTUNG! Die folgenden Komponenten werden sofort deaktiviert." -ForegroundColor Red
    Write-Host "Dieser Vorgang unterstützt den sicheren Modus -WhatIf nicht."
    $featuresToDisable | Select-Object DisplayName

    # Manuelle Bestätigung anfordern
    $confirmation = Read-Host "Fortfahren? (j/n)"
    
    if ($confirmation -eq 'j') {
        foreach($feature in $featuresToDisable){
            Write-Host "Deaktiviere Komponente '$($feature.DisplayName)'..." -ForegroundColor Yellow
            Disable-WindowsOptionalFeature -Online -FeatureName $feature.FeatureName
        }
        Write-Host "Vorgang abgeschlossen. Ein Neustart kann erforderlich sein." -ForegroundColor Green
    } else {
        Write-Host "Vorgang abgebrochen."
    }
}
```

Sie können unnötige Komponenten wie `Telnet-Client` oder `Windows-Sandbox` leicht finden und deaktivieren.

#### Beispiel 10: Verwalten von Hyper-V-Virtual Machines

Schnelles Anhalten mehrerer virtueller Maschinen für die Host-Wartung.

```powershell
# Nur laufende VMs abrufen
$vms = Get-VM | Where-Object { $_.State -eq 'Running' }

$vmsToStop = $vms | Select-Object Name, State, Uptime | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Wählen Sie VMs zum Anhalten aus"

if ($vmsToStop) {
    $vmsToStop | Stop-VM -WhatIf
}
```

Sie erhalten eine Liste nur der laufenden Maschinen und können interaktiv diejenigen auswählen, die sicher heruntergefahren werden sollen.