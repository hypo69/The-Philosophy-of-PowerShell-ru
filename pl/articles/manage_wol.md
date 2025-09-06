# Zarządzanie zasilaniem karty sieciowej Wake-on-LAN za pomocą PowerShell.

Szczegółowy przewodnik konfiguracji Wake-on-LAN (WOL) za pomocą PowerShell, który omawia podstawowe polecenia i sposoby rozwiązywania typowych problemów wynikających z różnic w sterownikach kart sieciowych.

#### Krok 1: Identyfikacja urządzenia.

Zanim skonfigurujesz Wake-on-LAN (WOL) dla karty sieciowej, musisz dokładnie określić, z jakim urządzeniem pracujesz. W tym celu użyjemy polecenia PowerShell, które wyszukuje urządzenia po części nazwy (np. "Realtek" lub "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

To polecenie mówi systemowi:
> "Pokaż mi wszystkie urządzenia, w których nazwie znajduje się słowo «Realtek», i wyświetl dla nich tabelę z czterema kolumnami: pełna nazwa, status, klasa i identyfikator systemowy."

1.  **`Get-PnpDevice`**: Pobiera pełną listę wszystkich urządzeń Plug-and-Play.
2.  **`|` (Potok)**: Przekazuje listę dalej.
3.  **`Where-Object { ... }`**: Filtruje listę, pozostawiając urządzenia, których nazwa (`FriendlyName`) zawiera "Realtek".
4.  **`|` (Potok)**: Przekazuje przefiltrowaną listę.
5.  **`Select-Object ...`**: Formatuje wyjście, pokazując tylko potrzebne właściwości.

*Znajdujemy potrzebne urządzenie i bierzemy pierwsze z listy*

```powershell
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*Zapisujemy jego właściwości do zmiennych*

$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### Krok 2: Globalne zezwolenie na wybudzanie

Polecenie `powercfg` daje urządzeniu "oficjalne" zezwolenie od Windows na wybudzanie systemu.
```powershell
powercfg -deviceenablewake $DeviceName
```
To polecenie jest równoważne zaznaczeniu pola "Zezwól temu urządzeniu na wybudzanie komputera ze stanu uśpienia".

Jego odwrotne działanie — wyłączenie:
```powershell
powercfg -devicedisablewake $DeviceName
```
#### Krok 3: Konfiguracja sterownika.
Ustawienia WOL znajdują się w parametrach samego sterownika, które są przechowywane w rejestrze.
Aby zaznaczyć pole **"Zezwalaj tylko pakietowi magicznemu na wybudzanie komputera ze stanu uśpienia"**,
korzystamy z polecenia `Set-ItemProperty`.

```powershell
# Ustawiamy właściwość
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
Odwrotne działanie — wyłączenie WOL (`Value 0`):
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **Problem** Nazwa tego parametru może się różnić u różnych producentów. Na przykład dla **Intel** to `*WakeOnMagicPacket`, a dla **Realtek** — `WakeOnMagicPacket` (bez `*`). Jeśli ustawienie nie działa, sprawdź poprawną nazwę za pomocą polecenia `Get-ItemProperty -Path $pmKey` i użyj jej.

### Krok 4: Końcowa konfiguracja przez CIM
Aby mieć pewność, że ustawienia zarządzania zasilaniem zostały zastosowane prawidłowo, użyjemy nowoczesnego standardu **CIM** (Common Information Model).

```powershell
# Znajdujemy obiekt CIM powiązany z naszym urządzeniem
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# Stosujemy do niego zmiany
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

!(../assets/manage-wol/1.png)
