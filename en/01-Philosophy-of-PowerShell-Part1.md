# The Philosophy of PowerShell.
## Part 0.
What came before PowerShell?
In 1981, MS-DOS 1.0 was released with the `COMMAND.COM` command interpreter. For task automation, **batch files (`.bat`)** were used—simple text files with a sequence of console commands. This was a surprising level of command-line asceticism compared to POSIX-compatible systems, where the **Bourne shell (`sh`)** had existed since 1979.

### 📅 State of the Shell Market at the Time of MS-DOS 1.0's Release (August 1981)

Here is a summary table of popular OSes of that time and their shell support (`sh`, `csh`, etc.):

| Operating System | Shell Support (`sh`, `csh`, etc.) | Comment |
|---|---|---|
| **UNIX Version 7 (V7)** | `sh` | The last classic UNIX from Bell Labs, widely used |
| **UNIX/32V** | `sh`, `csh` | UNIX version for the VAX architecture |
| **4BSD / 3BSD** | `sh`, `csh` | University branch of UNIX from Berkeley |
| **UNIX System III** | `sh` | The first commercial version from AT&T, predecessor to System V |
| **Xenix (from Microsoft)** | `sh` | A licensed version of UNIX, sold by Microsoft since 1980 |
| **IDRIS** | `sh` | A UNIX-like OS for PDP-11 and Intel |
| **Coherent (Mark Williams)** | `sh` (similar) | An inexpensive UNIX alternative for PCs |
| **CP/M (Digital Research)** | ❌ (No `sh`, only a very basic CLI) | Not UNIX, the most popular OS for 8-bit PCs |
| **MS-DOS 1.0** | ❌ (only `COMMAND.COM`) | Minimal command shell, no scripts or pipes |

---

### 💡 What are `sh`, `csh`

* `sh` — **Bourne Shell**, the primary scripting interpreter for UNIX since 1977.
* `csh` — **C Shell**, an improved shell with C-like syntax and conveniences for interactive work.
* These shells **supported redirects, pipes, variables, functions, and conditions**—everything that made UNIX a powerful automation tool.

---

Microsoft targeted **cheap 16-bit IBM PCs**, which had **little memory** (usually 64–256 KB), no multitasking, and were intended for **home and office use**, not servers. UNIX was expensive, required a complex architecture and expertise, while accountants and engineers, not system administrators, needed a fast and simple OS.

