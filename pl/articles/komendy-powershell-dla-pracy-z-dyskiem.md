### Diagnostyka i odzyskiwanie dysków za pomocą PowerShell

PowerShell umożliwia automatyzację kontroli, zdalną diagnostykę i tworzenie elastycznych skryptów do monitorowania. Ten przewodnik poprowadzi Cię od podstawowych kontroli do głębokiej diagnostyki i odzyskiwania dysków.

**Wersja:** Przewodnik jest aktualny dla **Windows 10/11** i **Windows Server 2016+**.

### Kluczowe polecenia cmdlet do pracy z dyskami

| Polecenie cmdlet | Przeznaczenie |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Informacje o dyskach fizycznych (model, stan zdrowia). |
| **`Get-Disk`** | Informacje o dyskach na poziomie urządzenia (status Online/Offline, styl partycji). |
| **`Get-Partition`** | Informacje o partycjach na dyskach. |
| **`Get-Volume`** | Informacje o woluminach logicznych (litery dysków, system plików, wolne miejsce). |
| **`Repair-Volume`** | Sprawdzanie i odzyskiwanie woluminów logicznych (odpowiednik `chkdsk`). |
| **`Get-StoragePool`** | Używane do pracy z przestrzeniami dyskowymi (Storage Spaces). |

---

### Krok 1: Podstawowa kontrola stanu systemu

Zacznij od ogólnej oceny stanu podsystemu dyskowego.

#### Przegląd wszystkich podłączonych dysków

Polecenie `Get-Disk` dostarcza zbiorcze informacje o wszystkich dyskach, które widzi system operacyjny.

```powershell
Get-Disk
```

Zobaczysz tabelę z numerami dysków, ich rozmiarami, statusem (`Online` lub `Offline`) i stylem partycji (`MBR` lub `GPT`).

**Przykład:** Znajdź wszystkie dyski, które są w trybie offline.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Sprawdzanie fizycznego „zdrowia” dysków

Polecenie cmdlet `Get-PhysicalDisk` odwołuje się do stanu samego sprzętu.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Zwróć szczególną uwagę na pole `HealthStatus`. Może ono przyjmować wartości:
*   **Healthy:** Dysk jest w porządku.
*   **Warning:** Istnieją problemy, wymagana jest uwaga (np. przekroczenie progów S.M.A.R.T.).
*   **Unhealthy:** Dysk jest w stanie krytycznym i może ulec awarii.

---

### Krok 2: Analiza i odzyskiwanie woluminów logicznych

Po sprawdzeniu stanu fizycznego przechodzimy do struktury logicznej — woluminów i systemu plików.

#### Informacje o woluminach logicznych

Polecenie `Get-Volume` pokazuje wszystkie zamontowane woluminy w systemie.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Kluczowe pola:
*   `DriveLetter` — Litera woluminu (C, D itd.).
*   `FileSystem` — Typ systemu plików (NTFS, ReFS, FAT32).
*   `HealthStatus` — Stan woluminu.
*   `SizeRemaining` i `Size` — Wolne i całkowite miejsce.

#### Sprawdzanie i odzyskiwanie woluminu (odpowiednik `chkdsk`)

Polecenie cmdlet `Repair-Volume` to nowoczesny zamiennik narzędzia `chkdsk`.

**1. Sprawdzanie woluminu bez poprawek (tylko skanowanie)**

Ten tryb jest bezpieczny do wykonania na działającym systemie, wyszukuje tylko błędy.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Pełne skanowanie i naprawa błędów**

Ten tryb jest odpowiednikiem `chkdsk C: /f`. Blokuje on wolumin na czas działania, dlatego dla dysku systemowego wymagane będzie ponowne uruchomienie.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Ważne:** Jeśli uruchamiasz to polecenie dla dysku systemowego (C:), PowerShell zaplanuje sprawdzenie przy następnym uruchomieniu systemu. Aby uruchomić je natychmiast, uruchom ponownie komputer.

**Przykład:** Automatycznie sprawdź i napraw wszystkie woluminy, których stan różni się od `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Repairing volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Krok 3: Głęboka diagnostyka i S.M.A.R.T.

Jeśli podstawowe kontrole nie wykryły problemów, ale pozostały podejrzenia, można zagłębić się w temat.

#### Analiza dzienników systemowych

Błędy podsystemu dyskowego są często rejestrowane w dzienniku systemowym Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
Aby uzyskać dokładniejsze wyszukiwanie, można filtrować według źródła zdarzenia:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Sprawdzanie statusu S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) — technologia autodiagnostyki dysków. PowerShell umożliwia uzyskanie tych danych.

**Metoda 1: Użycie WMI (dla kompatybilności)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
Jeśli `PredictFailure = True`, dysk przewiduje rychłą awarię. Jest to sygnał do natychmiastowej wymiany.

**Metoda 2: Nowoczesne podejście przez CIM i moduły Storage**

Bardziej nowoczesny i szczegółowy sposób to użycie polecenia cmdlet `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
To polecenie cmdlet dostarcza cenne informacje, takie jak zużycie (aktualne dla dysków SSD), temperatura i liczba błędów odczytu/zapisu.

---

### Praktyczne scenariusze dla administratora systemu

Oto kilka gotowych przykładów do codziennych zadań.

**1. Uzyskaj krótki raport o stanie zdrowia wszystkich dysków fizycznych.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Utwórz raport CSV o wolnym miejscu na wszystkich woluminach.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Znajdź wszystkie partycje na konkretnym dysku (np. dysku 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Uruchom diagnostykę dysku systemowego z późniejszym ponownym uruchomieniem.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```