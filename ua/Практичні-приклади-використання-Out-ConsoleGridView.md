### **Практичні приклади використання Out-ConsoleGridView**

У попередній главі ми познайомилися з `Out-ConsoleGridView` — потужним інструментом для інтерактивної роботи з даними прямо в терміналі. Якщо ви не знаєте, про що йдеться, рекомендую спочатку почитати
Ця стаття повністю присвячена йому. Я не буду повторювати теорію, а відразу перейду до практики і покажу 10 сценаріїв, в яких цей командлет може заощадити системному адміністратору або просунутому користувачеві масу часу.

`Out-ConsoleGridView` — це не просто "переглядач". Це **інтерактивний фільтр об'єктів** у середині вашого конвеєра.

**Попередні вимоги:**
*   PowerShell 7.2 або новішої версії.
*   Встановлений модуль `Microsoft.PowerShell.ConsoleGuiTools`. Якщо ви його ще не встановили:
    ```powershell
    Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
    ```


---

### 10 практичних прикладів

#### Приклад 1: Інтерактивна зупинка процесів

Класичне завдання: знайти та завершити кілька "завислих" або непотрібних процесів.

```powershell
# Вибираємо процеси в інтерактивному режимі
$procsToStop = Get-Process | Sort-Object -Property CPU -Descending | Out-ConsoleGridView -OutputMode Multiple

# Якщо щось було вибрано, передаємо об'єкти на зупинку
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```


