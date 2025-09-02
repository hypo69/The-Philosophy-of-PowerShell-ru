# PowerShell Philosophy.

## Part 4: Interactive Work: `Out-ConsoleGridView`, Alerts.

- In [Part 1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/01.md) we defined two key PowerShell concepts: pipeline and object.

- In [Part 2](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/02.md) I explained what objects and pipelines are.

- In [Part 3](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/03.md) we got acquainted with the file system and providers.

- Today we will look at interactive work with data in the console, as well as get acquainted with alerts and notifications.

### Chapter One: Interactive Work with Data in the Console.

#### `Out-ConsoleGridView`. GUI in PowerShell Console.


**❗ Important:** All tools described below require **PowerShell 7.2 or newer**.

Out-ConsoleGridView is an interactive table, directly in the PowerShell console, allowing you to:
- view data in a table;
- filter and sort columns;
- select rows with the cursor — to pass them further down the pipeline.
- and much more.

`Out-ConsoleGridView` is part of the `Microsoft.PowerShell.ConsoleGuiTools` module.
To use it, you first need to install this module.

To install the module, run the following command in PowerShell:
```powershell
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
```
![Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser](assets/04/1.png)

*Install-Module* downloads and installs the specified module from the repository to the system.
Analogues: `pip install` in `Python` or `npm install` in `Node.js`.

📎 Key parameters of *Install-Module*

------------------------------------------------------------------------------------------------------------------------------------------------------
| Parameter | Description |
|---|---|
| `-Name` | The name of the module to install. |
| `-Scope` | Installation scope: `AllUsers` (default, requires administrator rights) or `CurrentUser` (does not require administrator rights). |
| `-Repository` | Specifies the repository, for example `PSGallery`. |
| `-Force` | Forced installation without confirmation. |
| `-AllowClobber` | Allows overwriting existing commands. |
| `-AcceptLicense` | Automatically accepts the module license. |
| `-RequiredVersion` | Installs a specific version of the module. |



After installation, you can pipe any output to `Out-ConsoleGridView` for interactive work.

```powershell   
# Classic example: displaying a list of processes in an interactive table
Get-Process | Out-ConsoleGridView
```

