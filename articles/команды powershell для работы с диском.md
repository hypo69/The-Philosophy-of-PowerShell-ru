### Диагностика и восстановление дисков с помощью PowerShell

PowerShell позволяет автоматизировать проверки, выполнять удалённую диагностику и создавать гибкие скрипты для мониторинга. Это руководство проведёт вас от базовых проверок до глубокой диагностики и восстановления дисков.

**Версия:** Руководство актуально для **Windows 10/11** и **Windows Server 2016+**.

### Ключевые командлеты для работы с дисками

| Командлет | Назначение |
| :--- | :--- |
| **`Get-PhysicalDisk`** | Информация о физических дисках (модель, состояние здоровья). |
| **`Get-Disk`** | Информация о дисках на уровне устройства (статус Online/Offline, стиль разделов). |
| **`Get-Partition`** | Информация о разделах на дисках. |
| **`Get-Volume`** | Информация о логических томах (буквы дисков, файловая система, свободное место). |
| **`Repair-Volume`** | Проверка и восстановление логических томов (аналог `chkdsk`). |
| **`Get-StoragePool`** | Используется для работы с дисковыми пространствами (Storage Spaces). |

---

### Шаг 1: Базовая проверка состояния системы

Начните с общей оценки состояния дисковой подсистемы.

#### Просмотр всех подключенных дисков

Команда `Get-Disk` предоставляет сводную информацию о всех дисках, которые видит операционная система.

```powershell
Get-Disk
```

Вы увидите таблицу с номерами дисков, их размерами, статусом (`Online` или `Offline`) и стилем разделов (`MBR` или `GPT`).

**Пример:** Найти все диски, которые находятся в офлайне.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### Проверка физического «здоровья» дисков

Командлет `Get-PhysicalDisk` обращается к состоянию самого оборудования.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
Обратите особое внимание на поле `HealthStatus`. Оно может принимать значения:
*   **Healthy:** Диск в порядке.
*   **Warning:** Есть проблемы, требуется внимание (например, превышение порогов S.M.A.R.T.).
*   **Unhealthy:** Диск в критическом состоянии и может отказать.

---

### Шаг 2: Анализ и восстановление логических томов

После проверки физического состояния переходим к логической структуре — томам и файловой системе.

#### Информация о логических томах

Команда `Get-Volume` показывает все смонтированные тома в системе.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

Ключевые поля:
*   `DriveLetter` — Буква тома (C, D и т.д.).
*   `FileSystem` — Тип файловой системы (NTFS, ReFS, FAT32).
*   `HealthStatus` — Состояние тома.
*   `SizeRemaining` и `Size` — Свободное и общее пространство.

#### Проверка и восстановление тома (аналог `chkdsk`)

Командлет `Repair-Volume` — это современная замена утилиты `chkdsk`.

**1. Проверка тома без исправлений (только сканирование)**

Этот режим безопасен для выполнения на работающей системе, он только ищет ошибки.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. Полное сканирование и исправление ошибок**

Этот режим является аналогом `chkdsk C: /f`. Он блокирует том на время работы, поэтому для системного диска потребуется перезагрузка.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **Важно:** Если вы запускаете эту команду для системного диска (C:), PowerShell запланирует проверку при следующей загрузке системы. Чтобы запустить её немедленно, перезагрузите компьютер.

**Пример:** Автоматически проверить и исправить все тома, состояние которых отлично от `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Repairing volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### Шаг 3: Глубокая диагностика и S.M.A.R.T.

Если базовые проверки не выявили проблем, но подозрения остались, можно копнуть глубже.

#### Анализ системных журналов

Ошибки дисковой подсистемы часто фиксируются в системном журнале Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
Для более точного поиска можно фильтровать по источнику события:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### Проверка статуса S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) — технология самодиагностики дисков. PowerShell позволяет получить эти данные.

**Способ 1: Использование WMI (для совместимости)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
Если `PredictFailure = True`, диск предсказывает скорый сбой. Это сигнал к немедленной замене.

**Способ 2: Современный подход через CIM и Storage-модули**

Более современный и подробный способ — использовать командлет `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
Этот командлет предоставляет ценную информацию, такую как износ (актуально для SSD), температуру и количество ошибок чтения/записи.

---

### Практические сценарии для системного администратора

Вот несколько готовых примеров для повседневных задач.

**1. Получить краткий отчет о здоровье всех физических дисков.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. Создать CSV-отчет о свободном месте на всех томах.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. Найти все разделы на конкретном диске (например, диске 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. Запустить диагностику системного диска с последующей перезагрузкой.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```