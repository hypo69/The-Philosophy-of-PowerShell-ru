#requires -Version 7.2
#requires -RunAsAdministrator

# =================================================================================
# Start-InteractiveSystemMonitor.ps1 — Интерактивный монитор системы с GUI-меню
# PowerShell >= 7.2
# Запускать от имени администратора!
# Автор: hypo69
# Дата создания: 07/08/2025
# =================================================================================

<#
.SYNOPSIS
    Собирает и отображает информацию о CPU, RAM, дисках, системе, сети, пользователях и периферии.
.DESCRIPTION
    В интерактивном режиме (без параметров) скрипт запускает циклический графический интерфейс в консоли,
    позволяя пользователю выбирать действия из меню.
    В режиме прямого вызова (с параметром -Resource) скрипт выполняет анализ одного конкретного компонента и завершается.
.PARAMETER Resource
    Позволяет выполнить анализ для конкретного компонента и выйти.
    Допустимые значения: 'cpu', 'memory', 'system', 'storage', 'network', 'users', 'peripherals'.
.EXAMPLE
    .\Start-InteractiveSystemMonitor.ps1
    # Запустит утилиту в циклическом интерактивном режиме с GUI-меню.

.EXAMPLE
    .\Start-InteractiveSystemMonitor.ps1 -Resource users
    # Покажет детальную информацию о локальных пользователях в окне GridView и завершит работу.

.LICENSE
    MIT License
    Copyright (c) 2025 hypo69

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>
param(
    [Parameter(Mandatory = $false, HelpMessage = "Запуск анализа для конкретного компонента (cpu, memory, system, storage, network, users, peripherals).")]
    [ValidateSet('cpu', 'memory', 'system', 'storage', 'network', 'users', 'peripherals')]
    [string]$Resource
)

