# Let's Embed AI in PowerShell. Part Two: The Specification Finder

Last time, we saw how we can interact with the Gemini model through the command-line interface using PowerShell.
In this article, I will show you how to benefit from our knowledge.
We will turn our console into an interactive reference guide that takes a component identifier (brand, model, category, part number, etc.) as input and returns an interactive table with specifications obtained from the Gemini model.

Engineers, developers, and other specialists often need to find the exact parameters of, for example, a motherboard, a circuit breaker in an electrical panel, or a network switch. Our reference guide will always be at hand and, upon request, will gather information, clarify parameters on the internet, and return the desired table. In the table, you can select the necessary parameter(s) and, if needed, continue with a more in-depth search. Later, we will learn how to pass the result down the pipeline for further processing: exporting to an Excel or Google spreadsheet, storing in a database, or transferring to another program. In case of failure, the model will advise which parameters need to be clarified. But see for yourself:

[video](https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f" type="video/mp4">
  Your browser does not support the video tag.
</video>



## How the AI-Powered Finder Works: From Launch to Result

Let's trace the entire lifecycle of our script—what happens from the moment it's launched until the results are obtained.

## Initialization: Preparing for Work

The script accepts a `$Model` parameter with validation—you can choose 'gemini-2.5-flash' (the default, fast model) or 'gemini-2.5-pro' (more powerful). Upon launch, the script first sets up the working environment. It sets the API key for access to Gemini AI, defines the current folder as the base directory, and creates a structure for storing files. For each session, a file with a timestamp is created, for example, `ai_session_2025-08-26_14-30-15.jsonl`. This is the dialogue history.

Next, the system checks that all necessary tools are installed. It looks for the Gemini CLI in the system and checks for configuration files in the `.gemini/` folder. The `GEMINI.md` file is particularly important—it contains the system prompt for the model and is automatically loaded by the Gemini CLI at startup. This is the standard location for system instructions. The `ShowHelp.md` file, which contains help information, is also checked. If anything critical is missing, the script warns the user or terminates.

## Starting Interactive Mode

After successful initialization, the script displays a welcome message indicating the selected model ("AI Specification Finder. Model: 'gemini-2.5-flash'."), the path to the session file, and instructions for commands. It then enters interactive mode—it shows a prompt and waits for user input. The prompt looks like `🤖AI :) > ` and changes to `🤖AI [Selection active] :) > ` when the system has data for analysis.

## Processing User Input

Every user input is first checked for service commands by the `Command-Handler` function. This function recognizes commands like `?` (help from the ShowHelp.md file), `history` (show session history), `clear` and `clear-history` (clear the history file), `gemini help` (CLI help), and `exit` and `quit` (exit). If it's a service command, it is executed immediately without contacting the AI, and the loop continues.

If it's a regular query, the system starts building the context to send to Gemini. It reads the entire history of the current session from the JSONL file (if it exists), adds a block with data from the previous selection (if there is an active selection), and combines all of this with the new user query into a structured prompt with sections "DIALOGUE HISTORY," "DATA FROM SELECTION," and "NEW TASK." After use, the selection data is cleared.

## Interacting with the Artificial Intelligence

The formed prompt is sent to Gemini via the command line with the call `& gemini -m $Model -p $Prompt 2>&1`. The system captures all output (including errors via `2>&1`), checks the return code, and cleans the result of CLI service messages ("Data collection is disabled" and "Loaded cached credentials"). If an error occurs at this stage, the user receives a warning, but the script continues to run.

## Processing the AI's Response

The system attempts to interpret the response received from the AI as JSON. First, it looks for a code block in the format ```json...```, extracts the content, and tries to parse it. If there is no such block, it parses the entire response. If parsing is successful, the data is displayed in an interactive `Out-ConsoleGridView` table with the title "Select rows for the next query (OK) or close (Cancel)" and multiple selection enabled. If the JSON is not recognized (parsing error), the response is shown as plain text in blue.

## Working with Data Selection

When the user selects rows in the table and clicks OK, the system performs several actions. First, the `Show-SelectionTable` function is called, which analyzes the structure of the selected data: if they are objects with properties, it identifies all unique fields and displays the data using `Format-Table` with auto-sizing and wrapping. If they are simple values, it displays them as a numbered list. It then outputs a counter of the selected items and the message "Selection saved. Add your next query (e.g., 'compare them')."

The selected data is converted to a compressed JSON with a nesting depth of 10 levels and saved in the `$selectionContextJson` variable for use in subsequent requests to the AI.

## Maintaining History

Each "user query - AI response" pair is saved to the history file in JSONL format. This ensures the continuity of the dialogue—the AI "remembers" the entire previous conversation and can refer to previously discussed topics.

## The Cycle Continues

After processing the request, the system returns to waiting for new input. If the user has an active selection, this is reflected in the command-line prompt. The cycle continues until the user enters an exit command.

## Practical Example of Operation

Imagine a user runs the script and enters "RTX 4070 Ti Super":

1.  **Context Preparation:** The system takes the system prompt from the file, adds the history (currently empty), and the new query.
2.  **AI Request:** The full prompt is sent to Gemini with a request to find the specifications of the video cards.
3.  **Data Retrieval:** The AI returns a JSON with an array of objects containing information about various RTX 4070 Ti Super models.
4.  **Interactive Table:** The user sees a table with manufacturers, specifications, and prices, and selects 2-3 models of interest.
5.  **Displaying the Selection:** A table with the selected models appears in the console, and the prompt changes to `[Selection active]`.
6.  **Refining Query:** The user types "compare their gaming performance."
7.  **Contextual Analysis:** The AI receives the initial query, the selected models, and the new question, providing a detailed comparison of those specific cards.

## Termination

When `exit` or `quit` is entered, the script terminates correctly, having saved the entire session history to a file. The user can return to this dialogue at any time by viewing the contents of the corresponding file in the `.chat_history` folder.

All this complex logic is hidden from the user behind a simple command-line interface. The person simply asks questions and receives structured answers, while the system takes care of all the work of maintaining context, parsing data, and managing the state of the dialogue.

---


## Step 1: Setup

```powershell
# --- Step 1: Setup ---
$env:GEMINI_API_KEY = "AIzaSyCbq8bkt5Xr2hlE-73MIXFpdFYH-rLBd0k"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
# --- CHANGE: Variable renamed ---
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
# --- END CHANGE ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName
```

**Purpose of the lines:**

- `$env:GEMINI_API_KEY = "..."` - sets the API key for accessing the Gemini AI.
- `if (-not $env:GEMINI_API_KEY)` - checks for the key and terminates the script if it's missing.
- `$scriptRoot = Get-Location` - gets the current working directory.
- `$HistoryDir = Join-Path...` - forms the path to the folder for storing dialogue history (`.gemini/.chat_history`).
- `$timestamp = Get-Date...` - creates a timestamp in the format `2025-08-26_14-30-15`.
- `$historyFileName = "ai_session_$timestamp.jsonl"` - generates a unique session filename.
- `$historyFilePath = Join-Path...` - creates the full path to the current session's history file.

## Environment Check - What Should Be Installed

```powershell
# --- Step 2: Environment Check ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } 
catch { Write-Error "Command 'gemini' not found..."; return }

if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { 
    Write-Warning "System prompt file .gemini/GEMINI.md not found..." 
}
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { 
    Write-Warning "Help file .gemini/ShowHelp.md not found..." 
}
```

**What is checked:**

- The presence of **Gemini CLI** in the system - the script won't work without it.
- The **GEMINI.md** file - contains the system prompt (instructions for the AI).
- The **ShowHelp.md** file - user help (the `?` command).

## Main Function for Interacting with AI

```powershell
function Invoke-GeminiPrompt {
    param([string]$Prompt, [string]$Model)
    try {
        $output = & gemini -m $Model -p $Prompt 2>&1
        if (-not $?) { $output | ForEach-Object { Write-Warning $_.ToString() }; return $null }
        
        $outputString = ($output -join [Environment]::NewLine).Trim()
        $cleanedOutput = $outputString -replace "(?m)^Data collection is disabled\.`r?`n" , ""
        $cleanedOutput = $cleanedOutput -replace "(?m)^Loaded cached credentials\.`r?`n", ""
        
        return $cleanedOutput.Trim()
    }
    catch { Write-Error "Critical error when calling Gemini CLI: $_"; return $null }
}
```

**Function tasks:**
- Calls the Gemini CLI with the specified model and prompt.
- Captures all output (including errors).
- Cleans the result of CLI service messages.
- Returns the clean AI response or `$null` on error.

## History Management Functions

```powershell
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}

function Show-History {
    if (-not (Test-Path $historyFilePath)) { Write-Host "Current session history is empty." -ForegroundColor Yellow; return }
    Write-Host "`n--- Current Session History ---" -ForegroundColor Cyan
    Get-Content -Path $historyFilePath
    Write-Host "------------------------------------`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $historyFilePath) {
        Remove-Item -Path $historyFilePath -Force -ErrorAction Stop
        Write-Host "Current session history ($historyFileName) has been deleted." -ForegroundColor Yellow
    }
}
```

**Purpose:**
- `Add-History` - saves "question-answer" pairs in JSONL format.
- `Show-History` - displays the contents of the history file.
- `Clear-History` - deletes the current session's history file.

## Function for Displaying Selected Data

```powershell
function Show-SelectionTable {
    param([array]$SelectedData)
    
    if ($null -eq $SelectedData -or $SelectedData.Count -eq 0) { return }
    
    Write-Host "`n--- SELECTED DATA ---" -ForegroundColor Yellow
    
    # Get all unique properties from the selected objects
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # Show a table or a list
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    } else {
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
    
    Write-Host "-------------------------" -ForegroundColor Yellow
    Write-Host "Items selected: $($SelectedData.Count)" -ForegroundColor Magenta
}
```

**Function's task:** After selecting items in `Out-ConsoleGridView`, it displays them in the console as a neat table, so the user can see exactly what was chosen.

## Main Working Loop

```powershell
while ($true) {
    # Display prompt with state indicator
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [Selection active] :) > "
    } else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    
    $UserPrompt = Read-Host
    
    # Handle service commands
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }
    
    # Form the full prompt with context
    $fullPrompt = @"
