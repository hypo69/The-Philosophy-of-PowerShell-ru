Checking and managing Windows updates is an important task for maintaining system security and stability.
Unfortunately, standard PowerShell does not have built-in cmdlets for this. But there is an excellent third-party module called **`PSWindowsUpdate`**, which has become a kind of standard.

With the help of Gemini CLI, we can generate a script that uses this module to perform all necessary operations.

### **Step 1: Install the `PSWindowsUpdate` module**

Before running the script, you need to install this module. This is done once.

Open PowerShell as an administrator and run the following command:

```powershell
Install-Module -Name PSWindowsUpdate
```

If you see an error that "PowerShellGet" is outdated, or a warning about a "trusted repository", just follow the instructions in the console. Most likely, you will need to confirm the installation.

### **Step 2: Script for checking and installing updates**

After installing the module, you can use this script to check for updates and, if necessary, install them.

**Scenario:** You want to quickly check for new Windows updates and get a report.

**Command you can use in Gemini CLI:**

```powershell
gemini-cli "Write a PowerShell script that uses the PSWindowsUpdate module. The script should check for available Windows updates, display a list of them, and then, if updates are found, prompt the user to install them."
```

**Example of a generated script:**

```powershell
# Requires -Module PSWindowsUpdate

Write-Host "--- Checking and installing Windows updates ---" -ForegroundColor Green

# 1. Check for available updates
Write-Host "`nChecking for available updates..." -ForegroundColor Yellow
$availableUpdates = Get-WUList

if ($availableUpdates.Count -eq 0) {
    Write-Host "`nNo updates found. Your system is up to date." -ForegroundColor Green
} else {
    Write-Host "`nFound the following updates:" -ForegroundColor Yellow
    $availableUpdates | Format-Table -AutoSize

    # 2. Offer to install updates
    $installChoice = Read-Host "`nInstall found updates? (Y/N)"

    if ($installChoice -eq 'Y' -or $installChoice -eq 'y') {
        Write-Host "`nStarting update installation..." -ForegroundColor Yellow
        
        # Download and install updates
        Install-WindowsUpdate -AcceptAll -AutoReboot
        
        Write-Host "`nInstallation process completed. A reboot may be required." -ForegroundColor Green
    } else {
        Write-Host "`nInstallation canceled. Updates will not be installed." -ForegroundColor Red
    }
}

Write-Host "`n--- Completed ---" -ForegroundColor Green
```

### How it works?

  * **`Get-WUList`**: This is a key cmdlet from the `PSWindowsUpdate` module. It searches for available updates just like the standard Windows Update Center.
  * **`Read-Host`**: This command allows the script to interact with you, prompting for confirmation before installing updates.
  * **`Install-WindowsUpdate -AcceptAll -AutoReboot`**: If you agree, this cmdlet starts the installation process.
      * `-AcceptAll`: Automatically agrees to license agreements.
      * `-AutoReboot`: Automatically reboots the computer if necessary to complete the installation. You can remove this flag if you want to reboot manually.

This script gives you full control over the Windows update process, making it an excellent tool for system administration.
