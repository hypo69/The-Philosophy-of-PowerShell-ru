# Управление питанием сетевого адаптера Wake-on-LAN с PowerShell.

#### Шаг 1: Идентификация устройства.

Прежде чем настраивать Wake-on-LAN (WOL) для сетевого адаптера, нужно точно определить, с каким устройством мы работаем. Для этого используем команду PowerShell, которая ищет устройства по части имени (например, "Realtek" или "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

Эта команда говорит системе:
> "Покажи мне все устройства, в названии которых есть слово «Realtek», и выведи по ним таблицу с четырьмя колонками: полное имя, статус, класс и системный ID."

1.  **`Get-PnpDevice`**: Берет полный список всех Plug-and-Play устройств.
2.  **`|` (Конвейер)**: Передает список дальше.
3.  **`Where-Object { ... }`**: Фильтрует список, оставляя устройства, чье имя (`FriendlyName`) содержит "Realtek".
4.  **`|` (Конвейер)**: Передает отфильтрованный список.
5.  **`Select-Object ...`**: Форматирует вывод, показывая только нужные свойства.

Теперь, когда мы нашли устройство, сохраним его данные в переменные для дальнейшей работы.```powershell
*Находим нужное устройство и берем первое из списка*
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*Записываем его свойства в переменные*
$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### Шаг 2: Глобальное разрешение на пробуждение

Команда `powercfg` дает устройству "официальное" разрешение от Windows на пробуждение системы.
```powershell
powercfg -deviceenablewake $DeviceName
```
Эта команда эквивалентна установке флажка "Разрешить этому устройству выводить компьютер из ждущего режима".

Ее обратное действие — отключение:
```powershell
powercfg -devicedisablewake $DeviceName
```
#### Шаг 3: Настройка драйвера.
Настройки WOL находятся в параметрах самого драйвера, которые хранятся в реестре. 
Чтобы установить флажок **"Только разрешать магическому пакету выводить компьютер из ждущего режима"**, 
используем команду `Set-ItemProperty`.

```powershell
# Устанавливаем свойство
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
Обратное действие — отключение WOL (`Value 0`):
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **Проблема** Имя этого параметра может отличаться у разных производителей. Например, для **Intel** это `*WakeOnMagicPacket`, а для **Realtek** — `WakeOnMagicPacket` (без `*`). Если настройка не применяется, проверьте правильное имя командой `Get-ItemProperty -Path $pmKey` и используйте его.

### Шаг 4: Завершающая настройка через CIM
Для полной уверенности в том, что настройки управления питанием применены корректно, используем современный стандарт **CIM** (Common Information Model).

```powershell
# Находим CIM-объект, связанный с нашим устройством
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# Применяем к нему изменения
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

![1](../assets/manage-wol/1.png)