### DIALOGUE HISTORY (CONTEXT)
$historyContent

### DATA FROM SELECTION (FOR ANALYSIS)
$selectionContextJson

### NEW TASK
$UserPrompt
"@
    
    # Call AI and process the response
    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
    
    # Try to parse JSON and show the interactive table
    try {
        $jsonObject = $jsonToParse | ConvertFrom-Json
        $gridSelection = $jsonObject | Out-ConsoleGridView -Title "Select rows..." -OutputMode Multiple
        
        if ($null -ne $gridSelection) {
            Show-SelectionTable -SelectedData $gridSelection
            $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
        }
    }
    catch {
        Write-Host $ModelResponse -ForegroundColor Cyan
    }
    
    Add-History -UserPrompt $UserPrompt -ModelResponse $ModelResponse
}
```

**Key features:**
- The `[Selection active]` indicator shows that there is data for analysis.
- Each query includes the entire dialogue history to maintain context.
- The AI receives both the history and the user-selected data.
- The result is attempted to be displayed as an interactive table.
- If JSON parsing fails, plain text is shown.

## Working Files Structure

The script creates the following structure:
```
├── Find-Spec.ps1
├── .gemini/
│   ├── GEMINI.md              # System prompt for AI
│   ├── ShowHelp.md            # User help
│   └── .chat_history/         # Folder with session history
│       ├── ai_session_2025-08-26_10-15-30.jsonl
│       └── ai_session_2025-08-26_14-22-45.jsonl
```

The `GEMINI.md` file in the `.gemini/` folder is the standard location for the system prompt for the Gemini CLI. On each run, the model automatically loads instructions from this file, which defines its behavior and response format.


In the next part, we will look at the contents of the configuration files and practical usage examples.
