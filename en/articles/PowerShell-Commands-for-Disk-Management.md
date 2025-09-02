### Disk Diagnostics and Recovery with PowerShell

PowerShell allows you to automate checks, perform remote diagnostics, and create flexible scripts for monitoring. This guide will walk you through basic checks to in-depth disk diagnostics and recovery.

**Version:** This guide is relevant for **Windows 10/11** and **Windows Server 2016+**.

### Key Cmdlets for Disk Management

| Cmdlet | Purpose |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Information about physical disks (model, health status). |
| **`Get-Disk`** | Information about disks at the device level (Online/Offline status, partition style). |
| **`Get-Partition`** | Information about partitions on disks. |
| **`Get-Volume`** | Information about logical volumes (drive letters, file system, free space). |
| **`Repair-Volume`** | Check and repair logical volumes (analogous to `chkdsk`). |
| **`Get-StoragePool`** | Used for working with Storage Spaces. |

---

### Step 1: Basic System Health Check

Start with a general assessment of the disk subsystem's health.

#### Viewing All Connected Disks

The `Get-Disk` command provides summary information about all disks seen by the operating system.

```powershell
Get-Disk
```

You will see a table with disk numbers, their sizes, status (`Online` or `Offline`), and partition style (`MBR` or `GPT`).

**Example:** Find all disks that are offline.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Checking Physical Disk Health

The `Get-PhysicalDisk` cmdlet accesses the hardware's status.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Pay special attention to the `HealthStatus` field. It can take the following values:
*   **Healthy:** Disk is okay.
*   **Warning:** There are issues, attention is required (e.g., S.M.A.R.T. thresholds exceeded).
*   **Unhealthy:** Disk is in a critical state and may fail.

---

### Step 2: Analyzing and Recovering Logical Volumes

After checking the physical condition, we move to the logical structure — volumes and the file system.

#### Information about Logical Volumes

The `Get-Volume` command shows all mounted volumes in the system.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Key fields:
*   `DriveLetter` — Volume letter (C, D, etc.).
*   `FileSystem` — File system type (NTFS, ReFS, FAT32).
*   `HealthStatus` — Volume status.
*   `SizeRemaining` and `Size` — Free and total space.

#### Checking and Repairing a Volume (analogous to `chkdsk`)

The `Repair-Volume` cmdlet is a modern replacement for the `chkdsk` utility.

**1. Checking a Volume Without Repairs (scan only)**

This mode is safe to run on a running system; it only looks for errors.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Full Scan and Error Correction**

This mode is analogous to `chkdsk C: /f`. It locks the volume during operation, so a reboot will be required for the system drive.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Important:** If you run this command for the system drive (C:), PowerShell will schedule a check on the next system boot. To run it immediately, restart your computer.

**Example:** Automatically check and repair all volumes whose status is not `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Repairing volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Step 3: In-depth Diagnostics and S.M.A.R.T.

If basic checks did not reveal problems, but suspicions remain, you can dig deeper.

#### Analyzing System Logs

Disk subsystem errors are often recorded in the Windows system log.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
For more precise searching, you can filter by event source:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Checking S.M.A.R.T. Status

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) is a disk self-diagnosis technology. PowerShell allows you to get this data.

**Method 1: Using WMI (for compatibility)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
If `PredictFailure = True`, the disk predicts an imminent failure. This is a signal for immediate replacement.

**Method 2: Modern Approach via CIM and Storage Modules**

A more modern and detailed way is to use the `Get-StorageReliabilityCounter` cmdlet.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
This cmdlet provides valuable information, such as wear (relevant for SSDs), temperature, and the number of read/write errors.

---

### Practical Scenarios for a System Administrator

Here are some ready-to-use examples for everyday tasks.

**1. Get a brief report on the health of all physical disks.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Create a CSV report on free space on all volumes.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Find all partitions on a specific disk (e.g., disk 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Run system disk diagnostics with a subsequent reboot.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```