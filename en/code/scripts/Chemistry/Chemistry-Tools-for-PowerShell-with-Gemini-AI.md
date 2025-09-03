# Chemistry Tools for PowerShell (with Gemini AI)

**Chemistry Tools** is a PowerShell module that provides the `Start-ChemistryExplorer` command for interactive exploration of chemical elements using Google Gemini AI.

This tool transforms your console into an intelligent reference, allowing you to query lists of elements by category, view them in a convenient filterable table (`Out-ConsoleGridView`), and obtain additional information about each.

 *(Recommended to replace with a real GIF animation of the script's operation)*

## 🚀 Installation and Setup

### Prerequisites

1.  **PowerShell 7.2+**.
2.  **Node.js (LTS):** [Install from here](https://nodejs.org/).
3.  **Google Gemini CLI:** Ensure the CLI is installed and authenticated.
    ```powershell
    # 1. Install Gemini CLI
    npm install -g @google/gemini-cli

    # 2. First run to log in to Google account
    gemini
    ```

### Step-by-step installation guide

#### Step 1: Create the correct folder structure (Mandatory!)

This is the most important step. For PowerShell to find your module, it must be in a folder with **exactly the same name** as the module itself.

1.  Find your personal PowerShell modules folder.
    ```powershell
    # This command will show the path, usually C:\Users\YourName\Documents\PowerShell\Modules
    $moduleBasePath = Split-Path $PROFILE.CurrentUserAllHosts
    $moduleBasePath
    ```2.  Create a folder for our module named `Chemistry` in it.
    ```powershell
    $modulePath = Join-Path $moduleBasePath "Chemistry"
    if (-not (Test-Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }
    ```
3.  Download and place the following files from the repository into this folder (`Chemistry`):
    *   `Chemistry.psm1` (main module code)
    *   `Chemistry.GEMINI.md` (AI instruction file)
    *   `Chemistry.psd1` (manifest file, optional but recommended)

Your final file structure should look like this:
```
...\Documents\PowerShell\Modules\
└── Chemistry\                <-- Module folder
    ├── Chemistry.psd1        <-- Manifest (optional)
    ├── Chemistry.psm1        <-- Main code
    └── Chemistry.GEMINI.md   <-- AI instructions
```

#### Step 2: Unblock files

If you downloaded files from the internet, Windows might block them. Run this command to resolve the issue:
```powershell
Get-ChildItem -Path $modulePath | Unblock-File
```

#### Step 3: Import and test the module

Restart PowerShell. The module should load automatically. To ensure the command is available, run:
```powershell
Get-Command -Module Chemistry
```
The output should be:
```
CommandType     Name                    Version    Source
-----------     ----                    -------    ------
Function        Start-ChemistryExplorer 1.0.0      Chemistry
```

## 💡 Usage

After installation, simply run the command in your console:
```powershell
Start-ChemistryExplorer
```
The script will greet you and prompt you to enter a category of chemical elements.
> `Starting interactive chemist's reference...`
> `Enter element category (e.g., 'noble gases') or 'exit'`
> `> noble gases`

After that, an interactive `Out-ConsoleGridView` window will appear with a list of elements. Select one of them, and Gemini will tell you interesting facts about it.

## 🛠️ Troubleshooting

*   **Error "module not found"**:
    1.  **Restart PowerShell.** This solves the problem in 90% of cases.
    2.  Double-check **Step 1**. The folder name (`Chemistry`) and file name (`Chemistry.psm1` or `Chemistry.psd1`) must be correct.

*   **Command `Start-ChemistryExplorer` not found after import**:
    1.  Ensure that your `Chemistry.psm1` file has the line `Export-ModuleMember -Function Start-ChemistryExplorer` at the end.
    2.  If you are using a manifest (`.psd1`), ensure that the `FunctionsToExport = 'Start-ChemistryExplorer'` field is populated in it.
