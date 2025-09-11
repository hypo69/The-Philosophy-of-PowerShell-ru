# Verwaltung der Netzwerkadapter-Energie Wake-on-LAN mit PowerShell.

Detaillierte Anleitung zur Konfiguration von Wake-on-LAN mit PowerShell, die die grundlegenden Befehle und Lösungsansätze für typische Probleme behandelt, die aufgrund von Unterschieden in den Treibern der Netzwerkadapter auftreten.

#### Schritt 1: Geräteidentifikation.

Bevor Sie Wake-on-LAN (WOL) für einen Netzwerkadapter konfigurieren, müssen Sie genau bestimmen, mit welchem Gerät Sie arbeiten. Dazu verwenden wir einen PowerShell-Befehl, der Geräte nach einem Teil des Namens sucht (z. B. "Realtek" oder "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

Dieser Befehl weist das System an:
> "Zeige mir alle Geräte, deren Name das Wort «Realtek» enthält, und gib eine Tabelle mit vier Spalten aus: vollständiger Name, Status, Klasse und System-ID."

1.  **`Get-PnpDevice`**: Ruft die vollständige Liste aller Plug-and-Play-Geräte ab.
2.  **`|` (Pipeline)**: Leitet die Liste weiter.
3.  **`Where-Object { ... }`**: Filtert die Liste und behält nur Geräte, deren Name (`FriendlyName`) "Realtek" enthält.
4.  **`|` (Pipeline)**: Leitet die gefilterte Liste weiter.
5.  **`Select-Object ...`**: Formatiert die Ausgabe und zeigt nur die benötigten Eigenschaften an.

*Finden Sie das gewünschte Gerät und nehmen Sie das erste aus der Liste*

```powershell
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*Schreiben Sie seine Eigenschaften in Variablen*

$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### Schritt 2: Globale Aktivierung des Aufweckens

Der Befehl `powercfg` erteilt dem Gerät die "offizielle" Erlaubnis von Windows, das System aufzuwecken.
```powershell
powercfg -deviceenablewake $DeviceName
```
Dieser Befehl entspricht dem Setzen des Häkchens "Diesem Gerät erlauben, den Computer aus dem Ruhezustand zu wecken".

Die Umkehrung davon ist die Deaktivierung:
```powershell
powercfg -devicedisablewake $DeviceName
```
#### Schritt 3: Treibereinstellungen.
Die WOL-Einstellungen befinden sich in den Parametern des Treibers selbst, die in der Registrierung gespeichert sind.
Aby ustawić znacznik **"Nur Magic Packet erlauben, den Computer aus dem Ruhezustand zu wecken"**,
verwenden Sie den Befehl `Set-ItemProperty`.

```powershell
# Eigenschaft setzen
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
Die Umkehrung davon ist die Deaktivierung von WOL (`Value 0`):
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **Problem** Der Name dieses Parameters kann je nach Hersteller variieren. Zum Beispiel ist es für **Intel** `*WakeOnMagicPacket`, während es für **Realtek** — `WakeOnMagicPacket` (ohne `*`) ist. Wenn die Einstellung nicht angewendet wird, überprüfen Sie den korrekten Namen mit dem Befehl `Get-ItemProperty -Path $pmKey` und verwenden Sie diesen.

### Schritt 4: Abschließende Konfiguration über CIM
Um sicherzustellen, dass die Energieverwaltungseinstellungen korrekt angewendet werden, verwenden wir den modernen Standard **CIM** (Common Information Model).

```powershell
# Finden Sie das CIM-Objekt, das mit unserem Gerät verknüpft ist
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# Wenden Sie die Änderungen darauf an
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

![1](../assets/manage-wol/1.png)

```
