# PowerShell Philosophy.

### **Part 3: File System Navigation and Management. Logic Operators. Introduction to Functions.**

In the [previous part](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/01.md) we explored pipelines and abstract process objects.
Now let's apply our knowledge of pipelines and objects to one of the common tasks of a user or administrator—working with the file system.
In PowerShell, this work is built on the same principles: commands return objects that can be piped for further processing.



***


### **1. The Concept of PowerShell Drives (PSDrives)**

Before you start working with files, it's important to understand the concept of **PowerShell Drives (PSDrives)**. Unlike `cmd.exe`, where drives are only letters `C:`, `D:`, and so on, in PowerShell a "drive" is an abstraction for accessing any hierarchical data store.

```powershell
Get-PSDrive
```
The result will show not only physical drives, but also pseudo-drives:

| Name | Provider | Root | Description |
|------|----------|------|----------|
| Alias | Alias | Alias:\ | Command aliases |
| C | FileSystem | C:\ | Local drive C |
| Cert | Certificate | Cert:\ | Certificate store |
| Env | Environment | Env:\ | Environment variables |
| Function | Function | Function:\ | Loaded functions |
| HKCU | Registry | HKEY_CURRENT_USER | Registry branch |
| HKLM | Registry | HKEY_LOCAL_MACHINE | Registry branch |
| Variable | Variable | Variable:\ | Session variables |
| WSMan | WSMan | WSMan:\ | WinRM configuration |

This unification means that you can "enter" the registry (`Set-Location HKLM:`) and get a list of its keys with the same `Get-ChildItem` command that you use to get a list of files on drive C:. This is an incredibly powerful concept.

#### **Examples of working with different providers**

*   **Certificate Store (Cert:)**
     Allows you to work with digital certificates as if they were files in folders.
    
     **Task:** Find all SSL certificates on the local machine that expire within the next 30 days.
    ```powershell
    # Navigate to the local computer's certificate store
    Set-Location Cert:\LocalMachine\My
    
    # Find certificates where the end date is less than today + 30 days
    Get-ChildItem | Where-Object { $_.NotAfter -lt (Get-Date).AddDays(30) } | Select-Object Subject, NotAfter, Thumbprint
    ```

*   **Environment Variables (Env:)**
     Provides access to Windows environment variables (`%PATH%`, `%windir%`, etc.) as if they were files.
    
     **Task:** Get the path to the Windows system folder and add the `System32` path to it.
    ```powershell
    # Get the value of the windir variable
    $windowsPath = (Get-Item Env:windir).Value
    # Or simpler: $windowsPath = $env:windir
    
    # Safely construct the full path
    $system32Path = Join-Path -Path $windowsPath -ChildPath "System32"
    Write-Host $system32Path
    # Result: C:\WINDOWS\System32
    ```

*   **Windows Registry (HKCU: and HKLM:)**
     Imagine the registry is just another file system. Branches are folders, and parameters are properties of these folders.
    
     **Task:** Find out the full name of the installed Windows version from the registry.
    ```powershell
    # Navigate to the desired registry branch
    Set-Location "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    
    # Get the property (registry parameter) named "ProductName"
    Get-ItemProperty -Path . -Name "ProductName"
    # Result: ProductName : Windows 11 Pro
    ```

*   **Loaded Functions (Function:)**
     Shows all functions available in the current PowerShell session, as if they were files.
    
     **Task:** Find all loaded functions whose name contains the word "Help" and view the code of one of them.
    ```powershell
    # Search for functions by mask
    Get-ChildItem Function: | Where-Object { $_.Name -like "*Help*" }
    
    # Get the full code (definition) of the Get-Help function
    (Get-Item Function:Get-Help).Definition
    ```

*   **Session Variables (Variable:)**
     Allows you to manage all variables (`$myVar`, `$PROFILE`, `$Error`, etc.) defined in the current session.
    
     **Task:** Find all variables related to the PowerShell version (`$PSVersionTable`, `$PSHOME`, etc.).
    ```powershell
    # Find all variables starting with "PS"
    Get-ChildItem Variable:PS*
    
    # Get the value of a specific variable
    Get-Variable -Name "PSVersionTable"
    ```