# --- Функция для показа деталей (чтобы не дублировать код) ---
function Show-ResourceDetails {
    param(
        [ValidateSet('cpu', 'memory', 'system', 'storage', 'network', 'users', 'peripherals')]
        [string]$ResourceType
    )
    
    try {
        switch ($ResourceType) {
            'cpu'       { (Get-CimInstance -ClassName Win32_Processor).psobject.Properties | Select-Object Name, Value | Out-ConsoleGridView -Title "Детальная информация: Процессор (CPU)" }
            'memory'    { Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object BankLabel, Capacity, Manufacturer, Speed | Out-ConsoleGridView -Title "Детальная информация: Оперативная память (RAM)" }
            'system'    { (Get-CimInstance -ClassName Win32_OperatingSystem).psobject.Properties | Select-Object Name, Value | Out-ConsoleGridView -Title "Детальная информация: Операционная система" }
            'storage'   { Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, VolumeName, FileSystem, @{N='Size (GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace (GB)';E={[math]::Round($_.FreeSpace / 1GB, 2)}} | Out-ConsoleGridView -Title "Детальная информация: Локальные диски" }
            'network'   { Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress, @{N='IPv4 Address';E={($_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress}} | Out-ConsoleGridView -Title "Детальная информация: Сетевые адаптеры" }
            'users'     { Get-LocalUser | Select-Object Name, FullName, Enabled, PasswordLastSet, Description | Out-ConsoleGridView -Title "Детальная информация: Локальные пользователи" }
            'peripherals' {
                $peripheralMenu = @(
                    [PSCustomObject]@{ Name = "Подключенные USB-устройства"; Command = { Get-PnpDevice -Class 'USB' -Status 'OK' | Select-Object FriendlyName, Manufacturer, Status } }
                    [PSCustomObject]@{ Name = "Принтеры"; Command = { Get-Printer | Select-Object Name, DriverName, PortName, Status } }
                    [PSCustomObject]@{ Name = "Звуковые устройства"; Command = { Get-CimInstance -ClassName Win32_SoundDevice | Select-Object Name, Manufacturer, StatusInfo } }
                )
                $choice = $peripheralMenu | Out-ConsoleGridView -Title "Выберите тип периферийных устройств"
                if ($choice) { & $choice.Command | Out-ConsoleGridView -Title $choice.Name }
            }
        }
    } catch { Write-Error "Произошла критическая ошибка: $($_.Exception.Message)" }
}


# --- Выбор режима работы: Прямой вызов или Интерактивный цикл ---

if ($PSBoundParameters.ContainsKey('Resource')) {
    # --- РЕЖИМ ПРЯМОГО ВЫЗОВА ---
    Write-Host "Выполняется анализ компонента: $Resource..." -ForegroundColor Cyan
    Show-ResourceDetails -ResourceType $Resource

} else {
    # --- ИНТЕРАКТИВНЫЙ ЦИКЛИЧЕСКИЙ РЕЖИМ ---
    
    $mainMenuOptions = @(
        [PSCustomObject]@{ Description = 'Показать общую сводку по системе'; ActionKey = 'summary' }
        [PSCustomObject]@{ Description = 'Детально: Процессор (CPU)'; ActionKey = 'cpu' }
        [PSCustomObject]@{ Description = 'Детально: Оперативная память (RAM)'; ActionKey = 'memory' }
        [PSCustomObject]@{ Description = 'Детально: Локальные диски (Storage)'; ActionKey = 'storage' }
        [PSCustomObject]@{ Description = 'Детально: Сетевые адаптеры (Network)'; ActionKey = 'network' }
        [PSCustomObject]@{ Description = 'Детально: Локальные пользователи (Users)'; ActionKey = 'users' }
        [PSCustomObject]@{ Description = 'Детально: Периферийные устройства'; ActionKey = 'peripherals' }
        [PSCustomObject]@{ Description = 'Детально: Операционная система'; ActionKey = 'system' }
        [PSCustomObject]@{ Description = 'Выход из программы'; ActionKey = 'exit' }
    )

    Clear-Host
    Write-Host "Добро пожаловать в Интерактивный монитор системы!" -ForegroundColor Cyan
    
    while ($true) {
        Write-Host "`nВы в главном меню. Сделайте выбор в появившемся окне." -ForegroundColor Cyan
        
        
        $choice = $mainMenuOptions | Out-ConsoleGridView -Title "Главное меню: Выберите действие" -OutputMode Single

        if ($null -eq $choice) { continue }

        switch ($choice.ActionKey) {
            'exit' { break }
            'summary' {
                Write-Host "`nСобираю информацию о состоянии системы..." -ForegroundColor Gray
                $systemStatus = [System.Collections.Generic.List[object]]::new()
                
                # ... (Сбор данных) ...
                $cpuInfo = Get-CimInstance -ClassName Win32_Processor; $cpuLoad = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor | Where-Object Name -eq '_Total'; $systemStatus.Add([PSCustomObject]@{ Компонент = "Процессор (CPU)"; Имя = $cpuInfo.Name.Trim(); Состояние = "$($cpuLoad.PercentProcessorTime) %"; DetailsObject = 'cpu' })
                $memInfo = Get-CimInstance -ClassName Win32_OperatingSystem; $totalMemGB = [math]::Round($memInfo.TotalVisibleMemorySize / 1MB, 1); $freeMemGB = [math]::Round($memInfo.FreePhysicalMemory / 1MB, 1); $usedMemGB = $totalMemGB - $freeMemGB; $percentUsed = [math]::Round(($usedMemGB / $totalMemGB) * 100, 0); $systemStatus.Add([PSCustomObject]@{ Компонент = "Память (RAM)"; Имя = "Оперативная память"; Состояние = "$percentUsed % ($($usedMemGB) GB / $($totalMemGB) GB)"; DetailsObject = 'memory' })
                $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"; foreach ($disk in $diskInfo) { $diskTotalGB = [math]::Round($disk.Size / 1GB, 1); $diskFreeGB = [math]::Round($disk.FreeSpace / 1GB, 1); if ($disk.Size -gt 0) { $diskUsedPercent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 0) } else { $diskUsedPercent = 0 }; $systemStatus.Add([PSCustomObject]@{ Компонент = "Диск"; Имя = "$($disk.VolumeName) ($($disk.DeviceID))"; Состояние = "$diskUsedPercent % ($($diskFreeGB) GB свободно)"; DetailsObject = $disk }) }
                $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }; foreach ($adapter in $activeAdapters) { $ipAddress = ($adapter | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress; if ([string]::IsNullOrEmpty($ipAddress)) { $ipAddress = "Нет IPv4 адреса" }; $systemStatus.Add([PSCustomObject]@{ Компонент = "Сеть (Network)"; Имя = $adapter.Name; Состояние = $ipAddress; DetailsObject = $adapter }) }
                $activeUsers = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName; if ($activeUsers) { $systemStatus.Add([PSCustomObject]@{ Компонент = "Пользователи"; Имя = "Активные сессии"; Состояние = $activeUsers; DetailsObject = 'users' }) }
                $usbCount = (Get-PnpDevice -Class 'USB' -Status 'OK' -ErrorAction SilentlyContinue).Count; $systemStatus.Add([PSCustomObject]@{ Компонент = "Периферия"; Имя = "Подключенные USB"; Состояние = "$usbCount устройств(а)"; DetailsObject = 'peripherals' })

                $selectedResource = $systemStatus | Out-ConsoleGridView -Title "ЭТАП 1: Сводка состояния системы"
                
                if ($null -ne $selectedResource) {
                    if ($selectedResource.DetailsObject.psobject) {
                        $selectedResource.DetailsObject.psobject.Properties | Select-Object Name, Value | Out-ConsoleGridView -Title "ЭТАП 2: Детали"
                    } else {
                        Show-ResourceDetails -ResourceType $selectedResource.DetailsObject
                    }
                }
            }
            default {
                Show-ResourceDetails -ResourceType $choice.ActionKey
            }
        }
    }

    Write-Host "`nСкрипт завершил работу. До свидания!" -ForegroundColor Green
}