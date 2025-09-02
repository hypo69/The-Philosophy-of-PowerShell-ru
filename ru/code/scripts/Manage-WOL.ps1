# =================================================================================
# ИНТЕРАКТИВНЫЙ ИНСТРУМЕНТ ДЛЯ УПРАВЛЕНИЯ WAKE-ON-LAN (WOL)
# Windows PowerShell >= 5.1.
# Запускать от имени администратора!
# Версия: 2.0 (Интерактивная)
# Автор: hypo69
# Дата создания: 12/06/2025 
# =================================================================================
# =================================================================================
# ЛИЦЕНЗИЯ (MIT) - без изменений
# =================================================================================
<#
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
<#
.SYNOPSIS
    Позволяет пользователю в интерактивном режиме выбрать сетевой адаптер
    и включить или отключить для него все параметры Wake-on-LAN.

.DESCRIPTION
    Этот инструмент сначала сканирует систему на наличие активных сетевых адаптеров,
    представляет их в виде списка, а затем, на основе выбора пользователя и параметра
    -Action, выполняет полную настройку WOL.

.PARAMETER Action
    Указывает, что делать: 'Enable' для включения WOL или 'Disable' для отключения.

.EXAMPLE
    # Запустить скрипт для включения WOL. Он покажет список устройств для выбора.
    .\Manage-WOL-Interactive.ps1 -Action Enable

.EXAMPLE
    # Запустить скрипт для отключения WOL.
    .\Manage-WOL-Interactive.ps1 -Action Disable

.NOTES
    Требуются права администратора. Скрипт использует современные CIM-командлеты
    и пытается применить настройки для разных типов драйверов (Intel, Realtek и др.).
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Выберите действие: 'Enable' для включения или 'Disable' для отключения WOL.")]
    [ValidateSet('Enable', 'Disable')]
    [string]$Action
)

#-------------------------------------------------------------------
# БЛОК 1: ИНТЕРАКТИВНЫЙ ВЫБОР УСТРОЙСТВА
#-------------------------------------------------------------------
Write-Host "--- 1. Поиск активных сетевых устройств в системе..." -ForegroundColor Yellow

# Ищем все устройства класса "Сеть" со статусом "OK"
$devices = Get-PnpDevice -Class 'Net' | Where-Object { $_.Status -eq 'OK' }

if ($null -eq $devices) {
    Write-Error "В системе не найдено ни одного активного сетевого устройства."
    exit 1
}

Write-Host "Найдены следующие устройства. Выберите одно для настройки:" -ForegroundColor Cyan
for ($i = 0; $i -lt $devices.Count; $i++) {
    Write-Host "  [$($i+1)] $($devices[$i].FriendlyName)"
}

$selectedDevice = $null
do {
    try {
        $choice = Read-Host "`nВведите номер устройства (от 1 до $($devices.Count))"
        if ($choice -match "^\d+$" -and $choice -ge 1 -and $choice -le $devices.Count) {
            $selectedDevice = $devices[$choice - 1]
        } else {
            Write-Warning "Неверный ввод. Пожалуйста, введите только число из списка."
        }
    }
    catch {
        Write-Warning "Произошла ошибка при вводе. Попробуйте еще раз."
    }
} while ($null -eq $selectedDevice)

# Теперь у нас есть выбранное пользователем устройство
$exactDeviceName = $selectedDevice.FriendlyName
$instanceId = $selectedDevice.InstanceId
Write-Host "Выбрано устройство: '$exactDeviceName'" -ForegroundColor Green

#-------------------------------------------------------------------
# БЛОК 2: ПРИМЕНЕНИЕ НАСТРОЕК К ВЫБРАННОМУ УСТРОЙСТВУ
#-------------------------------------------------------------------
try {
    $pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$instanceId\Device Parameters"

    if ($Action -eq 'Enable') {
        Write-Host "--- 2. Включение Wake-on-LAN..." -ForegroundColor Cyan
        
        powercfg -deviceenablewake "$exactDeviceName"
        Write-Host "   [OK] powercfg -deviceenablewake"
        
        Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $pmKey -Name "WakeOnMagicPacket" -Value 1 -Force -ErrorAction SilentlyContinue
        Write-Host "   [OK] Реестр: WakeOnMagicPacket = 1 (применены оба варианта)"
        
        $adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }
        if ($adapterCim) {
            Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
            Write-Host "   [OK] WMI/CIM Power Management включено"
        }

        Write-Host "✔ Wake-on-LAN УСПЕШНО ВКЛЮЧЕН для '$exactDeviceName'." -ForegroundColor Green
    }
    else { # ($Action -eq 'Disable')
        Write-Host "--- 2. Отключение Wake-on-LAN..." -ForegroundColor Cyan
        
        powercfg -devicedisablewake "$exactDeviceName"
        Write-Host "   [OK] powercfg -devicedisablewake"

        Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $pmKey -Name "WakeOnMagicPacket" -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Host "   [OK] Реестр: WakeOnMagicPacket = 0 (применены оба варианта)"

        Write-Host "✔ Wake-on-LAN УСПЕШНО ОТКЛЮЧЕН для '$exactDeviceName'." -ForegroundColor Green
    }
}
catch {
    Write-Error "Произошла критическая ошибка при применении настроек: $($_.Exception.Message)"
    exit 1
}

Write-Host "`nСкрипт завершил работу."