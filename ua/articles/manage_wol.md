# Керування живленням мережевого адаптера Wake-on-LAN за допомогою PowerShell.

Детальний посібник з налаштування Wake-on-LAN (WOL) за допомогою PowerShell, у якому розглядаються основні команди та способи вирішення типових проблем, що виникають через відмінності в драйверах мережевих адаптерів.

#### Крок 1: Ідентифікація пристрою.

Перш ніж налаштовувати Wake-on-LAN (WOL) для мережевого адаптера, потрібно точно визначити, з яким пристроєм ми працюємо. Для цього використовуємо команду PowerShell, яка шукає пристрої за частиною імені (наприклад, "Realtek" або "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

Ця команда говорить системі:
> "Покажи мені всі пристрої, у назві яких є слово «Realtek», і виведи по них таблицю з чотирма колонками: повне ім'я, статус, клас та системний ID."

1.  **`Get-PnpDevice`**: Бере повний список усіх Plug-and-Play пристроїв.
2.  **`|` (Конвеєр)**: Передає список далі.
3.  **`Where-Object { ... }`**: Фільтрує список, залишаючи пристрої, чиє ім'я (`FriendlyName`) містить "Realtek".
4.  **`|` (Конвеєр)**: Передає відфільтрований список.
5.  **`Select-Object ...`**: Форматує вивід, показуючи лише потрібні властивості.

*Знаходимо потрібний пристрій і беремо перший зі списку*

```powershell
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*Записуємо його властивості у змінні*

$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### Крок 2: Глобальний дозвіл на пробудження

Команда `powercfg` дає пристрою "офіційний" дозвіл від Windows на пробудження системи.
```powershell
powercfg -deviceenablewake $DeviceName
```
Ця команда еквівалентна встановленню прапорця "Дозволити цьому пристрою виводити комп'ютер зі сплячого режиму".

Її зворотна дія — відключення:
```powershell
powercfg -devicedisablewake $DeviceName
```
#### Крок 3: Налаштування драйвера.
Налаштування WOL знаходяться в параметрах самого драйвера, які зберігаються в реєстрі.
Щоб встановити прапорець **"Дозволяти магічному пакету виводити комп'ютер зі сплячого режиму"**,
використовуємо команду `Set-ItemProperty`.

```powershell
# Встановлюємо властивість
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
Зворотна дія — відключення WOL (`Value 0`):
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **Проблема** Ім'я цього параметра може відрізнятися у різних виробників. Наприклад, для **Intel** це `*WakeOnMagicPacket`, а для **Realtek** — `WakeOnMagicPacket` (без `*`). Якщо налаштування не застосовується, перевірте правильне ім'я командою `Get-ItemProperty -Path $pmKey` і використовуйте його.

### Крок 4: Завершальне налаштування через CIM
Для повної впевненості в тому, що налаштування керування живленням застосовані коректно, використовуємо сучасний стандарт **CIM** (Common Information Model).

```powershell
# Знаходимо CIM-об'єкт, пов'язаний з нашим пристроєм
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# Застосовуємо до нього зміни
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

!(../assets/manage-wol/1.png)
