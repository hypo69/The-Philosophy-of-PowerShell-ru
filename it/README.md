![1](assets/cover.png)
# Filosofia di PowerShell

&nbsp;&nbsp;&nbsp;&nbsp;L'obiettivo di questa serie non è creare un'altra guida ai cmdlet.
L'idea chiave che svilupperò in tutti i capitoli è il passaggio dal pensiero testuale al **pensiero orientato agli oggetti**.
Invece di lavorare con stringhe non strutturate, vi insegnerò a operare con oggetti completi, con le loro proprietà e metodi,
passandoli attraverso la pipeline, come su una linea di assemblaggio in fabbrica.


&nbsp;&nbsp;&nbsp;&nbsp;Questa serie vi aiuterà a superare la semplice scrittura di comandi e ad acquisire un approccio ingegneristico consapevole a PowerShell,
come potente strumento per la dissezione del sistema operativo.

---

## 🗺️ Indice

### **Sezione I: Fondamenti e Basi**

*   **[Parte 0: Cosa c'era prima di PowerShell?](./01.md)**
    *   Excursus storico: `COMMAND.COM`, `AUTOEXEC.BAT`, `CONFIG.SYS`.
    *   Confronto con il mondo UNIX (`sh`, `csh`).
    *   Evoluzione di Windows: il kernel NT e gli strumenti di amministrazione frammentati.

*   **[Parte 1: Primo Avvio e Concetti Chiave](./01.md)**
    *   Il progetto Monad e la nascita di PowerShell.
    *   **L'idea principale:** Oggetti al posto del testo.
    *   Sintassi «Verbo-Nome».
    *   Il tuo assistente principale: `Get-Help`.

*   **[Parte 2: Pipeline, Variabili e Esplorazione degli Oggetti](./02.md)**
    *   Principi di funzionamento della pipeline (`|`).
    *   Lavorare con le variabili (`$var`, `$_`).
    *   Analisi degli oggetti con `Get-Member`.
    *   *Esempio di codice: [system_monitor.ps1](./code/02/system_monitor.ps1)*


*   **[Parte 3: Navigazione e Gestione del File System](./03.md)**
    *   Concetto di provider (`PSDrives`): file system, registro, certificati.
    *   Operatori di confronto e logici.
    *   Introduzione alle funzioni.
    *   *Esempi di codice: [Find-DuplicateFiles.ps1](./code/03/Find-DuplicateFiles.ps1), [Backup-FolderToZip.ps1](./code/03/Backup-FolderToZip.ps1)*

*   **[Parte 4: Lavoro Interattivo: `Out-ConsoleGridView`, `F7History` e `ConsoleGuiTools`**






    *   `Where-Object`: Filtro per oggetti.
    *   `Sort-Object`: Ordinamento dei dati.
    *   `Select-Object`: Selezione delle proprietà e creazione di campi calcolati.

*   **[Parte 5: Variabili e Tipi di Dati Base](./05.md)**
    *   Variabili come oggetti `PSVariable`.
    *   Ambiti (Scope).
    *   Lavorare con stringhe, array e tabelle hash.

### **Sezione III: Dagli Script agli Strumenti Professionali**

*   **[Parte 6: Fondamenti di Scripting. File `.ps1` e Politica di Esecuzione](./06.md)**
    *   Passaggio dalla console interattiva ai file `.ps1`.
    *   Politiche di esecuzione (`Execution Policy`): cosa sono e come configurarle.

*   **[Parte 7: Costrutti Logici e Cicli](./07.md)**
    *   Decisioni: `If / ElseIf / Else` e `Switch`.
    *   Ripetizione di azioni: cicli `ForEach`, `For`, `While`.

*   **[Parte 8: Funzioni — Creiamo i Nostri Cmdlet](./08.md)**
    *   Anatomia di una funzione avanzata: `[CmdletBinding()]`, `[Parameter()]`.
    *   Creazione della guida (`Comment-Based Help`).
    *   Elaborazione della pipeline: blocchi `begin`, `process`, `end`.

*   **[Parte 9: Lavorare con i Dati: CSV, JSON, XML](./09.md)**
    *   Importazione ed esportazione di dati tabellari con `Import-Csv` e `Export-Csv`.
    *   Lavorare con le API: `ConvertTo-Json` e `ConvertFrom-Json`.
    *   Nozioni di base sulla gestione XML.

*   **[Parte 10: Moduli e PowerShell Gallery](./10.md)**
    *   Organizzazione del codice in moduli: `.psm1` e `.psd1`.
    *   Importazione di moduli ed esportazione di funzioni.
    *   Utilizzo della libreria globale `PowerShell Gallery`.

### **Sezione IV: Tecniche Avanzate e Progetto Finale**

*   **[Parte 11: Gestione Remota e Attività in Background](./11.md)**
    *   Fondamenti di PowerShell Remoting (WinRM).
    *   Sessioni interattive (`Enter-PSSession`).
    *   Gestione di massa con `Invoke-Command`.
    *   Avvio di operazioni a lungo termine in background (`Start-Job`).

*   **[Parte 12: Introduzione alla GUI in PowerShell con Windows Forms](./12.md)**
    *   Creazione di finestre, pulsanti ed etichette.
    *   Gestione degli eventi (clic del pulsante).

*   **[Parte 13: Progetto "CPU-monitor" — Progettazione dell'Interfaccia](./13.md)**
    *   Composizione dell'interfaccia grafica.
    *   Configurazione dell'elemento `Chart` per la visualizzazione dei grafici.

*   **[Parte 14: Progetto "CPU-monitor" — Raccolta Dati e Logica](./14.md)**
    *   Acquisizione delle metriche di performance con `Get-Counter`.
    *   Utilizzo del timer per l'aggiornamento dei dati in tempo reale.

*   **[Parte 15: Progetto "CPU-monitor" — Assemblaggio Finale e Passi Successivi](./15.md)**
    *   Aggiunta della gestione degli errori (`Try...Catch`).
    *   Riepilogo e idee per ulteriori sviluppi.

---

## 🎯 A chi è rivolta questa serie?

*   **Ai principianti** che vogliono gettare solide e corrette basi nello studio di PowerShell, evitando errori comuni.
*   **Agli amministratori Windows esperti** che sono abituati a `cmd.exe` o VBScript e vogliono sistematizzare le proprie conoscenze, passando a uno strumento moderno e più potente.
*   **A tutti** coloro che vogliono imparare a pensare non in termini di comandi, ma di sistemi, e a creare script di automazione eleganti, affidabili e di facile manutenzione.

## ✍️ Feedback e Partecipazione

&nbsp;&nbsp;&nbsp;&nbsp;Se hai trovato un errore, un refuso o hai un suggerimento per migliorare una qualsiasi delle parti, non esitare a creare un **Issue** in questo repository.

## 📜 Licenza

&nbsp;&nbsp;&nbsp;&nbsp;Tutto il codice e i testi in questo repository sono distribuiti sotto la **[licenza MIT](./LICENSE)**. Puoi liberamente usare, modificare e distribuire i materiali con l'attribuzione dell'autore.