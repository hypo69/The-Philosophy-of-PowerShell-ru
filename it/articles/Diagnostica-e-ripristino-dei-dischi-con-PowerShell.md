### Diagnostica e ripristino dei dischi con PowerShell

PowerShell consente di automatizzare i controlli, eseguire la diagnostica remota e creare script flessibili per il monitoraggio. Questa guida vi condurrà dalle verifiche di base alla diagnostica approfondita e al ripristino dei dischi.

**Versione:** La guida è valida per **Windows 10/11** e **Windows Server 2016+**.

### Cmdlet chiave per la gestione dei dischi

| Cmdlet | Scopo |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Informazioni sui dischi fisici (modello, stato di salute). |
| **`Get-Disk`** | Informazioni sui dischi a livello di dispositivo (stato Online/Offline, stile delle partizioni). |
| **`Get-Partition`** | Informazioni sulle partizioni sui dischi. |
| **`Get-Volume`** | Informazioni sui volumi logici (lettere di unità, file system, spazio libero). |
| **`Repair-Volume`** | Controllo e ripristino dei volumi logici (analogo a `chkdsk`). |
| **`Get-StoragePool`** | Utilizzato per lavorare con gli spazi di archiviazione (Storage Spaces). |

---

### Passaggio 1: Controllo di base dello stato del sistema

Iniziare con una valutazione generale dello stato del sottosistema disco.

#### Visualizzazione di tutti i dischi collegati

Il comando `Get-Disk` fornisce informazioni riassuntive su tutti i dischi visti dal sistema operativo.

```powershell
Get-Disk
```

Verrà visualizzata una tabella con i numeri dei dischi, le loro dimensioni, lo stato (`Online` o `Offline`) e lo stile delle partizioni (`MBR` o `GPT`).

**Esempio:** Trova tutti i dischi che sono offline.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Controllo della "salute" fisica dei dischi

Il cmdlet `Get-PhysicalDisk` accede allo stato dell'hardware stesso.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Prestare particolare attenzione al campo `HealthStatus`. Può assumere i seguenti valori:
*   **Healthy:** Il disco è a posto.
*   **Warning:** Ci sono problemi, è necessaria attenzione (ad esempio, superamento delle soglie S.M.A.R.T.).
*   **Unhealthy:** Il disco è in condizioni critiche e potrebbe guastarsi.

---

### Passaggio 2: Analisi e ripristino dei volumi logici

Dopo aver controllato lo stato fisico, passiamo alla struttura logica – volumi e file system.

#### Informazioni sui volumi logici

Il comando `Get-Volume` mostra tutti i volumi montati nel sistema.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Campi chiave:
*   `DriveLetter` — Lettera del volume (C, D, ecc.).
*   `FileSystem` — Tipo di file system (NTFS, ReFS, FAT32).
*   `HealthStatus` — Stato del volume.
*   `SizeRemaining` e `Size` — Spazio libero e totale.

#### Controllo e ripristino del volume (analogo a `chkdsk`)

Il cmdlet `Repair-Volume` è un sostituto moderno dell'utilità `chkdsk`.

**1. Controllo del volume senza correzioni (solo scansione)**

Questa modalità è sicura da eseguire su un sistema funzionante, cerca solo errori.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Scansione completa e correzione degli errori**

Questa modalità è analoga a `chkdsk C: /f`. Blocca il volume durante l'operazione, quindi per il disco di sistema sarà necessario un riavvio.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Importante:** Se si esegue questo comando per il disco di sistema (C:), PowerShell pianificherà un controllo al successivo avvio del sistema. Per eseguirlo immediatamente, riavviare il computer.

**Esempio:** Controllare e correggere automaticamente tutti i volumi il cui stato è diverso da `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Repairing volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Passaggio 3: Diagnostica approfondita e S.M.A.R.T.

Se i controlli di base non hanno rivelato problemi, ma i sospetti persistono, è possibile approfondire.

#### Analisi dei registri di sistema

Gli errori del sottosistema disco vengono spesso registrati nel registro di sistema di Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
Per una ricerca più precisa, è possibile filtrare per origine dell'evento:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Controllo dello stato S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) — tecnologia di autodiagnostica dei dischi. PowerShell consente di ottenere questi dati.

**Metodo 1: Utilizzo di WMI (per compatibilità)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
Se `PredictFailure = True`, il disco prevede un guasto imminente. Questo è un segnale per una sostituzione immediata.

**Metodo 2: Approccio moderno tramite CIM e moduli Storage**

Un metodo più moderno e dettagliato è l'utilizzo del cmdlet `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
Questo cmdlet fornisce informazioni preziose, come l'usura (rilevante per gli SSD), la temperatura e il numero di errori di lettura/scrittura.

---

### Scenari pratici per l'amministratore di sistema

Ecco alcuni esempi pronti per le attività quotidiane.

**1. Ottenere un breve rapporto sullo stato di salute di tutti i dischi fisici.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Creare un rapporto CSV sullo spazio libero su tutti i volumi.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Trovare tutte le partizioni su un disco specifico (ad esempio, disco 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Avviare la diagnostica del disco di sistema con riavvio successivo.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```