### Diagnose und Wiederherstellung von Festplatten mit PowerShell

PowerShell ermöglicht die Automatisierung von Überprüfungen, die Durchführung von Ferndiagnosen und die Erstellung flexibler Skripte zur Überwachung. Dieser Leitfaden führt Sie von grundlegenden Überprüfungen bis hin zur tiefgreifenden Diagnose und Wiederherstellung von Festplatten.

**Version:** Der Leitfaden ist aktuell für **Windows 10/11** und **Windows Server 2016+**.

### Schlüssel-Cmdlets für die Arbeit mit Festplatten

| Cmdlet | Zweck |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Informationen zu physischen Festplatten (Modell, Gesundheitszustand). |
| **`Get-Disk`** | Informationen zu Festplatten auf Geräteebene (Online/Offline-Status, Partitionsstil). |
| **`Get-Partition`** | Informationen zu Partitionen auf Festplatten. |
| **`Get-Volume`** | Informationen zu logischen Volumes (Laufwerksbuchstaben, Dateisystem, freier Speicherplatz). |
| **`Repair-Volume`** | Überprüfung und Wiederherstellung logischer Volumes (analog zu `chkdsk`). |
| **`Get-StoragePool`** | Wird für die Arbeit mit Speicherplätzen (Storage Spaces) verwendet. |

---

### Schritt 1: Grundlegende Systemzustandsprüfung

Beginnen Sie mit einer allgemeinen Bewertung des Zustands des Festplattensubsystems.

#### Anzeigen aller angeschlossenen Festplatten

Der Befehl `Get-Disk` liefert zusammenfassende Informationen über alle Festplatten, die das Betriebssystem sieht.

```powershell
Get-Disk
```

Sie sehen eine Tabelle mit Festplattennummern, deren Größen, Status (`Online` oder `Offline`) und Partitionsstil (`MBR` oder `GPT`).

**Beispiel:** Finden Sie alle Festplatten, die offline sind.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Überprüfung der physischen „Gesundheit“ der Festplatten

Das Cmdlet `Get-PhysicalDisk` greift auf den Zustand der Hardware selbst zu.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Beachten Sie besonders das Feld `HealthStatus`. Es kann folgende Werte annehmen:
*   **Healthy:** Festplatte ist in Ordnung.
*   **Warning:** Es gibt Probleme, Aufmerksamkeit ist erforderlich (z. B. Überschreitung der S.M.A.R.T.-Schwellenwerte).
*   **Unhealthy:** Festplatte ist in kritischem Zustand und kann ausfallen.

---

### Schritt 2: Analyse und Wiederherstellung logischer Volumes

Nach der Überprüfung des physischen Zustands gehen wir zur logischen Struktur über – Volumes und Dateisystem.

#### Informationen zu logischen Volumes

Der Befehl `Get-Volume` zeigt alle gemounteten Volumes im System an.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Schlüsselfelder:
*   `DriveLetter` – Laufwerksbuchstabe (C, D usw.).
*   `FileSystem` – Dateisystemtyp (NTFS, ReFS, FAT32).
*   `HealthStatus` – Zustand des Volumes.
*   `SizeRemaining` und `Size` – Freier und gesamter Speicherplatz.

#### Überprüfung und Wiederherstellung des Volumes (analog zu `chkdsk`)

Das Cmdlet `Repair-Volume` ist ein moderner Ersatz für das Dienstprogramm `chkdsk`.

**1. Überprüfung des Volumes ohne Korrekturen (nur Scan)**

Dieser Modus ist sicher für die Ausführung auf einem laufenden System, er sucht nur nach Fehlern.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Vollständiger Scan und Fehlerbehebung**

Dieser Modus ist analog zu `chkdsk C: /f`. Er blockiert das Volume während des Betriebs, daher ist für die Systemfestplatte ein Neustart erforderlich.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Wichtig:** Wenn Sie diesen Befehl für die Systemfestplatte (C:) ausführen, plant PowerShell eine Überprüfung beim nächsten Systemstart. Um sie sofort auszuführen, starten Sie den Computer neu.

**Beispiel:** Überprüfen und reparieren Sie automatisch alle Volumes, deren Zustand von `Healthy` abweicht.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Repairing volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Schritt 3: Tiefendiagnose und S.M.A.R.T.

Wenn grundlegende Überprüfungen keine Probleme ergaben, aber Verdachtsmomente bestehen bleiben, kann man tiefer graben.

#### Analyse der Systemprotokolle

Fehler im Festplattensubsystem werden oft im Windows-Systemprotokoll aufgezeichnet.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
Für eine genauere Suche kann nach der Ereignisquelle gefiltert werden:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Überprüfung des S.M.A.R.T.-Status

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) – Technologie zur Selbstdiagnose von Festplatten. PowerShell ermöglicht das Abrufen dieser Daten.

**Methode 1: Verwendung von WMI (für Kompatibilität)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
Wenn `PredictFailure = True`, sagt die Festplatte einen baldigen Ausfall voraus. Dies ist ein Signal zum sofortigen Austausch.

**Methode 2: Moderner Ansatz über CIM und Storage-Module**

Eine modernere und detailliertere Methode ist die Verwendung des Cmdlets `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
Dieses Cmdlet liefert wertvolle Informationen wie Verschleiß (relevant für SSDs), Temperatur und die Anzahl der Lese-/Schreibfehler.

---

### Praktische Szenarien für den Systemadministrator

Hier sind einige fertige Beispiele für alltägliche Aufgaben.

**1. Erstellen Sie einen kurzen Bericht über den Zustand aller physischen Festplatten.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Erstellen Sie einen CSV-Bericht über den freien Speicherplatz auf allen Volumes.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Finden Sie alle Partitionen auf einer bestimmten Festplatte (z.B. Festplatte 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Starten Sie die Diagnose der Systemfestplatte mit anschließendem Neustart.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```