### **Esempi pratici di utilizzo di Out-ConsoleGridView**

Nel capitolo precedente abbiamo conosciuto `Out-ConsoleGridView` — un potente strumento per lavorare interattivamente con i dati direttamente nel terminale. Se non sapete di cosa si tratta, vi consiglio di leggere prima.
Questo articolo è interamente dedicato ad esso. Non ripeterò la teoria, ma passerò subito alla pratica e mostrerò 10 scenari in cui questo cmdlet può far risparmiare un sacco di tempo a un amministratore di sistema o a un utente avanzato.

`Out-ConsoleGridView` — è un **filtro interattivo di oggetti** nel mezzo della vostra pipeline.

**Prerequisiti:**
*   PowerShell 7.2 o versioni successive.
*   Modulo `Microsoft.PowerShell.ConsoleGuiTools` installato. Se non l'avete ancora installato:
    ```powershell
    Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
    ```

---

### 10 esempi pratici

#### Esempio 1: Arresto interattivo dei processi

Un compito classico: trovare e terminare diversi processi "bloccati" o non necessari.

```powershell
# Selezioniamo i processi in modalità interattiva
$procsToStop = Get-Process | Sort-Object -Property CPU -Descending | Out-ConsoleGridView -OutputMode Multiple

# Se qualcosa è stato selezionato, passiamo gli oggetti per l'arresto
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```