[1](https://github.com/user-attachments/assets/5828dd51-cfb8-4904-87be-796ccc8395be)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/5828dd51-cfb8-4904-87be-796ccc8395be" type="video/mp4">
  Your browser does not support the video tag.
</video>



**Interface:**
*   **Filtering:** Just start typing, and the list will be filtered on the fly.
*   **Navigation:** Use arrow keys to move through the list.
*   **Selection:** Press `Space` to select/deselect an item.
*   **Multiple selection:** `Ctrl+A` to select all items, `Ctrl+D` to deselect all.
*   **Confirmation:** Press `Enter` to return the selected objects.
*   **Cancel:** Press `ESC` to close the window without returning data.




## What `Out-ConsoleGridView` can do:

* Display tabular data directly in the PowerShell console as an interactive table with row and column navigation.
* Sort columns by pressing keys.
* Filter data using search.
* Select one or more rows with result return.
* Work in a clean console without GUI windows.
* Support a large number of rows with scrolling.
* Support various data types (strings, numbers, dates, etc.).

---

## Examples of using `Out-ConsoleGridView`

### Basic usage — show a table with interactive selection capability. (checkbox)

```powershell
Import-Module Microsoft.PowerShell.ConsoleGuiTools

$data = Get-Process | Select-Object -First 30 -Property Id, ProcessName, CPU, WorkingSet

# Display a table with filtering, sorting, and row selection capabilities
$selected = $data | Out-ConsoleGridView -Title "Select process(es)" -OutputMode Multiple

$selected | Format-Table -AutoSize
```

[2](https://github.com/user-attachments/assets/3f1a2a62-066f-4dbb-947a-9b26095da356)

<video>
  <source src="https://github.com/user-attachments/assets/3f1a2a62-066f-4dbb-947a-9b26095da356" type="video/mp4">
  Your browser does not support the video tag.
</video>



The list of processes is displayed in an interactive console table.
You can filter by name, sort columns, and select processes.
Selected processes are returned to the `$selected` variable.

---

### Selecting a single row with mandatory result return. (radio)



```powershell
$choice = Get-Service | Select-Object -First 20 | Out-ConsoleGridView -Title "Select a service" -OutputMode Single

Write-Host "You selected service: $($choice.Name)"
```

[](https://github.com/user-attachments/assets/5ee8fb92-8e18-496a-9db7-2d86b243742e)

<video>
  <source src="https://github.com/user-attachments/assets/5ee8fb92-8e18-496a-9db7-2d86b243742e" type="video/mp4">
  Your browser does not support the video tag.
</video>


User selects a single row (service). `-OutputMode Single` prevents multiple selections.

---

### Filtering and sorting large arrays

```powershell
$data = 1..1000 | ForEach-Object { 
    [PSCustomObject]@{ 
        Number = $_ 
        Square = $_ * $_ 
        Cube   = $_ * $_ * $_ 
    } 
}

$data | Out-ConsoleGridView -Title "Numbers and powers"  -OutputMode Multiple
```

Displays a table of 1000 rows with numbers and their powers.



### **Interactive process management:**

You can select multiple processes to stop. The `-OutputMode Multiple` parameter indicates that we want to return all selected items.



```powershell
# Pipe the results.
# Stop selected processes with the -WhatIf parameter for preview.
# To do this, define the $procsToStop variable
$procsToStop = Get-Process | Out-ConsoleGridView -OutputMode Multiple
    
# If something was selected, pass the objects further down the pipeline
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```

### **Selecting files for archiving:**
    Find all `.log` files in a folder, select the necessary ones, and create an archive from them.

```powershell
$filesToArchive = Get-ChildItem -Path C:\Logs -Filter "*.log" -Recurse | Out-ConsoleGridView -OutputMode Multiple
```

    ❗Be careful with recursion

```powershell
if ($filesToArchive) {
    Compress-Archive -Path $filesToArchive.FullName -DestinationPath C:\Temp\LogArchive.zip
    
    # Add success message
    Write-Host "✅ Archiving completed successfully!" -ForegroundColor Green
}
```


### **Selecting a single item for detailed analysis:**


#### "Drill-Down" Pattern — from general list to details with `Out-ConsoleGridView`

Often when working with system objects, we face a dilemma:
1.  If you request **all properties** for **all objects** (`Get-NetAdapter | Format-List *`), the output will be huge and unreadable.
2.  If you show a **brief table**, we will lose important details.
3.  Sometimes trying to get all data at once can lead to an error if one of the objects contains invalid values.

Solving this problem is the **"Drill-Down"** pattern (detailing or "drilling down"). Its essence is simple:

*   **Step 1 (Overview):** Show the user a clean, concise, and safe list of items for **selection**.
*   **Step 2 (Detailing):** After the user has selected one specific item, show them **all available information** for that particular item.


#### Practical example: Creating a network adapter explorer

Let's implement this pattern using the `Get-NetAdapter` command as an example.

**Task:** First, show a brief list of network adapters. After selecting one of them, open a second window with all its properties.

**Ready code:**
```powershell
# --- Stage 1: Selecting an adapter from a brief list ---
$adapterList = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed
$selectedAdapter = $adapterList | Out-ConsoleGridView -Title "STAGE 1: Select a network adapter"

# --- Stage 2: Displaying detailed information or a cancellation message ---
if ($null -ne $selectedAdapter) {
    # Get ALL properties for the SELECTED adapter
    $detailedInfoObject = Get-NetAdapter -Name $selectedAdapter.Name | Select-Object *

    # Use our trick with .psobject.Properties to turn the object into a convenient "Name-Value" table
    $detailedInfoForGrid = $detailedInfoObject.psobject.Properties | Select-Object Name, Value
    
    # Open a SECOND GridView window with full information
    $detailedInfoForGrid | Out-ConsoleGridView -Title "STAGE 2: Full information for '$($selectedAdapter.Name)'"
} else {
    Write-Host "Operation canceled. Adapter was not selected." -ForegroundColor Yellow
}
```

#### Step-by-step breakdown

1.  **Creating a "safe" list:**
    `$adapterList = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed`
    We do not pipe the output of `Get-NetAdapter` directly. Instead, we create new, "clean" objects using `Select-Object`, including only the properties we need for an overview. This ensures that problematic data that caused an error will be discarded.

2.  **First interactive window:**
    `$selectedAdapter = $adapterList | Out-ConsoleGridView ...`
    The script displays the first window and **pauses its execution**, waiting for your selection. Once you select a row and press `Enter`, the object corresponding to that row will be written to the `$selectedAdapter` variable.

3.  **Checking the selection:**
    `if ($null -ne $selectedAdapter)`
    This is a critically important check. If the user presses `Esc` or closes the window, the `$selectedAdapter` variable will be empty (`$null`). This check prevents the rest of the code from executing and errors from occurring.

4.  **Getting full information:**
    `$detailedInfoObject = Get-NetAdapter -Name $selectedAdapter.Name`
    Here's the key point of the pattern. We call `Get-NetAdapter` again, but this time we request **only one** object by its name, which we took from the item selected in the first stage. Now we get the full object with all its properties.

5.  **Transformation for the second window:**
    `$detailedInfoForGrid = $detailedInfoObject.psobject.Properties | ...`
    We use the powerful trick you already know to "unroll" this single complex object into a long list of "Property Name" | "Value" pairs, which is ideal for display in a table.

6.  **Second interactive window:**
    `$detailedInfoForGrid | Out-ConsoleGridView ...`
    A second window appears on the screen, this time with comprehensive information about the adapter you selected.


---



### Example with custom title and hints

Displaying Windows event log in an interactive table with the title "System Events".

```powershell
Get-EventLog -LogName System -Newest 50 |
    Select-Object TimeGenerated, EntryType, Source, Message |
    Out-ConsoleGridView -Title "System Events"  -OutputMode Multiple
```
This code retrieves the last 50 events from the Windows system log, selects only four key properties (time, type, source, and message) from each event, and displays them in the Out-ConsoleGridView window.

----

### System Information.


[1](https://github.com/user-attachments/assets/1e53a339-56f9-4add-8053-86d94dbc8e06)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1e53a339-56f9-4add-8053-86d94dbc8e06" type="video/mp4">
  Your browser does not support the video tag.
</video>


Code for the system information script:
[Get-SystemMonitor.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/04/Get-SystemMonitor.ps1)


### Creating the 'Get-SystemMonitor' cmdlet


#### Step 1: Setting up the `PATH` variable

1.  **Create a permanent folder for your tools,** if you haven't already. For example:
    `C:\PowerShell\Scripts`

2.  **Place your `Get-SystemMonitor.ps1` file** in this folder.

3.  **Add this folder to the system `PATH` variable**,

#### Step 2: Setting up an alias in the PowerShell profile

Now that the system knows where to find your script by its full name, we can create a short alias for it.

1.  **Open your PowerShell profile file**:
    ```powershell
    notepad $PROFILE
    ```

2.  **Add the following line to it:**
    ```powershell
    # Alias for system monitor
    Set-Alias -Name sysmon -Value "Get-SystemMonitor.ps1"
    ```

    **Note the key point:** Since the folder with the script is already in `PATH`, we no longer need to specify the full path to the file! We simply refer to its name. This makes your profile cleaner and more reliable. If you ever move the `C:\PowerShell\Scripts` folder, you will only need to update the `PATH` variable, and your profile file will remain unchanged.

#### Restart PowerShell

Close **all** open PowerShell windows and open a new one. This is necessary for the system to apply changes to both the `PATH` variable and your profile.

---

### Result: What you get

After performing these steps, you will be able to call your script **in two ways from anywhere in the system**:

1.  **By full name (reliable, for use in other scripts):**
    ```powershell
    Get-SystemMonitor.ps1
    Get-SystemMonitor.ps1 -Resource storage
    ```

2.  **By short alias (convenient, for interactive work):**
    ```powershell
    sysmon
    sysmon -Resource memory
    ```

You have successfully "registered" your script in the system in the most professional and flexible way.


Useful? Subscribe.
Liked it — put "+"
Good luck! 🚀

Other PowerShell articles:
