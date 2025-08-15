### **Практические примеры использования Out-ConsoleGridView**

В предыдущей главе мы познакомились с `Out-ConsoleGridView` — мощным инструментом для интерактивной работы с данными прямо в терминале. 
Эта статья полностью посвящена ему. Я не буду повторять теорию, а сразу перейду к практике и покажу 10 сценариев, в которых этот командлет может сэкономить системному администратору или продвинутому пользователю массу времени.

`Out-ConsoleGridView` — это не просто "просмотрщик". Это **интерактивный фильтр объектов** в середине вашего конвейера.

**Предварительные требования:**
*   PowerShell 7.2 или новее.
*   Установленный модуль `Microsoft.PowerShell.ConsoleGuiTools`. Если вы его еще не установили:
    ```powershell
    Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
    ```

---

### 10 практических примеров

#### Пример 1: Интерактивная остановка процессов

Классическая задача: найти и завершить несколько "зависших" или ненужных процессов.

```powershell
# Выбираем процессы в интерактивном режиме
$procsToStop = Get-Process | Sort-Object -Property CPU -Descending | Out-ConsoleGridView -OutputMode Multiple

# Если что-то было выбрано, передаем объекты на остановку
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```


[1](https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  `Get-Process` получает все запущенные процессы.
2.  `Sort-Object` упорядочивает их по загрузке CPU, чтобы самые "прожорливые" были наверху.
3.  `Out-ConsoleGridView` отображает таблицу. Вы можете ввести `chrome` или `notepad`, чтобы мгновенно отфильтровать список, и выбрать нужные процессы клавишей `Space`.
4.  После нажатия `Enter` выбранные **объекты** процессов попадают в переменную `$procsToStop` и передаются в `Stop-Process`.

#### Пример 2: Управление службами Windows

Нужно быстро перезапустить несколько служб, связанных с одним приложением (например, SQL Server).

```powershell
$services = Get-Service | Out-ConsoleGridView -OutputMode Multiple -Title "Выберите службы для перезапуска"

if ($services) {
    $services | Restart-Service -WhatIf
}
```

[1](https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Вы получаете список всех служб.
2.  Внутри `Out-ConsoleGridView` вы вводите в фильтр `sql` и сразу видите все службы, относящиеся к SQL Server.
3.  Выбираете нужные и нажимаете `Enter`. Объекты выбранных служб передаются на перезапуск.

#### Пример 3: Очистка папки "Загрузки" от больших файлов

Со временем папка "Загрузки" забивается ненужными файлами. Найдем и удалим самые большие из них.

```powershell

# --- ШАГ 1: Настройка пути к директории 'Downloads'
$DownloadsPath = "E:\Users\user\Downloads" # <--- ИЗМЕНИТЕ ЭТУ СТРОКУ НА ВАШ ПУТЬ
===========================================================================

# Проверка: если путь не указан или папка не существует - выходим.
if ([string]::IsNullOrEmpty($DownloadsPath) -or (-not (Test-Path -Path $DownloadsPath))) {
    Write-Error "Папка 'Загрузки' не найдена по указанному пути: '$DownloadsPath'. Пожалуйста, проверьте путь в блоке НАСТРОЙКА в начале скрипта."
    return
}

# --- ШАГ 2: Информирование пользователя и сбор данных ---
Write-Host "Начинаю сканирование папки '$DownloadsPath'. Это может занять некоторое время..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $DownloadsPath -File -Recurse -ErrorAction SilentlyContinue | 
    Sort-Object -Property Length -Descending

# --- ШАГ 3: Проверка наличия файлов и вызов интерактивного окна ---
if ($files) {
    Write-Host "Сканирование завершено. Найдено $($files.Count) файлов. Открытие окна выбора..." -ForegroundColor Green
    
    $filesToShow = $files | Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime
    
    $filesToDelete = $filesToShow | Out-ConsoleGridView -OutputMode Multiple -Title "Выберите файлы для удаления из '$DownloadsPath'"

    # --- ШАГ 4: Обработка выбора пользователя ---
    if ($filesToDelete) {
        Write-Host "Следующие файлы будут удалены:" -ForegroundColor Yellow
        $filesToDelete | Format-Table -AutoSize
        
        $filesToDelete.FullName | Remove-Item -WhatIf -Verbose
    } else {
        Write-Host "Операция отменена. Не выбрано ни одного файла." -ForegroundColor Yellow
    }
} else {
    Write-Host "В папке '$DownloadsPath' не найдено файлов." -ForegroundColor Yellow
}
```
[Clear-DownloadsFolder.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/scripts/Clear-DownloadsFolder.ps1)

[Содержимое Downloads](https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a" type="video/mp4">
  Your browser does not support the video tag.
</video>


1.  Мы получаем все файлы, сортируем их по размеру и с помощью `Select-Object` создаем удобную колонку `SizeMB`.
2.  В `Out-ConsoleGridView` вы видите отсортированный список, где легко выбрать старые и большие `.iso` или `.zip` файлы.
3.  После выбора их полные пути передаются в `Remove-Item`.

#### Пример 4: Добавление пользователей в группу Active Directory

Незаменимая вещь для администраторов AD.

```powershell
# Получаем пользователей из отдела Marketing
$users = Get-ADUser -Filter 'Department -eq "Marketing"' -Properties DisplayName

# Интерактивно выбираем, кого добавить
$usersToAdd = $users | Select-Object Name, DisplayName | Out-ConsoleGridView -OutputMode Multiple

if ($usersToAdd) {
    Add-ADGroupMember -Identity "Marketing-Global-Group" -Members $usersToAdd -WhatIf
}
```

Вместо того чтобы вручную вводить имена пользователей, вы получаете удобный список, где можете быстро найти и выбрать нужных сотрудников по фамилии или логину.



---

#### Пример 5: Узнать, какие программы используют интернет прямо сейчас

Одна из частых задач: "Какая программа тормозит интернет?" или "Кто и куда отправляет данные?". С помощью `Out-ConsoleGridView` можно получить наглядный и интерактивный ответ.

**Внутри таблицы:**
*   **Введите `chrome` или `msedge`** в поле фильтра, чтобы увидеть все активные подключения вашего браузера.
*   **Введите IP-адрес** (например, `151.101.1.69` из колонки `RemoteAddress`), чтобы увидеть, какие еще процессы подключены к этому же серверу.

```powershell
# Получаем все активные TCP-подключения
$connections = Get-NetTCPConnection -State Established | 
    Select-Object RemoteAddress, RemotePort, OwningProcess, @{Name="ProcessName"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

# Выводим в интерактивную таблицу для анализа
$connections | Out-ConsoleGridView -Title "Активные интернет-подключения"
```

1.  `Get-NetTCPConnection -State Established` собирает все установленные сетевые подключения.
2.  С помощью `Select-Object` мы формируем удобный отчет: добавляем имя процесса (`ProcessName`) к его ID (`OwningProcess`), чтобы было понятно, какая программа установила соединение.
3.  `Out-ConsoleGridView` показывает вам живую картину сетевой активности.

[Net](https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

#### Пример 6: Анализ системных событий: запуск и остановка служб

В Windows постоянно запускаются и останавливаются десятки фоновых служб. Это нормальная работа системы. 
Анализ этих событий может помочь понять, что именно происходит на вашем ПК, особенно если вы замечаете периодические "тормоза".

Мы будем искать **Событие с ID 7036** в журнале **"System"**. Это событие регистрируется каждый раз, когда какая-либо служба запускается или останавливается.

**Что такое Событие 7036?** Это событие генерирует "Диспетчер управления службами" (Service Control Manager). Он отвечает не только за обычные службы (которые вы видите в `services.msc`), но и за запуск и остановку **драйверов устройств**.


```powershell
# Ищем 500 последних событий запуска/остановки служб
$events = Get-WinEvent -FilterHashtable @{LogName='System'; Id=7036} -MaxEvents 500

# Выводим в интерактивную таблицу для анализа
$events | Select-Object TimeCreated, @{N='Service';E={$_.Properties[0].Value}}, @{N='State';E={$_.Properties[1].Value}} | 
    Out-ConsoleGridView -Title "Журнал запуска и остановки служб"
```

1.  `Get-WinEvent` быстро извлекает из системного журнала 500 последних событий с кодом `7036`. На любом работающем компьютере их будет предостаточно.
2.  `Select-Object` извлекает из каждого события полезную информацию:
    *   `TimeCreated`: Когда событие произошло.
    *   `Properties[0].Value`: Имя службы.
    *   `Properties[1].Value`: Новое состояние службы ("running" или "stopped").
3.  `Out-ConsoleGridView` отображает вам всю эту активность в удобном виде.



### Упс! 

Вы видите события, где Диспетчер управления службами отправил команду **драйверу вашего Wi-Fi адаптера** (`Intel(R) Dual Band Wireless-AC 3165`). 
У таких "драйверных" событий **другая структура данных**. В них есть только одно свойство (`Properties[0]`), которое содержит имя драйвера. 
Свойства для имени службы и ее состояния (`Properties[1]`) в них **просто отсутствуют**. Поэтому колонка `State` у вас пустая.

### Как это исправить

Чтобы получить только те события, которые нас интересуют (запуск и остановка обычных служб), нам нужно отфильтровать "шум", связанный с драйверами.

Самый надежный способ — это проверять, есть ли в событии нужное нам количество свойств. У "правильных" событий о службах их как минимум два (имя и состояние). У "драйверных" — обычно одно.

---

#### Пример 6 (Правильный) : Анализ запуска и остановки СЛУЖБ


Скрипт сначала находит все события с ID 7036, а затем отфильтровывает только те, которые имеют нужную нам структуру с двумя свойствами (имя службы и ее состояние).


```powershell
# Ищем 500 последних событий от Диспетчера управления службами
$rawEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Id=7036} -MaxEvents 500

# Фильтруем события, оставляя только те, где есть минимум 2 свойства (имя и состояние),
# и формируем красивую таблицу для анализа.
$serviceEvents = $rawEvents | Where-Object { $_.Properties.Count -ge 2 } | 
    Select-Object TimeCreated, @{N='Service';E={$_.Properties[0].Value}}, @{N='State';E={$_.Properties[1].Value}}

# Если события найдены, выводим их в интерактивную таблицу
if ($serviceEvents) {
    $serviceEvents | Out-ConsoleGridView -Title "Журнал запуска и остановки служб"
} else {
    Write-Warning "Не найдено событий о запуске/остановке служб среди последних 500 событий с ID 7036."
}
```

**Внутри таблицы:**
*   **Введите `Update`** в поле фильтра, чтобы увидеть, как часто служба "Центра обновления Windows" (Windows Update) запускалась и останавливалась.
*   **Введите имя службы вашего антивируса**, чтобы посмотреть на его активность.
*   Это отличный способ отследить, какая именно служба вызывает периодическую активность диска или процессора, сопоставив время событий с временем "тормозов".


#### Пример 7: Интерактивное удаление программ

```powershell
$programs = Get-Package | Sort-Object Name

$programsToUninstall = $programs | Out-ConsoleGridView -OutputMode Multiple

if ($programsToUninstall) {
    $programsToUninstall | Uninstall-Package -WhatIf
}
```

Вы получаете список всего установленного ПО. В интерфейсе вы можете легко найти и выбрать несколько программ для удаления.

#### Пример 8: Связывание (Chaining) `Out-ConsoleGridView`

Это самый мощный прием. Выход одной интерактивной сессии становится входом для другой. **Задача:** Выбрать пользователя AD, а затем выбрать, из какой группы его удалить.

```powershell
# --- ШАГ 1: Выбираем пользователя ---
$user = Get-ADUser -Filter * | Select-Object Name, SamAccountName | 
    Out-ConsoleGridView -Title "Выберите пользователя"

if ($user) {
    # --- ШАГ 2: Если пользователь выбран, получаем его группы и выбираем, какие удалить ---
    $groups = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName | 
        Out-ConsoleGridView -OutputMode Multiple -Title "Выберите группы, из которых нужно удалить $($user.Name)"

    if ($groups) {
        # --- ШАГ 3: Выполняем действие ---
        foreach ($group in $groups) {
            Remove-ADGroupMember -Identity $group.Name -Members $user.SamAccountName -WhatIf
        }
    }
}
```

1.  Первый `Out-ConsoleGridView` позволяет вам выбрать **одного** пользователя.
2.  Если пользователь выбран, скрипт получает список групп, в которых он состоит, и открывает **второй** `Out-ConsoleGridView` уже с этим списком.
3.  Вы выбираете одну или несколько групп, и скрипт удаляет из них пользователя. Это превращает сложную многошаговую задачу в интуитивно понятный интерактивный процесс.

#### Пример 9: Управление опциональными компонентами Windows

```powershell
# Получаем только включенные компоненты
$features = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }

$featuresToDisable = $features | Select-Object FeatureName, DisplayName | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Выберите компоненты для отключения"

if ($featuresToDisable) {
    foreach($feature in $featuresToDisable){
        Disable-WindowsOptionalFeature -Online -FeatureName $feature.FeatureName -WhatIf
    }
}
```

Вы можете легко найти и отключить ненужные компоненты, например `Telnet-Client` или `Windows-Sandbox`.

#### Пример 10: Управление виртуальными машинами Hyper-V

Быстро остановить несколько виртуальных машин для обслуживания хоста.

```powershell
# Получаем только запущенные ВМ
$vms = Get-VM | Where-Object { $_.State -eq 'Running' }

$vmsToStop = $vms | Select-Object Name, State, Uptime | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Выберите ВМ для остановки"

if ($vmsToStop) {
    $vmsToStop | Stop-VM -WhatIf
}
```

Вы получаете список только работающих машин и можете интерактивно выбрать те, которые нужно безопасно выключить.

---

### Заключение

Как показывают эти примеры, `Out-ConsoleGridView` — это не просто средство отображения. Это мощный инструмент, который добавляет **интерактивный слой** в ваши скрипты и однострочные команды. Он позволяет вам принимать решения "на лету", не прерывая рабочий процесс и продолжая оперировать **полноценными объектами PowerShell**, что является краеугольным камнем всей его философии.