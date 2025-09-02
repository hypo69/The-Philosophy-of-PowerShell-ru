![1](assets/cover.png)
# The Philosophy of PowerShell

&nbsp;&nbsp;&nbsp;&nbsp;The goal of this series is not to create another cmdlet reference. 
The key idea that I will be developing throughout all chapters is the transition from thinking in text to **thinking in objects**. 
Instead of working with unstructured strings, I will teach you how to operate with full-fledged objects with their properties and methods, 
passing them through the pipeline, like on an assembly line in a factory.


&nbsp;&nbsp;&nbsp;&nbsp;This series will help you go beyond simply writing commands and acquire a conscious engineering approach to PowerShell,
as a powerful tool for dissecting the operating system.

---

## 🗺️ Table of Contents

### **Section I: Foundation and Basics**

*   **[Part 0: What came before PowerShell?](./01.md)**
    *   Historical excursion: `COMMAND.COM`, `AUTOEXEC.BAT`, `CONFIG.SYS`.
    *   Comparison with the UNIX world (`sh`, `csh`).
    *   Evolution of Windows: NT kernel and disparate administration tools.

*   **[Part 1: First launch and key concepts](./01.md)**
    *   The Monad project and the birth of PowerShell.
    *   **Main idea:** Objects instead of text.
    *   "Verb-Noun" syntax.
    *   Your main assistant: `Get-Help`.

*   **[Part 2: Pipeline, variables, and object exploration](./02.md)**
    *   Principles of pipeline operation (`|`).
    *   Working with variables (`$var`, `$_`).
    *   Analyzing objects with `Get-Member`.
    *   *Code example: [system_monitor.ps1](./code/02/system_monitor.ps1)*


*   **[Part 3: File system navigation and management](./03.md)**
    *   The concept of providers (`PSDrives`): file system, registry, certificates.
    *   Comparison and logic operators.
    *   Introduction to functions.
    *   *Code examples: [Find-DuplicateFiles.ps1](./code/03/Find-DuplicateFiles.ps1), [Backup-FolderToZip.ps1](./code/03/Backup-FolderToZip.ps1)*

*   **[Part 4: Interactive work: `Out-ConsoleGridView`, `F7History` and `ConsoleGuiTools`**






    *   `Where-Object`: A sieve for objects.
    *   `Sort-Object`: Ordering data.
    *   `Select-Object`: Selecting properties and creating calculated fields.

*   **[Part 5: Variables and basic data types](./05.md)**
    *   Variables as `PSVariable` objects.
    *   Scopes.
    *   Working with strings, arrays, and hash tables.

### **Section III: From Scripts to Professional Tools**

*   **[Part 6: Scripting basics. `.ps1` files and execution policy](./06.md)**
    *   Transition from interactive console to `.ps1` files.
    *   Execution Policies: what they are and how to configure them.

*   **[Part 7: Logical constructs and loops](./07.md)**
    *   Decision making: `If / ElseIf / Else` and `Switch`.
    *   Repeating actions: `ForEach`, `For`, `While` loops.

*   **[Part 8: Functions — creating your own cmdlets](./08.md)**
    *   Anatomy of an advanced function: `[CmdletBinding()]`, `[Parameter()]`.
    *   Creating help (`Comment-Based Help`).
    *   Pipeline processing: `begin`, `process`, `end` blocks.

*   **[Part 9: Working with data: CSV, JSON, XML](./09.md)**
    *   Importing and exporting tabular data with `Import-Csv` and `Export-Csv`.
    *   Working with APIs: `ConvertTo-Json` and `ConvertFrom-Json`.
    *   Basics of working with XML.

*   **[Part 10: Modules and PowerShell Gallery](./10.md)**
    *   Organizing code into modules: `.psm1` and `.psd1`.
    *   Importing modules and exporting functions.
    *   Using the global `PowerShell Gallery` library.

### **Section IV: Advanced Techniques and Final Project**

*   **[Part 11: Remote management and background tasks](./11.md)**
    *   PowerShell Remoting basics (WinRM).
    *   Interactive sessions (`Enter-PSSession`).
    *   Bulk management with `Invoke-Command`.
    *   Running long-running operations in the background (`Start-Job`).

*   **[Part 12: Introduction to GUI in PowerShell with Windows Forms](./12.md)**
    *   Creating windows, buttons, and labels.
    *   Event handling (button click).

*   **[Part 13: "CPU Monitor" Project — Interface Design](./13.md)**
    *   GUI layout.
    *   Configuring the `Chart` element for displaying graphs.

*   **[Part 14: "CPU Monitor" Project — Data Collection and Logic](./14.md)**
    *   Getting performance metrics with `Get-Counter`.
    *   Using a timer to update data in real time.

*   **[Part 15: "CPU Monitor" Project — Final Assembly and Next Steps](./15.md)**
    *   Adding error handling (`Try...Catch`).
    *   Summary and ideas for further development.

---

## 🎯 Who is this series for?

*   **For beginners** who want to lay a solid and correct foundation in learning PowerShell, avoiding common mistakes.
*   **For experienced Windows administrators** who are used to `cmd.exe` or VBScript and want to systematize their knowledge by switching to a modern and more powerful tool.
*   **For everyone** who wants to learn to think not in commands, but in systems, and create elegant, reliable, and easily maintainable automation scripts.

## ✍️ Feedback and Participation

&nbsp;&nbsp;&nbsp;&nbsp;If you find an error, typo, or have a suggestion for improving any part, please feel free to create an **Issue** in this repository.

## 📜 License

&nbsp;&nbsp;&nbsp;&nbsp;All code and texts in this repository are distributed under the **[MIT license](./LICENSE)**. You are free to use, modify, and distribute the materials with attribution.
