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
$path = "$env:USERPROFILE\Downloads"
$filesToDelete = Get-ChildItem -Path $path -File -Recurse | 
    Sort-Object -Property Length -Descending |
    Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime |
    Out-ConsoleGridView -OutputMode Multiple

if ($filesToDelete) {
    $filesToDelete.FullName | Remove-Item -WhatIf
}
```

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

#### Пример 5: Анализ сетевых подключений

Кто сейчас подключен к вашему файловому серверу?

```powershell
$connections = Get-NetTCPConnection -State Established -RemotePort 445 | 
    Select-Object RemoteAddress, OwningProcess, @{Name="ProcessName";E={(Get-Process -Id $_.OwningProcess).ProcessName}}

$connections | Out-ConsoleGridView
```

Эта команда покажет вам интерактивный список всех активных SMB-подключений (порт 445). В поле фильтра можно ввести IP-адрес, чтобы увидеть подключения с конкретного компьютера.

#### Пример 6: Анализ журналов событий Windows

Просматривать журналы безопасности — рутина. `Out-ConsoleGridView` может ее упростить.

```powershell
# Ищем 100 последних событий неудачного входа в систему (ID 4625)
$events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 100

# Выводим в интерактивную таблицу для анализа
$events | Select-Object TimeCreated, Id, @{N='User';E={$_.Properties[5].Value}}, @{N='Source IP';E={$_.Properties[19].Value}} | 
    Out-ConsoleGridView
```

Вы получаете чистый список событий. В `Out-ConsoleGridView` вы можете быстро отфильтровать его по имени пользователя или IP-адресу, чтобы найти источник подозрительной активности.

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