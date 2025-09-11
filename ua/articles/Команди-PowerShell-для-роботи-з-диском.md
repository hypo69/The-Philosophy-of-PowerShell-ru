### Діагностика та відновлення дисків за допомогою PowerShell

PowerShell дозволяє автоматизувати перевірки, виконувати віддалену діагностику та створювати гнучкі скрипти для моніторингу. Цей посібник проведе вас від базових перевірок до глибокої діагностики та відновлення дисків.

**Версія:** Посібник актуальний для **Windows 10/11** та **Windows Server 2016+**.

### Ключові командлети для роботи з дисками

| Командлет | Призначення |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Інформація про фізичні диски (модель, стан здоров'я). |
| **`Get-Disk`** | Інформація про диски на рівні пристрою (статус Online/Offline, стиль розділів). |
| **`Get-Partition`** | Інформація про розділи на дисках. |
| **`Get-Volume`** | Інформація про логічні томи (літери дисків, файлова система, вільне місце). |
| **`Repair-Volume`** | Перевірка та відновлення логічних томів (аналог `chkdsk`). |
| **`Get-StoragePool`** | Використовується для роботи з дисковими просторами (Storage Spaces). |

---

### Крок 1: Базова перевірка стану системи

Почніть із загальної оцінки стану дискової підсистеми.

#### Перегляд усіх підключених дисків

Команда `Get-Disk` надає зведену інформацію про всі диски, які бачить операційна система.

```powershell
Get-Disk
```

Ви побачите таблицю з номерами дисків, їх розмірами, статусом (`Online` або `Offline`) та стилем розділів (`MBR` або `GPT`).

**Приклад:** Знайти всі диски, які знаходяться в офлайні.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Перевірка фізичного «здоров'я» дисків

Командлет `Get-PhysicalDisk` звертається до стану самого обладнання.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Зверніть особливу увагу на поле `HealthStatus`. Воно може приймати значення:
*   **Healthy:** Диск у порядку.
*   **Warning:** Є проблеми, потрібна увага (наприклад, перевищення порогів S.M.A.R.T.).
*   **Unhealthy:** Диск у критичному стані та може відмовити.

---

### Крок 2: Аналіз та відновлення логічних томів

Після перевірки фізичного стану переходимо до логічної структури — томів та файлової системи.

#### Інформація про логічні томи

Команда `Get-Volume` показує всі змонтовані томи в системі.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Ключові поля:
*   `DriveLetter` — Літера тому (C, D тощо).
*   `FileSystem` — Тип файлової системи (NTFS, ReFS, FAT32).
*   `HealthStatus` — Стан тому.
*   `SizeRemaining` та `Size` — Вільний та загальний простір.

#### Перевірка та відновлення тому (аналог `chkdsk`)

Командлет `Repair-Volume` — це сучасна заміна утиліти `chkdsk`.

**1. Перевірка тому без виправлень (тільки сканування)**

Цей режим безпечний для виконання на працюючій системі, він тільки шукає помилки.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Повне сканування та виправлення помилок**

Цей режим є аналогом `chkdsk C: /f`. Він блокує том на час роботи, тому для системного диска знадобиться перезавантаження.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Важливо:** Якщо ви запускаєте цю команду для системного диска (C:), PowerShell запланує перевірку при наступному завантаженні системи. Щоб запустити її негайно, перезавантажте комп'ютер.

**Приклад:** Автоматично перевірити та виправити всі томи, стан яких відрізняється від `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Repairing volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Крок 3: Глибока діагностика та S.M.A.R.T.

Якщо базові перевірки не виявили проблем, але підозри залишилися, можна копнути глибше.

#### Аналіз системних журналів

Помилки дискової підсистеми часто фіксуються в системному журналі Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
Для більш точного пошуку можна фільтрувати за джерелом події:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Перевірка статусу S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) — технологія самодіагностики дисків. PowerShell дозволяє отримати ці дані.

**Спосіб 1: Використання WMI (для сумісності)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
Якщо `PredictFailure = True`, диск передбачає швидкий збій. Це сигнал до негайної заміни.

**Спосіб 2: Сучасний підхід через CIM та Storage-модулі**

Більш сучасний та докладний спосіб — використовувати командлет `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
Цей командлет надає цінну інформацію, таку як знос (актуально для SSD), температуру та кількість помилок читання/запису.

---

### Практичні сценарії для системного адміністратора

Ось кілька готових прикладів для повсякденних завдань.

**1. Отримати короткий звіт про здоров'я всіх фізичних дисків.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Створити CSV-звіт про вільне місце на всіх томах.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Знайти всі розділи на конкретному диску (наприклад, диску 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Запустити діагностику системного диска з подальшим перезавантаженням.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```