(https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  `Get-Process` ottiene tutti i processi in esecuzione.
2.  `Sort-Object` li ordina per carico CPU, in modo che i più "affamati" siano in cima.
3.  `Out-ConsoleGridView` visualizza la tabella. Potete digitare `chrome` o `notepad` per filtrare istantaneamente l'elenco e selezionare i processi desiderati con il tasto `Spazio`.
4.  Dopo aver premuto `Invio`, gli **oggetti** dei processi selezionati vengono inseriti nella variabile `$procsToStop` e passati a `Stop-Process`.

#### Esempio 2: Gestione dei servizi Windows

È necessario riavviare rapidamente diversi servizi associati a una singola applicazione (ad esempio, SQL Server).

```powershell
$services = Get-Service | Out-ConsoleGridView -OutputMode Multiple -Title "Seleziona i servizi da riavviare"

if ($services) {
    $services | Restart-Service -WhatIf
}
```

(https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Si ottiene un elenco di tutti i servizi.
2.  All'interno di `Out-ConsoleGridView` si digita `sql` nel filtro e si vedono immediatamente tutti i servizi relativi a SQL Server.
3.  Si selezionano quelli desiderati e si preme `Invio`. Gli oggetti dei servizi selezionati vengono passati per il riavvio.

#### Esempio 3: Pulizia della cartella "Download" da file di grandi dimensioni

Con il tempo, la cartella "Download" si riempie di file non necessari. Troviamo ed eliminiamo i più grandi.

```powershell

# --- PASSO 1: Configurazione del percorso della directory 'Downloads'
$DownloadsPath = "E:\Users\user\Downloads" # <--- MODIFICARE QUESTA RIGA CON IL VOSTRO PERCORSO
===========================================================================

# Controllo: se il percorso non è specificato o la cartella non esiste - usciamo.
if ([string]::IsNullOrEmpty($DownloadsPath) -or (-not (Test-Path -Path $DownloadsPath))) {
    Write-Error "La cartella 'Download' non è stata trovata nel percorso specificato: '$DownloadsPath'. Si prega di controllare il percorso nel blocco CONFIGURAZIONE all'inizio dello script."
    return
}

# --- PASSO 2: Informazione all'utente e raccolta dati ---
Write-Host "Avvio della scansione della cartella '$DownloadsPath'. Potrebbe richiedere del tempo..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $DownloadsPath -File -Recurse -ErrorAction SilentlyContinue | 
    Sort-Object -Property Length -Descending

# --- PASSO 3: Controllo della presenza di file e richiamo della finestra interattiva ---
if ($files) {
    Write-Host "Scansione completata. Trovati $($files.Count) file. Apertura della finestra di selezione..." -ForegroundColor Green
    
    $filesToShow = $files | Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime
    
    $filesToDelete = $filesToShow | Out-ConsoleGridView -OutputMode Multiple -Title "Seleziona i file da eliminare da '$DownloadsPath'"

    # --- PASSO 4: Elaborazione della selezione dell'utente ---
    if ($filesToDelete) {
        Write-Host "I seguenti file verranno eliminati:" -ForegroundColor Yellow
        $filesToDelete | Format-Table -AutoSize
        
        $filesToDelete.FullName | Remove-Item -WhatIf -Verbose
    } else {
        Write-Host "Operazione annullata. Nessun file selezionato." -ForegroundColor Yellow
    }
} else {
    Write-Host "Nessun file trovato nella cartella '$DownloadsPath'." -ForegroundColor Yellow
}
```
[Clear-DownloadsFolder.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/scripts/Clear-DownloadsFolder.ps1)

[Contenuto Download](https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Otteniamo tutti i file, li ordiniamo per dimensione e, usando `Select-Object`, creiamo una comoda colonna `SizeMB`.
2.  In `Out-ConsoleGridView` vedete un elenco ordinato, dove è facile selezionare file `.iso` o `.zip` vecchi e grandi.
3.  Dopo la selezione, i loro percorsi completi vengono passati a `Remove-Item`.

#### Esempio 4: Aggiunta di utenti a un gruppo di Active Directory

Una cosa indispensabile per gli amministratori AD.

```powershell
# Otteniamo gli utenti del dipartimento Marketing
$users = Get-ADUser -Filter 'Department -eq "Marketing"' -Properties DisplayName

# Selezioniamo interattivamente chi aggiungere
$usersToAdd = $users | Select-Object Name, DisplayName | Out-ConsoleGridView -OutputMode Multiple

if ($usersToAdd) {
    Add-ADGroupMember -Identity "Marketing-Global-Group" -Members $usersToAdd -WhatIf
}
```

Invece di digitare manualmente i nomi utente, si ottiene un comodo elenco in cui è possibile trovare e selezionare rapidamente i dipendenti desiderati per cognome o login.

---

#### Esempio 5: Scoprire quali programmi stanno usando internet in questo momento

Uno dei compiti frequenti: "Quale programma sta rallentando internet?" o "Chi e dove sta inviando dati?". Con `Out-ConsoleGridView` è possibile ottenere una risposta chiara e interattiva.

**All'interno della tabella:**
*   **Digitate `chrome` o `msedge`** nel campo del filtro per vedere tutte le connessioni attive del vostro browser.
*   **Digitate un indirizzo IP** (ad esempio, `151.101.1.69` dalla colonna `RemoteAddress`) per vedere quali altri processi sono connessi allo stesso server.

```powershell
# Otteniamo tutte le connessioni TCP attive
$connections = Get-NetTCPConnection -State Established | 
    Select-Object RemoteAddress, RemotePort, OwningProcess, @{Name="ProcessName"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

# Visualizziamo in una tabella interattiva per l'analisi
$connections | Out-ConsoleGridView -Title "Connessioni internet attive"
```

1.  `Get-NetTCPConnection -State Established` raccoglie tutte le connessioni di rete stabilite.
2.  Con `Select-Object` formiamo un report conveniente: aggiungiamo il nome del processo (`ProcessName`) al suo ID (`OwningProcess`) per capire quale programma ha stabilito la connessione.
3.  `Out-ConsoleGridView` vi mostra un'immagine in tempo reale dell'attività di rete.

[Net](https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

### Esempio 6: Analisi dell'installazione e degli aggiornamenti del software

Cercheremo eventi dalla sorgente **"MsiInstaller"**. È responsabile dell'installazione, dell'aggiornamento e della rimozione della maggior parte dei programmi (in formato `.msi`), nonché di molti componenti degli aggiornamenti di Windows.

```powershell
# Cerchiamo gli ultimi 100 eventi dell'installatore di Windows (MsiInstaller)
# Questi eventi sono presenti su qualsiasi sistema
$installEvents = Get-WinEvent -ProviderName 'MsiInstaller' -MaxEvents 100

# Se gli eventi sono stati trovati, li visualizziamo in un formato conveniente
if ($installEvents) {
    $installEvents | 
        # Selezioniamo solo le informazioni più utili: ora di creazione, ID e messaggio
        # ID 11707 - installazione riuscita, ID 11708 - installazione fallita
        Select-Object TimeCreated, Id, Message |
        Out-ConsoleGridView -Title "Registro installazione programmi (MsiInstaller)"
} else {
    Write-Warning "Nessun evento trovato da 'MsiInstaller'. Questo è molto insolito."
}
```

**All'interno della tabella:**
*   È possibile filtrare l'elenco per nome del programma (ad esempio, `Edge` o `Office`) per vedere l'intera cronologia dei suoi aggiornamenti.
*   È possibile ordinare per `Id` per trovare installazioni fallite (`11708`).

---

#### Esempio 7: Disinstallazione interattiva dei programmi

```powershell
# Percorsi nel registro dove sono memorizzate le informazioni sui programmi installati
$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Raccogliamo i dati dal registro, rimuovendo i componenti di sistema che non hanno un nome
$installedPrograms = Get-ItemProperty $registryPaths | 
    Where-Object { $_.DisplayName -and $_.UninstallString } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

# Se i programmi sono stati trovati, li visualizziamo in una tabella interattiva
if ($installedPrograms) {
    $programsToUninstall = $installedPrograms | Out-ConsoleGridView -OutputMode Multiple -Title "Seleziona i programmi da disinstallare"
    
    if ($programsToUninstall) {
        Write-Host "I seguenti programmi verranno disinstallati:" -ForegroundColor Yellow
        $programsToUninstall | Format-Table -AutoSize
        
        # Questo blocco è più complesso, poiché Uninstall-Package qui non funzionerà.
        # Eseguiamo il comando di disinstallazione dal registro.
        foreach ($program in $programsToUninstall) {
            # Troviamo l'oggetto programma originale con la stringa di disinstallazione
            $fullProgramInfo = Get-ItemProperty $registryPaths | Where-Object { $_.DisplayName -eq $program.DisplayName }
            
            if ($fullProgramInfo.UninstallString) {
                Write-Host "Avvio del disinstallatore per '$($program.DisplayName)'..." -ForegroundColor Yellow
                # ATTENZIONE: Questo avvierà il disinstallatore GUI standard del programma.
                # WhatIf qui non funzionerà, fate attenzione.
                # cmd.exe /c $fullProgramInfo.UninstallString
            }
        }
        Write-Warning "Per disinstallare realmente i programmi, decommentate la riga 'cmd.exe /c ...' nello script."
    }
} else {
    Write-Warning "Impossibile trovare programmi installati nel registro."
}
```

---

Avete assolutamente ragione. L'esempio con Active Directory non è adatto all'utente comune e richiede un ambiente speciale.

Sostituiamolo con uno scenario molto più universale e comprensibile, che dimostra perfettamente la potenza del concatenamento di `Out-ConsoleGridView` e sarà utile a qualsiasi utente.

---

#### Esempio 8: Concatenamento (Chaining) di `Out-ConsoleGridView`

Questa è la tecnica più potente. L'output di una sessione interattiva diventa l'input per un'altra. **Compito:** Selezionare una delle vostre cartelle di progetto, quindi selezionare da essa file specifici per creare un archivio ZIP.

```powershell
# --- PASSO 1: Troviamo universalmente la cartella "Documenti" ---
$SearchPath = [System.Environment]::GetFolderPath('MyDocuments')

# --- PASSO 2: Selezioniamo interattivamente una cartella dal percorso specificato ---
$selectedFolder = Get-ChildItem -Path $SearchPath -Directory | 
    Out-ConsoleGridView -Title "Seleziona la cartella da archiviare"

if ($selectedFolder) {
    # --- PASSO 3: Se la cartella è stata selezionata, otteniamo i suoi file e selezioniamo quali archiviare ---
    $filesToArchive = Get-ChildItem -Path $selectedFolder.FullName -File | 
        Out-ConsoleGridView -OutputMode Multiple -Title "Seleziona i file per l'archivio da '$($selectedFolder.Name)'"

    if ($filesToArchive) {
        # --- PASSO 4: Eseguiamo l'azione con percorsi universali ---
        $archiveName = "Archive-$($selectedFolder.Name)-$(Get-Date -Format 'yyyy-MM-dd').zip"
        
        # MODO UNIVERSALE PER OTTENERE IL PERCORSO DEL DESKTOP
        $desktopPath = [System.Environment]::GetFolderPath('Desktop')
        $destinationPath = Join-Path -Path $desktopPath -ChildPath $archiveName
        
        # Creiamo l'archivio
        Compress-Archive -Path $filesToArchive.FullName -DestinationPath $destinationPath -WhatIf
        
        Write-Host "L'archivio '$archiveName' verrà creato sul tuo desktop nel percorso '$destinationPath'." -ForegroundColor Green
    }
}
```

1.  Il primo `Out-ConsoleGridView` vi mostra un elenco di cartelle all'interno dei vostri "Documenti". Potete trovare rapidamente quella desiderata digitando parte del suo nome e selezionare **una** cartella.
2.  Se una cartella è stata selezionata, lo script apre immediatamente un **secondo** `Out-ConsoleGridView`, che mostra i **file all'interno** di quella cartella.
3.  Selezionate **uno o più** file con il tasto `Spazio` e premete `Invio`.
4.  Lo script prende i file selezionati e crea un archivio ZIP sul vostro desktop.

Questo trasforma un compito complesso a più passaggi (trovare una cartella, trovare file al suo interno, copiare i loro percorsi, eseguire il comando di archiviazione) in un processo interattivo intuitivo in due passaggi.

#### Esempio 9: Gestione dei componenti opzionali di Windows

```powershell
# --- Esempio 9: Gestione dei componenti opzionali di Windows ---

# Otteniamo solo i componenti abilitati
$features = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }

$featuresToDisable = $features | Select-Object FeatureName, DisplayName | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Seleziona i componenti da disabilitare"

if ($featuresToDisable) {
    # AVVERTIAMO L'UTENTE DELL'IRREVERSIBILITÀ
    Write-Host "ATTENZIONE! I seguenti componenti verranno immediatamente disabilitati." -ForegroundColor Red
    Write-Host "Questa operazione non supporta la modalità sicura -WhatIf."
    $featuresToDisable | Select-Object DisplayName

    # Richiediamo conferma manualmente
    $confirmation = Read-Host "Continuare? (s/n)"
    
    if ($confirmation -eq 's') {
        foreach($feature in $featuresToDisable){
            Write-Host "Disabilitazione del componente '$($feature.DisplayName)'..." -ForegroundColor Yellow
            Disable-WindowsOptionalFeature -Online -FeatureName $feature.FeatureName
        }
        Write-Host "Operazione completata. Potrebbe essere necessario un riavvio." -ForegroundColor Green
    } else {
        Write-Host "Operazione annullata."
    }
}
```

Potete facilmente trovare e disabilitare componenti non necessari, come `Telnet-Client` o `Windows-Sandbox`.

#### Esempio 10: Gestione delle macchine virtuali Hyper-V

Arrestare rapidamente diverse macchine virtuali per la manutenzione dell'host.

```powershell
# Otteniamo solo le VM in esecuzione
$vms = Get-VM | Where-Object { $_.State -eq 'Running' }

$vmsToStop = $vms | Select-Object Name, State, Uptime | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Seleziona le VM da arrestare"

if ($vmsToStop) {
    $vmsToStop | Stop-VM -WhatIf
}
```

Si ottiene un elenco delle sole macchine in esecuzione e si possono selezionare interattivamente quelle che devono essere spente in sicurezza.