Instead of the complex `sh`, the DOS interface provided a single file, command.com, with a meager set of internal commands [ (dir, copy, del, etc.)](https://www.techgeekbuzz.com/blog/dos-commands/){:target="_blank"} without functions, loops, or modules.

There were also external commands—separate executable files (.exe or .com). Examples: FORMAT.COM, XCOPY.EXE, CHKDSK.EXE, EDIT.COM.
Execution scripts were written in a text file with the .bat (batch file) extension.

Examples of configuration files:

- AUTOEXEC.BAT

```bash
:: ------------------------------------------------------------------------------
:: AUTOEXEC.BAT — Automatic configuration and startup of Windows 3.11
:: Author: hypo69
:: Year: approximately 1993
:: Purpose: Initializes the DOS environment, loads network drivers, and starts Windows 3.11
:: ------------------------------------------------------------------------------
@ECHO OFF

:: Set the command prompt
PROMPT $p$g

:: Set environment variables
SET TEMP=C:\TEMP
PATH=C:\DOS;C:\WINDOWS

:: Load drivers and utilities into high memory
LH C:\DOS\SMARTDRV.EXE       :: Disk cache
LH C:\DOS\MOUSE.COM          :: Mouse driver

:: Load network services (relevant for Windows for Workgroups 3.11)
IF EXIST C:\NET\NET.EXE LH C:\NET\NET START

:: Automatically start Windows
WIN
```
- CONFIG.SYS
```bash
:: ------------------------------------------------------------------------------
:: CONFIG.SYS — DOS memory and driver configuration for Windows 3.11
:: Author: hypo69
:: Year: approximately 1993
:: Purpose: Initializes memory drivers, configures system parameters
:: ------------------------------------------------------------------------------
DEVICE=C:\DOS\HIMEM.SYS
DEVICE=C:\DOS\EMM386.EXE NOEMS
DOS=HIGH,UMB
FILES=40
BUFFERS=30
DEVICEHIGH=C:\DOS\SETVER.EXE
```

In parallel with DOS, Microsoft almost immediately began developing a fundamentally new kernel.

The [**Windows NT**](https://www.wikiwand.com/ru/articles/Windows_NT){:target="_blank"} (New Technology) kernel first appeared with the release of the operating system:

> **Windows NT 3.1 — July 27, 1993**

---

* **Development began**: in **1988** under the leadership of **Dave Cutler** (a former DEC engineer and creator of VMS) with the goal of creating a completely new, secure, portable, and multitasking OS, not compatible with MS-DOS at the kernel level.
* **NT 3.1** — was named to emphasize compatibility with **Windows 3.1** at the interface level, but it was a **completely new architecture**.

---

#### 🧠 What the NT kernel brought:

| Feature | Description |
|---|---|
| **32-bit architecture** | Unlike MS-DOS and Windows 3.x, which were 16-bit. |
| **Multitasking** | True preemptive multitasking. |
| **Protected memory** | Programs could not corrupt each other's memory. |
| **Modularity** | Multi-layered kernel architecture: HAL, Executive, Kernel, drivers. |
| **Multi-platform support** | NT 3.1 ran on x86, MIPS, and Alpha. |
| **POSIX compatibility** | NT came with a **POSIX subsystem**, certified to POSIX.1. |

---

#### 📜 The NT Lineage:

| NT Version | Year | Comment |
|---|---|---|
| NT 3.1 | 1993 | First NT release |
| NT 3.5 / 3.51 | 1994–1995 | Improvements, optimization |
| NT 4.0 | 1996 | Windows 95 interface, but NT kernel |
| Windows 2000 | 2000 | NT 5.0 |
| Windows XP | 2001 | NT 5.1 |
| Windows Vista | 2007 | NT 6.0 |
| Windows 10 | 2015 | NT 10.0 |
| Windows 11 | 2021 | Also NT 10.0 (marketing 😊) |

---

Difference in operating system capabilities:

| Characteristic | **MS-DOS** (1981) | **Windows NT** (1993) |
|---|---|---|
| **System type** | Monolithic, single-tasking | Microkernel/hybrid, multitasking |
| **Bitness** | 16-bit | 32-bit (with 64-bit support since NT 5.2 / XP x64) |
| **Multitasking** | ❌ Absent (one process at a time) | ✅ Preemptive multitasking |
| **Protected memory** | ❌ No | ✅ Yes (each process in its own address space) |
| **Multi-user mode** | ❌ No | ✅ Partially (in NT Workstation/Server) |
| **POSIX compatibility** | ❌ No | ✅ Built-in POSIX subsystem in NT 3.1–5.2 |
| **Kernel portability** | ❌ x86 only | ✅ x86, MIPS, Alpha, PowerPC |
| **Drivers** | Direct hardware access | Through HAL and Kernel-mode Drivers |
| **Application access level** | Applications = system level | User / Kernel level separated |
| **Security** | ❌ Absent | ✅ Security model: SID, ACL, access tokens |
| **Stability** | ❌ Dependency of one program = OS crash | ✅ Process isolation, kernel protection |

---

But there was one big BUT! Automation and administration tools were not given due attention until 2002.

---
 
Microsoft used completely different approaches, strategies, and tools for administration. All of this was **disparate**, often GUI-oriented, and not always automatable.

---

##### 📌 List of some tools:

| Tool | Purpose |
|---|---|
| `cmd.exe` | Improved command interpreter (replacement for `COMMAND.COM`) |
| `.bat`, `.cmd` | Command-line scripts |
| **Windows Script Host (WSH)** | Support for VBScript and JScript for automation |
| `reg.exe` | Manage the registry from the command line |
| `net.exe` | Work with users, network, printers |
| `sc.exe` | Manage services |
| `tasklist`, `taskkill` | Manage processes |
| `gpedit.msc` | Group Policy (local) |
| `MMC` | Console with snap-ins for management |
| `WMI` | Access system information (via `wmic`, VBScript, or COM) |
| `WbemTest.exe` | GUI for testing WMI queries |
| `eventvwr` | View event logs |
| `perfmon` | Monitor resources |

##### 🛠 Automation examples:

* VBScript files (`*.vbs`) for administering users, networks, printers, and services.
* `WMIC` — command-line interface to WMI (e.g.: `wmic process list brief`).
* `.cmd` scripts with calls to `net`, `sc`, `reg`, `wmic`, etc.

---

### ⚙️ Windows Scripting Host (WSH)

* First appeared in **Windows 98**, actively used in **Windows 2000 and XP**.
* Allowed running VBScript and JScript files from the command line:

  ```vbscript
  Set objShell = WScript.CreateObject("WScript.Shell")
  objShell.Run "notepad.exe"
  ```

---
## Part 1.

Only in 2002 did the company formulate the <a href="https://learn.microsoft.com/en-us/powershell/scripting/developer/monad-manifesto?view=powershell-7.5" target="_blank">Monad</a> project, which later evolved into PowerShell:

Start of development: approximately 2002

Public announcement: 2003, as "Monad Shell"

First beta versions: appeared by 2005

Final release (PowerShell 1.0): November 2006

 The author and chief architect of the Monad / PowerShell project is Jeffrey Snover
 <a href="https://www.wikiwand.com/en/articles/Jeffrey_Snover" target="_blank"> (Jeffrey Snover)</a>
 
Today PowerShell Core runs on
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/windows-core.md" target="_blank">Windows</a>
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/macos.md" target="_blank">macOS</a>
<a href="https://github.com/PowerShell/PowerShell/blob/master/docs/building/linux.md" target="_blank">Linux</a>

 
In parallel, the .NET framework was being developed, and PowerShell was deeply integrated into it. In the following chapters, I will show examples.

And now — the most important thing!

The main advantage of PowerShell compared to classic command shells is that it works with *objects*, not text. When you execute a command, it returns not just text, but a structured object (or a collection of objects) with clearly defined properties and methods.

See how PowerShell surpasses classic shells thanks to **working with objects**

### 📁 The old way: `dir` and manual parsing

In **CMD** (both in the old `COMMAND.COM` and in `cmd.exe`), the `dir` command returns the result as plain text. Example output:

```
07/24/2025  09:15 PM         1,428  my_script.js
07/25/2025  08:01 AM         3,980  report.html
```

Suppose you want to extract the **filename** and **size** of each file. You would have to parse the strings manually:
```cmd
for /f "tokens=5,6" %a in ('dir ^| findstr /R "[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]"') do @echo %a %b
```

* This is terribly difficult to read, depends on the locale, date format, and font. And it breaks with spaces in the names.

---

### ✅ PowerShell: objects instead of text

#### ✔ Simple and readable example:

```powershell
Get-ChildItem | Select-Object Name, Length
```

**Result:**

```
Name          Length
----          ------
my_script.js   1428
report.html    3980
```

* `Get-ChildItem` returns an **array of file/folder objects**
* `Select-Object` allows you to easily get the required **properties**

---

### 🔍 What does `Get-ChildItem` actually return?

```powershell
$item = Get-ChildItem -Path .\my_script.js
$item | Get-Member
```

**Result:**

```
TypeName: System.IO.FileInfo

Name         MemberType     Definition
----         ---------      ----------
Length       Property       long Length {get;}
Name         Property       string Name {get;}
CreationTime Property       datetime CreationTime {get;set;}
Delete       Method         void Delete()
...
```

PowerShell returns **`System.IO.FileInfo` objects**, which have:

* 🧱 Properties (`Name`, `Length`, `CreationTime`, `Extension`, …)
* 🛠 Methods (`Delete()`, `CopyTo()`, `MoveTo()`, etc.)

You work **with full-fledged objects**, not with strings.

---

### "Verb-Noun" Syntax:

PowerShell uses a **strict and logical command syntax**:
`Verb-Noun`

| Verb | What it does |
|---|---|
| `Get-` | Get |
| `Set-` | Set |
| `New-` | Create |
| `Remove-` | Delete |
| `Start-` | Start |
| `Stop-` | Stop |

| Noun | What it works on |
|---|---|
| `Process` | Process |
| `Service` | Service |
| `Item` | File/folder |
| `EventLog` | Event logs |
| `Computer` | Computer |

#### 🔄 Examples:

| What to do | Command |
|---|---|
| Get processes | `Get-Process` |
| Stop a service | `Stop-Service` |
| Create a new file | `New-Item` |
| Get folder contents | `Get-ChildItem` |
| Delete a file | `Remove-Item` |

➡ Even if you **don't know the exact command**, you can **guess** it from the meaning — and you'll almost always be right.

---

The `Get-Help` cmdlet is your main assistant.

1.  **Get help about help itself:**
    ```powershell
    Get-Help Get-Help
    ```
2.  **Get basic help about the command for working with processes:**
    ```powershell
    Get-Help Get-Process
    ```
3.  **See examples of how to use this command:**
    ```powershell
    Get-Help Get-Process -Examples
    ```
    This is an incredibly useful parameter that often provides ready-made solutions for your tasks.
4.  **Get the most detailed information about the command:**
    ```powershell
    Get-Help Get-Process -Full
    ```
In the next part: the pipeline or command chain (PipeLines)
