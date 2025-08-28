# Managing Network Adapter Power Wake-on-LAN with PowerShell.

A detailed guide to configuring Wake-on-LAN using PowerShell, covering basic commands and troubleshooting common issues arising from differences in network adapter drivers.

#### Step 1: Device Identification.

Before configuring Wake-on-LAN (WOL) for a network adapter, you need to accurately identify which device you are working with. For this, we use a PowerShell command that searches for devices by part of their name (e.g., "Realtek" or "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

This command tells the system:
> "Show me all devices whose name contains the word «Realtek», and display a table with four columns for them: full name, status, class, and system ID."

1.  **`Get-PnpDevice`**: Retrieves a complete list of all Plug-and-Play devices.
2.  **`|` (Pipeline)**: Passes the list further.
3.  **`Where-Object { ... }`**: Filters the list, keeping devices whose name (`FriendlyName`) contains "Realtek".
4.  **`|` (Pipeline)**: Passes the filtered list.
5.  **`Select-Object ...`**: Formats the output, showing only the necessary properties.

*Find the desired device and take the first one from the list*

```powershell
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*Write its properties to variables*

$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### Step 2: Global Wake-up Permission

The `powercfg` command gives the device "official" permission from Windows to wake up the system.
```powershell
powercfg -deviceenablewake $DeviceName
```
This command is equivalent to checking the "Allow this device to wake the computer" box.

Its reverse action is disabling:
```powershell
powercfg -devicedisablewake $DeviceName
```
#### Step 3: Driver Configuration.
`WOL` settings are located in the driver's own parameters, which are stored in the registry.
To check the box **"Only allow a magic packet to wake the computer"**,
use the `Set-ItemProperty` command.

```powershell
# Set the property
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
Reverse action — disabling WOL (`Value 0`):
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **Problem** The name of this parameter may differ among manufacturers. For example, for **Intel** it is `*WakeOnMagicPacket`, and for **Realtek** — `WakeOnMagicPacket` (without `*`). If the setting is not applied, check the correct name with the `Get-ItemProperty -Path $pmKey` command and use it.

### Step 4: Final Configuration via CIM
To ensure that power management settings are applied correctly, we use the modern **CIM** (Common Information Model) standard.

```powershell
# Find the CIM object associated with our device
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# Apply changes to it
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

![1](../assets/manage-wol/1.png)
```