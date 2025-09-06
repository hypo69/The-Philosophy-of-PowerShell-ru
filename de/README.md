![1](assets/cover.png)
# PowerShell-Philosophie

&nbsp;&nbsp;&nbsp;&nbsp;Das Ziel dieser Serie ist es nicht, ein weiteres Cmdlet-Handbuch zu erstellen.
Die Schlüsselidee, die ich in allen Kapiteln entwickeln werde, ist der Übergang vom Textdenken zum **Objektdenken**.
Anstatt mit unstrukturierten Zeichenfolgen zu arbeiten, werde ich Ihnen beibringen, mit vollwertigen Objekten mit ihren Eigenschaften und Methoden zu operieren,
sie durch die Pipeline zu leiten, wie an einer Montagelinie in einer Fabrik.


&nbsp;&nbsp;&nbsp;&nbsp;Diese Serie wird Ihnen helfen, über das einfache Schreiben von Befehlen hinauszugehen und einen bewussten technischen Ansatz für PowerShell zu entwickeln,
als mächtiges Werkzeug zur Präparation des Betriebssystems.

---

## 🗺️ Inhaltsverzeichnis

### **Abschnitt I: Grundlagen und Basis**

*   **[Teil 0: Was war vor PowerShell?](./01.md)**
    *   Historischer Exkurs: `COMMAND.COM`, `AUTOEXEC.BAT`, `CONFIG.SYS`.
    *   Vergleich mit der UNIX-Welt (`sh`, `csh`).
    *   Evolution von Windows: NT-Kernel und fragmentierte Verwaltungstools.

*   **[Teil 1: Erster Start und Schlüsselkonzepte](./01.md)**
    *   Projekt Monad und die Geburt von PowerShell.
    *   **Hauptidee:** Objekte statt Text.
    *   Syntax „Verb-Nomen“.
    *   Ihr wichtigster Helfer: `Get-Help`.

*   **[Teil 2: Pipeline, Variablen und Objektuntersuchung](./02.md)**
    *   Prinzipien der Pipeline (`|`).
    *   Arbeit mit Variablen (`$var`, `$_`).
    *   Analyse von Objekten mit `Get-Member`.
    *   *Codebeispiel: [system_monitor.ps1](./code/02/system_monitor.ps1)*


*   **[Teil 3: Navigation und Dateisystemverwaltung](./03.md)**
    *   Konzept der Provider (`PSDrives`): Dateisystem, Registrierung, Zertifikate.
    *   Vergleichs- und Logikoperatoren.
    *   Einführung in Funktionen.
    *   *Codebeispiele: [Find-DuplicateFiles.ps1](./code/03/Find-DuplicateFiles.ps1), [Backup-FolderToZip.ps1](./code/03/Backup-FolderToZip.ps1)*

