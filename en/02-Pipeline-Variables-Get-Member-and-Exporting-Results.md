# PowerShell Philosophy.
## Part 2: The Pipeline, Variables, Get-Member, *.ps1* Files, and Exporting Results
**❗ Important:**
I am writing about PS7 (PowerShell 7). It is different from PS5 (PowerShell 5). Starting with version 7, PS became cross-platform. Because of this, the behavior of some commands has changed.

In the first part, we established a key principle: PowerShell works with **objects**, not text. This post is dedicated to some important PowerShell tools: we will learn how to pass objects through the **pipeline**, analyze them with **`Get-Member`**, save results in **variables**, and automate all of this in **script files (`.ps1`)** with **exporting** results into convenient formats.

### 1. What is the pipeline (`|`)?
The pipeline in PowerShell is a mechanism for passing full-fledged .NET objects (not just text) from one command to another, where each subsequent cmdlet receives structured objects with all their properties and methods.

The `|` (pipe) symbol is the pipeline operator. Its job is to take the result (output) of the command to its left and pass it as input to the command on its right.

`Command 1 (creates objects)` → `|` → `Command 2 (receives and processes objects)` → `|` → `Command 3 (receives processed objects)` → | ...

#### The Classic UNIX Pipeline: A Stream of Text

In `bash`, a **stream of bytes** is passed through the pipeline, which is usually interpreted as text.

```bash
# Find all 'nginx' processes and count them
ps -ef | grep 'nginx' | wc -l
```
Here, `ps` outputs text, `grep` filters this text, and `wc` counts the lines. Each utility knows nothing about "processes"; it only works with strings.

#### The PowerShell Pipeline: A Stream of Objects
**Example:** Let's get all processes, sort them by CPU usage, and select the 5 most "hungry" ones.

```powershell
Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5
```
![1](assets/02/1.png)

Here, `Get-Process` creates process **objects**. `Sort-Object` receives these **objects** and sorts them by the `CPU` property. `Select-Object` receives the sorted **objects** and selects the first 5.

You probably noticed words in the command that start with a hyphen (-): -Property, -Descending, -First. These are parameters.
Parameters are settings, switches, and instructions for a cmdlet. They allow you to control **HOW** a command will do its job. Without parameters, a command works in its default mode, but with parameters, you give it specific instructions.

Main types of parameters:

- Parameter with a value: requires additional information.

    `-Property CPU`: We are telling Sort-Object which property to sort by. CPU is the value of the parameter.
    
    `-First 5`: We are telling Select-Object how many objects to select. 5 is the value of the parameter.

- Switch parameter (flag): Does not require a value. Its mere presence in the command enables or disables a certain behavior.

   `-Descending`: This flag tells Sort-Object to reverse the sort order (from largest to smallest). It doesn't need an additional value—it is an instruction in itself.

```powershell
Get-Process -Name 'svchost' | Measure-Object
```
![1](assets/02/2.png)
This command answers a very simple question:
**"How many processes named `svchost.exe` are currently running on my system?"**

#### Step-by-step breakdown

##### **Step 1: `Get-Process -Name 'svchost'`**

This part of the command queries the operating system and asks it to find **all** running processes whose executable file name is `svchost.exe`.
Unlike processes like `notepad` (of which there are usually one or two), there are always **many** `svchost` processes in the system. The command will return an **array (collection) of objects**, where each object is a separate, full-fledged `svchost` process with its own unique ID, memory usage, etc.
PowerShell has found, for example, 90 `svchost` processes in the system and now holds a collection of 90 objects.

##### **Step 2: `|` (Pipeline Operator)**

This symbol takes the collection of 90 `svchost` objects obtained in the first step and begins to pass them **one by one** to the input of the next command.

##### **Step 3: `Measure-Object`**

Since we called `Measure-Object` without parameters (such as `-Property`, `-Sum`, etc.), it performs its **default** operation—it simply counts the number of "items" passed to it.
One, two, three ... After all the objects have been counted, `Measure-Object` creates its **own result object**, which has a `Count` property equal to the final number.


**`Count: 90`** — this is the answer to our question. There are 90 `svchost` processes running.
The other fields are empty because we did not ask `Measure-Object` to perform more complex calculations.


#### Example with `svchost` and parameters

Let's change our task. Now we want to not just count the `svchost` processes, but to find out **how much total RAM (in megabytes) they consume together**.

To do this, we will need parameters:
*   `-Property WorkingSet64`: This instruction tells `Measure-Object`: "From each `svchost` object that comes to you, take the numeric value from the `WorkingSet64` property (this is memory usage in bytes)".
*   `-Sum`: This flag instruction says: "Add up all these values that you took from the `WorkingSet64` property".

Our new command will look like this:
```powershell
Get-Process -Name 'svchost' | Measure-Object -Property WorkingSet64 -Sum
```
![3](assets/02/3.png)

1.  `Get-Process` will find the number of `svchost` objects.
2.  The pipeline `|` will pass them to `Measure-Object`.
3.  But now `Measure-Object` works differently:
    *   It takes the first `svchost` object, looks at its `.WorkingSet64` property (for example, `25000000` bytes) and remembers this number.
    *   It takes the second object, looks at its `.WorkingSet64` (for example, `15000000` bytes) and adds it to the previous one.
    *   ...and so on for all objects.
4.  As a result, `Measure-Object` will create a result object, but now it will be different.


*   **`Count: 92`**: The number of objects.
*   **`Sum: 1661890560`**: This is the total sum of all `WorkingSet64` values in bytes.
*   **`Property: WorkingSet64`**: This field is now also filled; it informs us which property was used for the calculations.




### 2. Variables (Regular and the special `$_`)

A variable is a named storage in memory that contains some value.

This value can be anything: text, a number, a date, or, most importantly for PowerShell, a whole object or even a collection of objects. A variable name in PowerShell always starts with a dollar sign ($).
Examples: $name, $counter, $processList.

The special variable $_?

$_ is shorthand for "the current object" or "this thing here".
Imagine a conveyor belt in a factory. Different parts (objects) are moving along it.

$_ is the very part that is right in front of you (or in front of the processing robot).

The source (Get-Process) dumps a whole box of parts (all processes) onto the conveyor belt.

The pipeline (|) makes these parts move along the belt one by one.

The handler (Where-Object or ForEach-Object) is a robot that looks at each part.

The $_ variable is the very part that is currently in the robot's "hands".

When the robot is finished with one part, the conveyor belt feeds it the next one, and $_ will now point to it.



Let's calculate how much total memory the `svchost` processes use and display the result on the monitor.
```powershell
# 1. Execute the command and save its complex result object to the $svchostMemory variable
$svchostMemory = Get-Process -Name svchost | Measure-Object -Property WorkingSet64 -Sum

# 2. Now we can work with the saved object. Let's get the Sum property from it
$memoryInMB = $svchostMemory.Sum / 1MB

# 3. Display the result on the screen using the new variable
Write-Host "All svchost processes are using $memoryInMB MB of memory."
```
![3](assets/02/4.png)

*   `Write-Host` is a specialized cmdlet whose sole purpose is to **show text directly to the user in the console**.

*   A string in double quotes: `"..."` is a text string that we pass to the `Write-Host` cmdlet as an argument. Why double quotes and not single quotes?
    
    In PowerShell, there are two types of quotes:
    
    *   **Single (`'...'`):** Create a **literal string**. Everything inside them is treated as plain text, without exception.
    *   **Double (`"..."`):** Create an **expandable (or substitutable) string**. PowerShell "scans" such a string for variables (starting with `$`) and substitutes their values in their place.

* `$memoryInMB`. This is the variable in which we **in the previous step** of our script put the result of the calculations. When `Write-Host` receives a string in double quotes, a process called **"String Expansion"** occurs:
    1.  PowerShell sees the text `"All svchost processes are using "`.
    2.  Then it encounters the construct `$memoryInMB`. It understands that this is not just text, but a variable.
    3.  It looks into memory, finds the value stored in `$memoryInMB` (for example, `1585.52`).
    4.  It **substitutes this value** directly into the string.
    5.  Then it adds the rest of the text: `" MB of memory."`.
    6.  As a result, the already assembled string is passed to `Write-Host`: `"All svchost processes are using 1585.52 MB of memory."`.