### 2. **Navigation and Analysis**


#### **Navigation Basics**

```powershell
# Find out where we are (returns a PathInfo object)
Get-Location          # Aliases: gl, pwd

# Navigate to the root of drive C:
Set-Location C:\      # Aliases: sl, cd

# Navigate to the current user's home folder
Set-Location ~

# Show the contents of the current folder (returns a collection of objects)
Get-ChildItem         # Aliases: gci, ls, dir
```

```powershell
# **Recursive search**
# Find the hosts file in the system, ignoring "Access Denied" errors
Get-ChildItem C:\ -Filter "hosts" -Recurse -ErrorAction SilentlyContinue
```
 **The `-Recurse` switch (Recursive):** Makes the cmdlet work not only with the specified item, but also with all its contents.

 **The `-ErrorAction SilentlyContinue` switch:** An instruction to ignore errors and continue silently.


##### **Disk Space Analysis**
A classic example of pipeline power: find, sort, format, and select.
```powershell
Get-ChildItem C:\Users -File -Recurse -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending |
    Select-Object FullName, @{Name="Size(MB)"; Expression={[math]::Round($_.Length/1MB,2)}} |
    Select-Object -First 20
```

###### **Tip on how to enter long commands.**
> PowerShell allows you to break them into multiple lines for readability.
>
> *   **After the pipeline operator (`|`):** This is the most common and convenient way. Just press `Enter` after the `|` symbol. PowerShell will see that the command is not complete and will wait for continuation on the next line.
> *   **Anywhere else:** Use the backtick (`` ` ``) character at the end of the line, then press `Enter`. This character tells PowerShell: "The command will continue on the next line."
> *   **In editors (ISE, VS Code):** The `Shift+Enter` key combination usually automatically inserts a line break without running the command.



#### **Content Filtering and Logic Operators**

```powershell
# Find all .exe files. The -Filter parameter works very fast.
Get-ChildItem C:\Windows -Filter "*.exe"
```

`Get-ChildItem` returns a collection of objects. We can pipe it to `Where-Object` for further filtering.

```powershell
# Show only files
Get-ChildItem C:\Windows | Where-Object { $_.PSIsContainer -eq $false }
```
This command introduces us to one of the fundamental concepts in PowerShell scripts: **comparison operators**. 

#### **Comparison and Logic Operators**

 These are special keywords for comparing values. They always start with a hyphen (`-`) and are the basis for filtering data in `Where-Object` and building logic in `if`.

 | Operator | Description | Example in pipeline |
 | :--- | :--- | :--- |
 | `-eq` | Equal | `$_.Name -eq "svchost.exe"` |
 | `-ne` | Not Equal | `$_.Status -ne "Running"` |
 | `-gt` | Greater Than | `$_.Length -gt 1MB` |
 | `-ge` | Greater or Equal | `$_.Handles -ge 500` |
 | `-lt` | Less Than | `$_.LastWriteTime -lt (Get-Date).AddDays(-30)`|
 | `-le` | Less or Equal | `$_.Count -le 1` |
 | `-like` | Like (with wildcards `*`, `?`)| `$_.Name -like "win*"` |
 | `-notlike`| Not Like | `$_.Name -notlike "*.tmp"` |
 | `-in` | Value is contained in collection | `$_.Extension -in ".log", ".txt"` |
 | `-and` | Logical AND (both conditions are true) | |
 | `-or` | Logical OR (at least one condition is true) | |
 | `-not` | Logical NOT (inverts the condition) | |

 The topic of logic operators is very extensive, and I will dedicate a separate part (or even two) to it. For now, armed with these operators, we can **filter, sort, and select the files and folders we need**, using the full power of the object pipeline.


#### **Examples of use in the file system**

*   **Find a file by exact name (case-sensitive):**
    ```powershell
    Get-ChildItem C:\Windows\System32 -Recurse | Where-Object { $_.Name -eq "kernel32.dll" }
    ```

*   **Find all .exe files. The -Filter parameter works very fast:**
    ```powershell
    Get-ChildItem C:\Windows -Filter "*.exe"
    ```

*   **Show only files:**
    ```powershell
    Get-ChildItem C:\Windows | Where-Object { $_.PSIsContainer -eq $false }
    ```

*   **Find all files starting with "host" but not folders:**
    ```powershell
    Get-ChildItem C:\Windows\System32\drivers\etc | Where-Object { ($_.Name -like "host*") -and (-not $_.PSIsContainer) }
    ```

*   **Find all log files (.log) larger than 50 megabytes:**
    ```powershell
    Get-ChildItem C:\Windows\Logs -Filter "*.log" -Recurse | Where-Object { $_.Length -gt 50MB }
    ```

*   **Find all temporary files (.tmp) and backup files (.bak) for cleanup:**
    The `-in` operator here is much more elegant than multiple conditions with `-or`.
    ```powershell
    $extensionsToDelete = ".tmp", ".bak", ".old"
    Get-ChildItem C:\Temp -Recurse | Where-Object { $_.Extension -in $extensionsToDelete }
    ```

*   **Find all Word (.docx) files created in the last week:**
    ```powershell
    $oneWeekAgo = (Get-Date).AddDays(-7)
    Get-ChildItem C:\Users\MyUser\Documents -Filter "*.docx" -Recurse | Where-Object { $_.CreationTime -ge $oneWeekAgo }
    ```

*   **Find empty files (0 bytes) that are not folders:**
    ```powershell
    Get-ChildItem C:\Downloads -Recurse | Where-Object { ($_.Length -eq 0) -and (-not $_.PSIsContainer) }
    ```

*   **Find all executable files (.exe) that were modified this year, but NOT this month:**
    This complex example demonstrates the power of combining operators.
    ```powershell
    Get-ChildItem "C:\Program Files" -Filter "*.exe" -Recurse | Where-Object {
        ($_.LastWriteTime.Year -eq (Get-Date).Year) -and ($_.LastWriteTime.Month -ne (Get-Date).Month)
    }
    ```
*(Note: parentheses `()` around each condition are used for grouping and improving readability, especially in complex cases).*

Be careful with recursion:
Too many files/folders — -Recurse can recursively enter tens of thousands of items.
Symbolic links / circular links — can cause infinite recursion.
Files without access rights — can block execution.


### 4. **Creation, Management, and Safe Deletion**

#### **Creation, Copying, and Moving**
```powershell
New-Item -Path "C:\Temp\MyFolder" -ItemType Directory
Add-Content -Path "C:\Temp\MyFolder\MyFile.txt" -Value "First line"
Copy-Item -Path "C:\Temp\MyFolder" -Destination "C:\Temp\MyFolder_Copy" -Recurse
```

#### **Safe Deletion**
`Remove-Item` is a potentially dangerous cmdlet, so PowerShell has built-in protection mechanisms.
> **The `-WhatIf` switch (What if?):** Your best friend. It **does not execute** the command, but only displays a message in the console about **what would happen**.

```powershell
# Safe CHECK before deletion
Remove-Item C:\Temp\MyFolder -Recurse -Force -WhatIf
# Result: What if: Performing the operation "Remove Directory" on target "C:\Temp\MyFolder".

# Only after making sure everything is correct, remove -WhatIf and EXECUTE the command
Remove-Item C:\Temp\MyFolder -Recurse -Force
```


### **Introduction to Functions**

When a single line of code turns into a complex set of commands that you want to use again and again, it's time to create **functions**.

#### **How to use and save functions**

There are three main ways to make your functions available:

**Method 1: Temporary (for tests)**
You can type in the console or simply copy and paste the entire function code into the PowerShell console. The function will be available until this window is closed.

**Method 2: Permanent, but manual (via `.ps1` file)**
This is the most common way to organize and share tools. You save the function to a `.ps1` file and load it into the session when you need it.
> **Dot Sourcing (`. .​script.ps1`):** This special command executes the script in the *current* context, making all its functions and variables available in your console.

**Method 3: Automatic (via PowerShell profile)**
This is the most powerful way for your personal, frequently used tools.
> **What is a PowerShell profile?** It is a special `.ps1` script that PowerShell automatically runs every time it starts. Everything you put in this file—aliases, variables, and, of course, functions—will be available in every session by default.
1.  **Find the path to the profile file.** PowerShell stores it in the `$PROFILE` variable.
    ```powershell
    $PROFILE
    ```
2.  **Create the profile file if it does not exist.**
    ```powershell
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Type File -Force
    }
    ```
3.  **Add the code of our function to the end of the profile file.**
    ```powershell
    Add-Content -Path $PROFILE -Value $functionCode
    ```
4.  **Restart PowerShell** (or run `. $PROFILE`), and now your `Find-DuplicateFiles` command will always be available, just like `Get-ChildItem`.


##### **Example 1: Finding Duplicate Files**

Let's go through all the steps using the `Find-DuplicateFiles` function as an example.

**Step 1: Define the function code**
```powershell
$functionCode = @'
function Find-DuplicateFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    Get-ChildItem $Path -File -Recurse -ErrorAction SilentlyContinue |
        Group-Object Name, Length |
        Where-Object { $_.Count -gt 1 } |
        ForEach-Object {
            # THIS IS THE CORRECTED LINE:
            # Inside the $() operator, variables are not escaped.
            Write-Host "Found duplicates: $($_.Name)" -ForegroundColor Yellow
            $_.Group | Select-Object FullName, Length, LastWriteTime
        }
}
'@
```

**Step 2 (Option A): Save to a separate file for manual loading**
```powershell
# Save
Set-Content -Path ".\Find-DuplicateFiles.ps1" -Value $functionCode
# Load 
. .\Find-DuplicateFiles.ps1
```
> Dot Sourcing (. .\Find-DuplicateFiles.ps1): This special command executes the script in the current context, making all its functions and variables available in your console.
```powershell
# Call
Find-DuplicateFiles -Path "C:\Users\$env:USERNAME\Downloads"
```

**Step 2 (Option B): Add to profile for automatic loading**
Let's make this function always available.
>What is a PowerShell profile? It is a special .ps1 script that PowerShell automatically runs every time it starts. Everything you put in this file—aliases, variables, and functions—will be available in every session by default.
1.  **Find the path to the profile file.** PowerShell stores it in the `$PROFILE` variable.
    ```powershell
    $PROFILE
    ```
2.  **Create the profile file if it does not exist.**
    ```powershell
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Type File -Force
    }
    ```
3.  **Add the code of our function to the end of the profile file.**
    ```powershell
    Add-Content -Path $PROFILE -Value $functionCode
    ```
4.  **Restart PowerShell** (or run `. $PROFILE`), and now your `Find-DuplicateFiles` command will always be available, just like `Get-ChildItem`.



##### **Example 2: Creating a ZIP Archive with a Backup**

**Code for `Backup-FolderToZip.ps1` file:**
```powershell
function Backup-FolderToZip {
    param([string]$SourcePath, [string]$DestinationPath)
    if (-not (Test-Path $SourcePath)) { Write-Error "Source folder not found."; return }
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $archiveFileName = "Backup_{0}_{1}.zip" -f (Split-Path $SourcePath -Leaf), $timestamp
    $fullArchivePath = Join-Path $DestinationPath $archiveFileName
    if (-not (Test-Path $DestinationPath)) { New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null }
    Compress-Archive -Path "$SourcePath\*" -DestinationPath $fullArchivePath -Force
    Write-Host "Backup completed: $fullArchivePath" -ForegroundColor Green
}
```

I will provide a detailed breakdown of functions in subsequent parts.


--- 

### **Cmdlet Reference for File System Operations**

#### **1. Basic Cmdlets**
This list includes 12 essential cmdlets that cover 90% of daily tasks.

| Cmdlet | Main Purpose | Example Usage |
| :--- | :--- | :--- |
| `Get-ChildItem`| Get a list of files and folders. | `Get-ChildItem C:\Windows` |
| `Set-Location` | Change to another directory. | `Set-Location C:\Temp` |
| `Get-Location` | Show the current directory. | `Get-Location` |
| `New-Item` | Create a new file or folder. | `New-Item "report.docx" -Type File`|
| `Remove-Item` | Delete a file or folder. | `Remove-Item "old_log.txt"` |
| `Copy-Item` | Copy a file or folder. | `Copy-Item "file.txt" -Dest "D:\"` |
| `Move-Item` | Move a file or folder. | `Move-Item "report.docx" -Dest "C:\Archive"` |
| `Rename-Item` | Rename a file or folder. | `Rename-Item "old.txt" -NewName "new.txt"` |
| `Get-Content` | Read the content of a file. | `Get-Content "config.ini"` |
| `Set-Content` | Write/overwrite the content of a file. | `"data" | Set-Content "file.txt"` |
| `Add-Content` | Append content to the end of a file. | `Get-Date | Add-Content "log.txt"` |
| `Test-Path` | Check if a file or folder exists. | `Test-Path "C:\Temp"` |