[1](https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  `Get-Process` отримує всі запущені процеси.
2.  `Sort-Object` упорядковує їх за завантаженням CPU, щоб найбільш "ненажерливі" були вгорі.
3.  `Out-ConsoleGridView` відображає таблицю. Ви можете ввести `chrome` або `notepad`, щоб миттєво відфільтрувати список, і вибрати потрібні процеси клавішею `Space`.
4.  Після натискання `Enter` вибрані **об'єкти** процесів потрапляють у змінну `$procsToStop` і передаються в `Stop-Process`.

#### Приклад 2: Керування службами Windows

Потрібно швидко перезапустити кілька служб, пов'язаних з однією програмою (наприклад, SQL Server).

```powershell
$services = Get-Service | Out-ConsoleGridView -OutputMode Multiple -Title "Виберіть служби для перезапуску"

if ($services) {
    $services | Restart-Service -WhatIf
}
```


[1](https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  Ви отримуєте список усіх служб.
2.  Всередині `Out-ConsoleGridView` ви вводите у фільтр `sql` і відразу бачите всі служби, що стосуються SQL Server.
3.  Вибираєте потрібні та натискаєте `Enter`. Об'єкти вибраних служб передаються на перезапуск.

#### Приклад 3: Очищення папки "Завантаження" від великих файлів

З часом папка "Завантаження" забивається непотрібними файлами. Знайдемо та видалимо найбільші з них.

```powershell

# --- КРОК 1: Налаштування шляху до директорії 'Downloads'
$DownloadsPath = "E:\Users\user\Downloads" # <--- ЗМІНІТЬ ЦЕЙ РЯДОК НА ВАШ ШЛЯХ
===========================================================================

# Перевірка: якщо шлях не вказано або папка не існує - виходимо.
if ([string]::IsNullOrEmpty($DownloadsPath) -or (-not (Test-Path -Path $DownloadsPath))) {
    Write-Error "Папка 'Завантаження' не знайдена за вказаним шляхом: '$DownloadsPath'. Будь ласка, перевірте шлях у блоці НАЛАШТУВАННЯ в початку скрипта."
    return
}

# --- КРОК 2: Інформування користувача та збір даних ---
Write-Host "Починаю сканування папки '$DownloadsPath'. Це може зайняти деякий час..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $DownloadsPath -File -Recurse -ErrorAction SilentlyContinue | 
    Sort-Object -Property Length -Descending

# --- КРОК 3: Перевірка наявності файлів та виклик інтерактивного вікна ---
if ($files) {
    Write-Host "Сканування завершено. Знайдено $($files.Count) файлів. Відкриття вікна вибору..." -ForegroundColor Green
    
    $filesToShow = $files | Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime
    
    $filesToDelete = $filesToShow | Out-ConsoleGridView -OutputMode Multiple -Title "Виберіть файли для видалення з '$DownloadsPath'"

    # --- КРОК 4: Обробка вибору користувача ---
    if ($filesToDelete) {
        Write-Host "Наступні файли будуть видалені:" -ForegroundColor Yellow
        $filesToDelete | Format-Table -AutoSize
        
        $filesToDelete.FullName | Remove-Item -WhatIf -Verbose
    } else {
        Write-Host "Операція скасована. Не вибрано жодного файлу." -ForegroundColor Yellow
    }
} else {
    Write-Host "У папці '$DownloadsPath' не знайдено файлів." -ForegroundColor Yellow
}
```
[Clear-DownloadsFolder.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/scripts/Clear-DownloadsFolder.ps1)

[Вміст Downloads](https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a" type="video/mp4">
  Your browser does not support the video tag.
</video>


1.  Ми отримуємо всі файли, сортуємо їх за розміром і за допомогою `Select-Object` створюємо зручну колонку `SizeMB`.
2.  У `Out-ConsoleGridView` ви бачите відсортований список, де легко вибрати старі та великі `.iso` або `.zip` файли.
3.  Після вибору їх повні шляхи передаються в `Remove-Item`.

#### Приклад 4: Додавання користувачів до групи Active Directory

Незамінна річ для адміністраторів AD.

```powershell
# Отримуємо користувачів з відділу Marketing
$users = Get-ADUser -Filter 'Department -eq "Marketing"' -Properties DisplayName

# Інтерактивно вибираємо, кого додати
$usersToAdd = $users | Select-Object Name, DisplayName | Out-ConsoleGridView -OutputMode Multiple

if ($usersToAdd) {
    Add-ADGroupMember -Identity "Marketing-Global-Group" -Members $usersToAdd -WhatIf
}
```

Замість того, щоб вручну вводити імена користувачів, ви отримуєте зручний список, де можете швидко знайти та вибрати потрібних співробітників за прізвищем або логіном.



---

#### Приклад 5: Дізнатися, які програми використовують інтернет прямо зараз

Одне з частих завдань: "Яка програма гальмує інтернет?" або "Хто і куди відправляє дані?". За допомогою `Out-ConsoleGridView` можна отримати наочну та інтерактивну відповідь.

**Всередині таблиці:**
*   **Введіть `chrome` або `msedge`** у поле фільтра, щоб побачити всі активні підключення вашого браузера.
*   **Введіть IP-адресу** (наприклад, `151.101.1.69` з колонки `RemoteAddress`), щоб побачити, які ще процеси підключені до цього ж сервера.

```powershell
# Отримуємо всі активні TCP-підключення
$connections = Get-NetTCPConnection -State Established | 
    Select-Object RemoteAddress, RemotePort, OwningProcess, @{Name="ProcessName"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

# Виводимо в інтерактивну таблицю для аналізу
$connections | Out-ConsoleGridView -Title "Активні інтернет-підключення"
```

1.  `Get-NetTCPConnection -State Established` збирає всі встановлені мережеві підключення.
2.  За допомогою `Select-Object` ми формуємо зручний звіт: додаємо ім'я процесу (`ProcessName`) до його ID (`OwningProcess`), щоб було зрозуміло, яка програма встановила з'єднання.
3.  `Out-ConsoleGridView` показує вам живу картину мережевої активності.

[Net](https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec" type="video/mp4">
  Your browser does not support the video tag.
</video>

---



### Приклад 6: Аналіз встановлення ПЗ та оновлень

Ми будемо шукати події від джерела **"MsiInstaller"**. Він відповідає за встановлення, оновлення та видалення більшості програм (у форматі `.msi`), а також за багато компонентів оновлень Windows.

```powershell
# Шукаємо 100 останніх подій від інсталятора Windows (MsiInstaller)
# Ці події є на будь-якій системі
$installEvents = Get-WinEvent -ProviderName 'MsiInstaller' -MaxEvents 100

# Якщо події знайдено, виводимо їх у зручному вигляді
if ($installEvents) {
    $installEvents | 
        # Вибираємо тільки найкорисніше: час, повідомлення та ID події
        # ID 11707 - успішне встановлення, ID 11708 - невдале встановлення
        Select-Object TimeCreated, Id, Message |
        Out-ConsoleGridView -Title "Журнал встановлення програм (MsiInstaller)"
} else {
    Write-Warning "Не знайдено подій від 'MsiInstaller'. Це дуже незвично."
}
```

**Всередині таблиці:**
*   Ви можете відфільтрувати список за назвою програми (наприклад, `Edge` або `Office`), щоб побачити всю історію її оновлень.
*   Ви можете відсортувати за `Id`, щоб знайти невдалі встановлення (`11708`).


---



#### Приклад 7: Інтерактивне видалення програм

```powershell
# Шляхи в реєстрі, де зберігається інформація про встановлені програми
$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Збираємо дані з реєстру, прибираючи системні компоненти, у яких немає імені
$installedPrograms = Get-ItemProperty $registryPaths | 
    Where-Object { $_.DisplayName -and $_.UninstallString } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

# Якщо програми знайдено, виводимо в інтерактивну таблицю
if ($installedPrograms) {
    $programsToUninstall = $installedPrograms | Out-ConsoleGridView -OutputMode Multiple -Title "Виберіть програми для видалення"
    
    if ($programsToUninstall) {
        Write-Host "Наступні програми будуть видалені:" -ForegroundColor Yellow
        $programsToUninstall | Format-Table -AutoSize
        
        # Цей блок складніший, оскільки Uninstall-Package тут не спрацює.
        # Ми запускаємо команду деінсталяції з реєстру.
        foreach ($program in $programsToUninstall) {
            # Знаходимо оригінальний об'єкт програми зі строкою деінсталяції
            $fullProgramInfo = Get-ItemProperty $registryPaths | Where-Object { $_.DisplayName -eq $program.DisplayName }
            
            if ($fullProgramInfo.UninstallString) {
                Write-Host "Запуск деінсталятора для '$($program.DisplayName)'..." -ForegroundColor Yellow
                # УВАГА: Це запустить стандартний GUI-деінсталятор програми.
                # WhatIf тут не спрацює, будьте обережні.
                # cmd.exe /c $fullProgramInfo.UninstallString
            }
        }
        Write-Warning "Щоб реально видалити програми, розкоментуйте рядок 'cmd.exe /c ...' у скрипті."
    }
} else {
    Write-Warning "Не вдалося знайти встановлені програми в реєстрі."
}
```

---


Ви абсолютно праві. Приклад з Active Directory не підходить для звичайного користувача і вимагає спеціального середовища.

Давайте замінимо його на набагато універсальніший і зрозуміліший сценарій, який ідеально демонструє міць зв'язування `Out-ConsoleGridView` і буде корисний будь-якому користувачеві.

---

#### Приклад 8: Зв'язування (Chaining) `Out-ConsoleGridView`

Це найпотужніший прийом. Вихід однієї інтерактивної сесії стає входом для іншої. **Завдання:** Вибрати одну з ваших папок з проєктами, а потім вибрати з неї певні файли для створення ZIP-архіву.

```powershell
# --- КРОК 1: Універсально знаходимо папку "Документи" ---
$SearchPath = [System.Environment]::GetFolderPath('MyDocuments')

# --- КРОК 2: Інтерактивно вибираємо одну папку з вказаного місця ---
$selectedFolder = Get-ChildItem -Path $SearchPath -Directory | 
    Out-ConsoleGridView -Title "Виберіть папку для архівації"

if ($selectedFolder) {
    # --- КРОК 3: Якщо папку вибрано, отримуємо її файли та вибираємо, які з них архівувати ---
    $filesToArchive = Get-ChildItem -Path $selectedFolder.FullName -File | 
        Out-ConsoleGridView -OutputMode Multiple -Title "Виберіть файли для архіву з '$($selectedFolder.Name)'"

    if ($filesToArchive) {
        # --- КРОК 4: Виконуємо дію з універсальними шляхами ---
        $archiveName = "Archive-$($selectedFolder.Name)-$(Get-Date -Format 'yyyy-MM-dd').zip"
        
        # УНІВЕРСАЛЬНИЙ СПОСІБ ОТРИМАТИ ШЛЯХ ДО РОБОЧОГО СТОЛУ
        $desktopPath = [System.Environment]::GetFolderPath('Desktop')
        $destinationPath = Join-Path -Path $desktopPath -ChildPath $archiveName
        
        # Створюємо архів
        Compress-Archive -Path $filesToArchive.FullName -DestinationPath $destinationPath -WhatIf
        
        Write-Host "Архів '$archiveName' буде створено на вашому робочому столі за шляхом '$destinationPath'." -ForegroundColor Green
    }
}
```


1.  Перший `Out-ConsoleGridView` показує вам список папок всередині ваших "Документів". Ви можете швидко знайти потрібну, ввівши частину її імені, і вибрати **одну** папку.
2.  Якщо папку було вибрано, скрипт негайно відкриває **другий** `Out-ConsoleGridView`, який показує вже **файли всередині** цієї папки.
3.  Ви вибираєте **один або кілька** файлів клавішею `Space` і натискаєте `Enter`.
4.  Скрипт бере вибрані файли та створює з них ZIP-архів на вашому робочому столі.

Це перетворює складне багатоетапне завдання (знайти папку, знайти в ній файли, скопіювати їх шляхи, запустити команду архівації) в інтуїтивно зрозумілий інтерактивний процес з двох кроків.


#### Приклад 9: Керування опціональними компонентами Windows

```powershell
# --- Приклад 9 : Керування опціональними компонентами Windows ---

# Отримуємо тільки включені компоненти
$features = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }

$featuresToDisable = $features | Select-Object FeatureName, DisplayName | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Виберіть компоненти для відключення"

if ($featuresToDisable) {
    # ПОПЕРЕДЖАЄМО КОРИСТУВАЧА ПРО НЕЗВОРОТНІСТЬ
    Write-Host "УВАГА! Наступні компоненти будуть негайно відключені." -ForegroundColor Red
    Write-Host "Ця операція не підтримує безпечний режим -WhatIf."
    $featuresToDisable | Select-Object DisplayName

    # Запитуємо підтвердження вручну
    $confirmation = Read-Host "Продовжити? (y/n)"
    
    if ($confirmation -eq 'y') {
        foreach($feature in $featuresToDisable){
            Write-Host "Відключення компонента '$($feature.DisplayName)'..." -ForegroundColor Yellow
            Disable-WindowsOptionalFeature -Online -FeatureName $feature.FeatureName
        }
        Write-Host "Операція завершена. Може знадобитися перезавантаження." -ForegroundColor Green
    } else {
        Write-Host "Операція скасована."
    }
}
```

Ви можете легко знайти та відключити непотрібні компоненти, наприклад `Telnet-Client` або `Windows-Sandbox`.

#### Приклад 10: Керування віртуальними машинами Hyper-V

Швидко зупинити кілька віртуальних машин для обслуговування хоста.

```powershell
# Отримуємо тільки запущені ВМ
$vms = Get-VM | Where-Object { $_.State -eq 'Running' }

$vmsToStop = $vms | Select-Object Name, State, Uptime | 
    Out-ConsoleGridView -OutputMode Multiple -Title "Виберіть ВМ для зупинки"

if ($vmsToStop) {
    $vmsToStop | Stop-VM -WhatIf
}
```

Ви отримуєте список тільки працюючих машин і можете інтерактивно вибрати ті, які потрібно безпечно вимкнути.