*   **[Teil 4: Interaktive Arbeit: `Out-ConsoleGridView`, `F7History` und `ConsoleGuiTools`**






    *   `Where-Object`: Sieb für Objekte.
    *   `Sort-Object`: Daten sortieren.
    *   `Select-Object`: Eigenschaften auswählen und berechnete Felder erstellen.

*   **[Teil 5: Variablen und grundlegende Datentypen](./05.md)**
    *   Variablen als `PSVariable`-Objekte.
    *   Geltungsbereiche (Scope).
    *   Arbeit mit Zeichenfolgen, Arrays und Hashtabellen.

### **Abschnitt III: Von Skripten zu professionellen Tools**

*   **[Teil 6: Grundlagen des Skriptings. `.ps1`-Dateien und Ausführungsrichtlinie](./06.md)**
    *   Übergang von der interaktiven Konsole zu `.ps1`-Dateien.
    *   Ausführungsrichtlinien (`Execution Policy`): Was sie sind und wie man sie konfiguriert.

*   **[Teil 7: Logische Konstrukte und Schleifen](./07.md)**
    *   Entscheidungsfindung: `If / ElseIf / Else` und `Switch`.
    *   Wiederholte Aktionen: Schleifen `ForEach`, `For`, `While`.

*   **[Teil 8: Funktionen — Eigene Cmdlets erstellen](./08.md)**
    *   Anatomie einer erweiterten Funktion: `[CmdletBinding()]`, `[Parameter()]`.
    *   Hilfe erstellen (`Comment-Based Help`).
    *   Pipeline-Verarbeitung: `begin`-, `process`- und `end`-Blöcke.

*   **[Teil 9: Arbeiten mit Daten: CSV, JSON, XML](./09.md)**
    *   Import und Export von Tabellendaten mit `Import-Csv` und `Export-Csv`.
    *   Arbeiten mit APIs: `ConvertTo-Json` und `ConvertFrom-Json`.
    *   Grundlagen der XML-Verarbeitung.

*   **[Teil 10: Module und PowerShell Gallery](./10.md)**
    *   Codeorganisation in Modulen: `.psm1` und `.psd1`.
    *   Import von Modulen und Export von Funktionen.
    *   Verwendung der globalen Bibliothek `PowerShell Gallery`.

### **Abschnitt IV: Fortgeschrittene Techniken und Abschlussprojekt**

*   **[Teil 11: Remote-Verwaltung und Hintergrundaufgaben](./11.md)**
    *   Grundlagen von PowerShell Remoting (WinRM).
    *   Interaktive Sitzungen (`Enter-PSSession`).
    *   Massenverwaltung mit `Invoke-Command`.
    *   Starten langwieriger Operationen im Hintergrund (`Start-Job`).

*   **[Teil 12: Einführung in GUI in PowerShell mit Windows Forms](./12.md)**
    *   Erstellen von Fenstern, Schaltflächen und Beschriftungen.
    *   Ereignisbehandlung (Schaltflächenklick).

*   **[Teil 13: Projekt "CPU-Monitor" — Schnittstellenentwurf](./13.md)**
    *   Zusammenstellung der grafischen Benutzeroberfläche.
    *   Konfiguration des `Chart`-Elements zur Anzeige von Diagrammen.

*   **[Teil 14: Projekt "CPU-Monitor" — Datenerfassung und Logik](./14.md)**
    *   Abrufen von Leistungsmetriken mit `Get-Counter`.
    *   Verwenden eines Timers zur Aktualisierung von Daten in Echtzeit.

*   **[Teil 15: Projekt "CPU-Monitor" — Endmontage und nächste Schritte](./15.md)**
    *   Hinzufügen der Fehlerbehandlung (`Try...Catch`).
    *   Zusammenfassung und Ideen für die weitere Entwicklung.

---

## 🎯 Für wen ist diese Serie?

*   **Für Anfänger**, die ein solides und korrektes Fundament im Erlernen von PowerShell legen möchten, um häufige Fehler zu vermeiden.
*   **Für erfahrene Windows-Administratoren**, die an `cmd.exe` oder VBScript gewöhnt sind und ihr Wissen systematisieren möchten, indem sie zu einem modernen und leistungsfähigeren Tool wechseln.
*   **Für alle**, die lernen möchten, nicht in Befehlen, sondern in Systemen zu denken und elegante, zuverlässige und leicht wartbare Automatisierungsskripte zu erstellen.

## ✍️ Feedback und Beteiligung

&nbsp;&nbsp;&nbsp;&nbsp;Wenn Sie einen Fehler, einen Tippfehler oder einen Verbesserungsvorschlag für einen der Teile gefunden haben, zögern Sie bitte nicht, ein **Issue** in diesem Repository zu erstellen.

## 📜 Lizenz

&nbsp;&nbsp;&nbsp;&nbsp;Der gesamte Code und die Texte in diesem Repository werden unter der **[MIT-Lizenz](./LICENSE)** verbreitet. Sie können die Materialien unter Angabe der Urheberschaft frei verwenden, ändern und verbreiten.