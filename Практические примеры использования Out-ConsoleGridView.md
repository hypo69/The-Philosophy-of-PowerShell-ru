### **Практические примеры использования Out-ConsoleGridView**

В предыдущей главе мы познакомились с `Out-ConsoleGridView` — мощным инструментом для интерактивной работы с данными прямо в терминале. Если вы не знаете о чем речь, рекомендую сначала почитать   
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



### Пример 6: Анализ установки ПО и обновлений

Мы будем искать события от источника **"MsiInstaller"**. Он отвечает за установку, обновление и удаление большинства программ (в формате `.msi`), а также за многие компоненты обновлений Windows.

```powershell
# Ищем 100 последних событий от установщика Windows (MsiInstaller)
# Эти события есть на любой системе
$installEvents = Get-WinEvent -ProviderName 'MsiInstaller' -MaxEvents 100

# Если события найдены, выводим их в удобном виде
if ($installEvents) {
    $installEvents | 
        # Выбираем только самое полезное: время, сообщение и ID события
        # ID 11707 - успешная установка, ID 11708 - неудачная установка
        Select-Object TimeCreated, Id, Message |
        Out-ConsoleGridView -Title "Журнал установки программ (MsiInstaller)"
} else {
    Write-Warning "Не найдено событий от 'MsiInstaller'. Это очень необычно."
}
```

**Внутри таблицы:**
*   Вы можете отфильтровать список по названию программы (например, `Edge` или `Office`), чтобы увидеть всю историю ее обновлений.
*   Вы можете отсортировать по `Id`, чтобы найти неудачные установки (`11708`).


---



#### Пример 7: Интерактивное удаление программ

```powershell
# Пути в реестре, где хранится информация об установленных программах
$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Собираем данные из реестра, убирая системные компоненты, у которых нет имени
$installedPrograms = Get-ItemProperty $registryPaths | 
    Where-Object { $_.DisplayName -and $_.UninstallString } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

# Если программы найдены, выводим в интерактивную таблицу
if ($installedPrograms) {
    $programsToUninstall = $installedPrograms | Out-ConsoleGridView -OutputMode Multiple -Title "Выберите программы для удаления"
    
    if ($programsToUninstall) {
        Write-Host "Следующие программы будут удалены:" -ForegroundColor Yellow
        $programsToUninstall | Format-Table -AutoSize
        
        # Этот блок сложнее, так как Uninstall-Package здесь не сработает.
        # Мы запускаем команду деинсталляции из реестра.
        foreach ($program in $programsToUninstall) {
            # Находим оригинальный объект программы со строкой деинсталляции
            $fullProgramInfo = Get-ItemProperty $registryPaths | Where-Object { $_.DisplayName -eq $program.DisplayName }
            
            if ($fullProgramInfo.UninstallString) {
                Write-Host "Запуск деинсталлятора для '$($program.DisplayName)'..."
                # ВНИМАНИЕ: Это запустит стандартный GUI-деинсталлятор программы.
                # WhatIf здесь не сработает, будьте осторожны.
                # cmd.exe /c $fullProgramInfo.UninstallString
            }
        }
        Write-Warning "Чтобы реально удалить программы, раскомментируйте строку 'cmd.exe /c ...' в скрипте."
    }
} else {
    Write-Warning "Не удалось найти установленные программы в реестре."
}
```

---


Вы абсолютно правы. Пример с Active Directory не подходит для обычного пользователя и требует специальной среды.

Давайте заменим его на гораздо более универсальный и понятный сценарий, который идеально демонстрирует мощь связывания `Out-ConsoleGridView` и будет полезен любому пользователю.

---

#### Пример 8: Связывание (Chaining) `Out-ConsoleGridView`

Это самый мощный прием. Выход одной интерактивной сессии становится входом для другой. **Задача:** Выбрать одну из ваших папок с проектами, а затем выбрать из нее определенные файлы для создания ZIP-архива.

```powershell
# --- ШАГ 1: Укажите папку, где лежат ваши проекты или документы ---
$SearchPath = "$env:USERPROFILE\Documents"

# --- ШАГ 2: Интерактивно выбираем одну папку из указанного места ---
$selectedFolder = Get-ChildItem -Path $SearchPath -Directory | 
    Out-ConsoleGridView -Title "Выберите папку для архивации"

if ($selectedFolder) {
    # --- ШАГ 3: Если папка выбрана, получаем ее файлы и выбираем, какие из них архивировать ---
    $filesToArchive = Get-ChildItem -Path $selectedFolder.FullName -File | 
        Out-ConsoleGridView -OutputMode Multiple -Title "Выберите файлы для архива из '$($selectedFolder.Name)'"

    if ($filesToArchive) {
        # --- ШАГ 4: Выполняем действие ---
        $archiveName = "Archive-$($selectedFolder.Name)-$(Get-Date -Format 'yyyy-MM-dd').zip"
        $destinationPath = Join-Path -Path $env:USERPROFILE -ChildPath "Desktop\$archiveName"
        
        Compress-Archive -Path $filesToArchive.FullName -DestinationPath $destinationPath -WhatIf
        
        Write-Host "Архив '$archiveName' будет создан на вашем рабочем столе." -ForegroundColor Green
    }
}
```


1.  Первый `Out-ConsoleGridView` показывает вам список папок внутри ваших "Документов". Вы можете быстро найти нужную, введя часть ее имени, и выбрать **одну** папку.
2.  Если папка была выбрана, скрипт немедленно открывает **второй** `Out-ConsoleGridView`, который показывает уже **файлы внутри** этой папки.
3.  Вы выбираете **один или несколько** файлов клавишей `Space` и нажимаете `Enter`.
4.  Скрипт берет выбранные файлы и создает из них ZIP-архив на вашем рабочем столе.

Это превращает сложную многошаговую задачу (найти папку, найти в ней файлы, скопировать их пути, запустить команду архивации) в интуитивно понятный интерактивный процесс из двух шагов.


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