Need to **read the content** of a text file? Use `Get-Content`.
Need to **completely overwrite a file** with new content? Use `Set-Content`.
Need to **add a line to a log file** without erasing old data? Use `Add-Content`.
Need to **check if a file exists** before writing? Use `Test-Path`.

#### **2. Specialized Cmdlets for Advanced Tasks**
When basic cmdlets are not enough, PowerShell offers more specialized tools. They do not duplicate the basic ones, but expand your capabilities.

*   **Working with Paths**
    *   **`Join-Path`**: Safely combines path parts, automatically inserting `\`.
    *   **`Split-Path`**: Splits a path into parts (folder, file name, extension).
    *   **`Resolve-Path`**: Converts a relative path (e.g., `.` or `..iles`) to a full, absolute one.

*   **Working with Properties and Content (Item Properties and Content)**
    *   **`Get-ItemProperty`**: Gets the properties of a specific file (e.g., `IsReadOnly`, `CreationTime`).
    *   **`Set-ItemProperty`**: Changes the properties of a file or folder.
    *   **`Clear-Content`**: Deletes all content from a file, but leaves the file itself empty.

*   **Advanced Navigation (Location Stack)**
    *   **`Push-Location`**: "Remembers" the current directory and moves to a new one.
    *   **`Pop-Location`**: Returns to the directory that `Push-Location` "remembered".

*   **Access Rights Management (ACL)**
    *   **`Get-Acl`**: Gets a list of access rights (ACL) for a file or folder.
    *   **`Set-Acl`**: Sets access rights for a file or folder (complex operation).

Need to **change a file attribute**, for example, make it "read-only"? Use `Set-ItemProperty`.
Need to **completely clear a log file** without deleting it? Use `Clear-Content`.
Need to **temporarily change to another folder** in a script, and then reliably return? Use `Push-Location` and `Pop-Location`.
Need to **find out who has access** to a folder? Use `Get-Acl`.

In the next part, we will learn how to work with other data stores, such as the Windows registry,
using the same approaches, delve into the concept of functions, consider logic operators, and learn how to interactively with the shell.

PowerShell Philosophy on github:
[History and first cmdlet](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/01.md)

Part 2: [Pipeline, variables, Get-Member, .ps1 file and exporting results.](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/02.md)
Examples for part two:
[system_monitor.ps1](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/code/02/system_monitor.ps1)

Part 3: [File system navigation and management.](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/03.md)

Examples for part three:
[Find-DuplicateFiles.ps1](https://github.com/hypo69/1001-python-ru/blob/master/articles/%D0%A4%D0%B8%D0%BB%D0%BE%D1%81%D0%BE%D1%84%D0%B8%D1%8F%20PowerShell/code/03/Find-DuplicateFiles.ps1)
[Backup-FolderToZip]()