Start Notepad:
 1. Find the Notepad process and save it to the $notepadProcess variable
 ```powershell
$notepadProcess = Get-Process -Name notepad
```

 2. Access the 'Id' property of this object through the dot and display it
 ```powershell
Write-Host "The ID of the 'Notepad' process is: $($notepadProcess.Id)"
```
![5](assets/02/5.png)

**❗ Important:**
    Write-Host "breaks" the pipeline. The text output by it cannot be passed further down the pipeline for processing. It is intended for display only.

### 3. Get-Member (The Object Inspector)

We know that objects "flow" through the pipeline. But how do we know what they are made of? What properties do they have and what actions (methods) can be performed on them?

The **`Get-Member`** cmdlet (alias: `gm`) is the main tool for investigation.
Before working with an object, pass it through `Get-Member` to see all its capabilities.

Let's analyze the objects that `Get-Process` creates:
```powershell
Get-Process | Get-Member
```
![6](assets/02/6.png)

*Let's break down each part of the Get-Member output.*

`TypeName: System.Diagnostics.Process` - This is the full, official "type name" of the object from the .NET library. This is its "passport".
This line tells you that all objects returned by Get-Process are objects of type System.Diagnostics.Process.
This guarantees that they will all have the same set of properties and methods.
You can [google](https://www.google.com/search?q=System.Diagnostics.Process+site%3Amicrosoft.com) "System.Diagnostics.Process" to find the official Microsoft documentation with even more detailed information.



- Column 1: `Name`

This is a simple, human-readable **name** of a property, method, or other "member" of an object. This is the name you will use in your code to access data or perform actions.



- Column 2: `MemberType` (Type of object)

This is the most important column to understand. It classifies **what** each member is. This is its "job title" that tells you **HOW** to use it.

*   **`Property`:** a **characteristic** or **piece of data** stored inside an object. You can "read" its value.
    *   *Examples from the screenshot:* `BasePriority`, `HandleCount`, `ExitCode`. This is just data that can be viewed.

*   **`Method`:** an **ACTION** that can be performed on an object. Methods are always called with parentheses `()`.
    *   *Examples from the screenshot:* `Kill`, `Refresh`, `WaitForExit`. You would write `$process.Kill()` or `$process.Refresh()`.

*   **`AliasProperty`:** a **friendly alias** for another, longer property. PowerShell adds them for convenience and brevity.
    *   *Examples from the screenshot:* `WS` is a short alias for `WorkingSet64`. `Name` is for `ProcessName`. `VM` is for `VirtualMemorySize64`.

*   **`Event`:** a **NOTIFICATION** that something has happened, to which you can "subscribe".
    *   *Example from the screenshot:* `Exited`. Your script can "listen" for this event to perform some action immediately after the process terminates.

*   **`CodeProperty` and `NoteProperty`:** special types of properties, often added by PowerShell itself for convenience. A `CodeProperty` calculates its value "on the fly", and a `NoteProperty` is a simple note property added to an object.

- Column 3: `Definition`

This is the **technical definition** or "signature" of the member. It gives you the exact details for its use. Its content depends on the `MemberType`:

*   **For `AliasProperty`:** Shows **what the alias is equal to**. This is incredibly useful!
    *   *Example from the screenshot:* `WS = WorkingSet64`. You can immediately see that `WS` is just a short notation for `WorkingSet64`.

*   **For `Property`:** Shows the **data type** stored in the property (e.g., `int` for an integer, `string` for text, `datetime` for a date and time), and what you can do with it (`{get;}` - read only, `{get;set;}` - read and write).
    *   *Example from the screenshot:* `int BasePriority {get;}`. This is an integer property that can only be read.

*   **For `Method`:** Shows what the method returns (e.g., `void` - nothing, `bool` - true/false) and what **parameters** (input data) it accepts in parentheses.
    *   *Example from the screenshot:* `void Kill()`. This means that the `Kill` method returns nothing and can be called without parameters. There is also a second version `void Kill(bool entireProcessTree)` that accepts a boolean value (true/false).

#### In table form

| Column | What is it? | Example from screenshot | What for? |
|---|---|---|---|
| **Name** | The name you use in your code. | `Kill`, `WS`, `Name` | to access a property or method (`$process.WS`, `$process.Kill()`). |
| **MemberType**| The type of member (data, action, etc.). | `Method`, `Property`, `AliasProperty` | **how** to use it (read a value or call with `()`). |
| **Definition** | Technical details. | `WS = WorkingSet64`, `void Kill()` | what is hidden behind an alias and what parameters a method needs. |



#### Example: Working with process windows

##### 1. The problem:
"I have opened many Notepad windows. How can I programmatically minimize all but the main one, and then close only the one that has the word 'Untitled' in its title?"

##### 2. Investigation with `Get-Member`:
We need to find properties related to the window and its title.

```powershell
Get-Process -Name notepad | Get-Member
```
**Analysis of the `Get-Member` result:**
*   Scrolling through the properties, we find `MainWindowTitle`. The type is `string`. Great, this is the title of the main window!
*   In the methods, we see `CloseMainWindow()`. This is a "softer" way to close a window than `Kill()`.
*   Also in the methods, there is `WaitForInputIdle()`. This sounds interesting; perhaps it will help to wait until the process is ready for interaction.

![7](assets/02/7.png)

`Get-Member` showed us the `MainWindowTitle` property, which is the key to solving the problem and allows us to interact with processes based on the state of their windows, and not just by name.

##### 3. The solution:
Now we can build logic based on the window title.

```powershell
# 1. Find all Notepad processes
$notepads = Get-Process -Name notepad

# 2. Go through each one and check the title
foreach ($pad in $notepads) {
    # For each process ($pad), check its MainWindowTitle property
    if ($pad.MainWindowTitle -like '*Untitled*') {
        Write-Host "Found an unsaved Notepad (ID: $($pad.Id)). Closing its window..."
        # $pad.CloseMainWindow() # Uncomment to actually close
        Write-Host "The window '$($pad.MainWindowTitle)' would have been closed." -ForegroundColor Yellow
    } else {
        Write-Host "Skipping Notepad with title: $($pad.MainWindowTitle)"
    }
}
```

![8](assets/02/8.png)

![9](assets/02/9.png)


---

#### Example: Find the parent process

##### 1. The problem:
"Sometimes I see a lot of child `chrome.exe` processes in the system. How can I find out which one is the main, "parent" process that launched them all?"

##### 2. Investigation with `Get-Member`:
We need to find something that links one process to another.

```powershell
Get-Process -Name chrome | Select-Object -First 1 | Get-Member
```
![10](assets/02/10.png)

**Analysis of the `Get-Member` result:**
*   Carefully looking through the list, we find a property of type `CodeProperty` named `Parent`.
*   Its `Definition` is `System.Diagnostics.Process Parent{get=GetParentProcess;}`.
This is a calculated property that, when accessed, returns the **parent process object**.

##### 3. The solution:
Now we can write a script that, for each `chrome` process, will display information about its parent.

```powershell
# 1. Get all chrome processes
$chromeProcesses = Get-Process -Name chrome

# 2. For each of them, display information about it and its parent
$chromeProcesses | Select-Object -First 5 | ForEach-Object {
    # Get the parent process
    $parent = $_.Parent
    
    # Format a nice output
    Write-Host "Process:" -ForegroundColor Green
    Write-Host "  - Name: $($_.ProcessName), ID: $($_.Id)"
    Write-Host "Its parent:" -ForegroundColor Yellow
    Write-Host "  - Name: $($parent.ProcessName), ID: $($parent.Id)"
    Write-Host "-----------------------------"
}
```
![11](assets/02/11.png)

![12](assets/02/12.png)

We can immediately see that the processes with IDs 4756, 7936, 8268, and 9752 were launched by the process with ID 14908. We can also notice an interesting case with the process ID: 7252, whose parent process was not determined (perhaps the parent had already terminated by the time of the check). Modifying the script with an if ($parent) check neatly handles this case without causing an error.
Get-Member helped us discover the "hidden" Parent property, which provides powerful capabilities for analyzing the process hierarchy.

#### 4. The *.ps1* file (Creating scripts)

When your command chain becomes useful, you will want to save it for repeated use. This is what **scripts** are for—text files with the **`.ps1`** extension.

##### Permission to run scripts
By default, Windows prohibits the execution of local scripts. To fix this **for the current user**, run the following once in PowerShell **as an administrator**:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
This is a safe setting that allows you to run your own scripts and scripts signed by a trusted publisher.

##### Example script `system_monitor.ps1`
Create a file with this name and paste the code below into it. This script collects system information and generates reports.

```powershell
# system_monitor.ps1
#requires -Version 5.1

<#
.SYNOPSIS
    A script to create a system status report.
.DESCRIPTION
    Collects information about processes, services, and disk space and generates reports.
.PARAMETER OutputPath
    The path to save the reports. Defaults to 'C:\Temp'.
.EXAMPLE
    .\system_monitor.ps1 -OutputPath "C:\Reports"
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\Temp"
)

# --- Block 1: Preparation ---
Write-Host "Preparing to create the report..." -ForegroundColor Cyan
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# --- Block 2: Data collection ---
Write-Host "Collecting information..." -ForegroundColor Green
$processes = Get-Process | Sort-Object CPU -Descending
$services = Get-Service | Group-Object Status | Select-Object Name, Count

# --- Block 3: Calling the export function (see next section) ---
Export-Results -Processes $processes -Services $services -OutputPath $OutputPath

Write-Host "Reports successfully saved to the $OutputPath folder" -ForegroundColor Magenta
```
*Note: The `Export-Results` function will be defined in the next section as an example of good practice.*

#### 5. Exporting results

Raw data is good, but often it needs to be presented in a form that is convenient for a person or another program. PowerShell offers many cmdlets for exporting.

| Method | Command | Description |
|---|---|---|
| **Plain text** | `... \| Out-File C:\Temp\data.txt` | Redirects the text representation to a file. |
| **CSV (for Excel)** | `... \| Export-Csv C:\Temp\data.csv -NoTypeInfo` | Exports objects to CSV. `-NoTypeInfo` removes the service first line. |
| **HTML report** | `... \| ConvertTo-Html -Title "Report"` | Creates HTML code from objects. |
| **JSON (for API, web)** | `... \| ConvertTo-Json` | Converts objects to JSON format. |
| **XML (PowerShell's native format)** | `... \| Export-Clixml C:\Temp\data.xml` | Saves objects with all data types. They can be perfectly restored via `Import-Clixml`. |

##### Addition to the script: export function
Let's add a function to our `system_monitor.ps1` script that will handle exporting. Place this code **before** the `Export-Results` call.

```powershell
function Export-Results {
    param(
        $Processes,
        $Services,
        $OutputPath
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

    # Export to CSV
    $Processes | Select-Object -First 20 | Export-Csv (Join-Path $OutputPath "processes_$timestamp.csv") -NoTypeInformation
    $Services | Export-Csv (Join-Path $OutputPath "services_$timestamp.csv") -NoTypeInformation

    # Create a nice HTML report
    $htmlReportPath = Join-Path $OutputPath "report_$timestamp.html"
    $processesHtml = $Processes | Select-Object -First 10 Name, Id, CPU | ConvertTo-Html -Fragment -PreContent "<h2>Top 10 processes by CPU</h2>"
    $servicesHtml = $Services | ConvertTo-Html -Fragment -PreContent "<h2>Service statistics</h2>"

    ConvertTo-Html -Head "<title>System Report</title>" -Body "<h1>System report from $(Get-Date)</h1> $($processesHtml) $($servicesHtml)" | Out-File $htmlReportPath
}
```
Now our script not only collects data, but also neatly saves it in two formats: CSV for analysis and HTML for quick viewing.

#### Conclusion

1.  **The pipeline (`|`)** is the main tool for combining commands and processing objects.
2.  **`Get-Member`** is an object analyzer that shows what they are made of.
3.  **Variables (`$var`, `$_`)** allow you to save data and refer to the current object in the pipeline.
4.  **`.ps1` files** turn commands into reusable automation tools.
5.  **Export cmdlets** (`Export-Csv`, `ConvertTo-Html`) export data in the appropriate format.

**In the next part, we will apply this knowledge to navigate and manage the file system, exploring the `System.IO.DirectoryInfo` and `System.IO.FileInfo` objects.**
