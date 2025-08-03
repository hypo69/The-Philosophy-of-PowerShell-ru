# =================================================================================
# СКРИПТ ДЛЯ УПРАВЛЕНИЯ ЭНЕРГОСБЕРЕЖЕНИЕМ УСТРОЙСТВ
# Windows PowerShell >= 5.1.
# Запускать от имени администратора!
# Автор: hypo69
# Дата создания: 12/06/2025 
# =================================================================================

# =================================================================================
# ЛИЦЕНЗИЯ (MIT)
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
    Предоставляет набор функций для поиска и включения параметров управления питанием ("Разрешить отключение этого устройства...") для устройств в Windows.

.DESCRIPTION
    Этот скрипт содержит три основные функции для работы с параметрами энергосбережения устройств:

    1. Get-PowerManagementCapableDevices:
       Находит и выводит список всех устройств в системе, которые поддерживают управление питанием через WMI,
       показывая их текущий статус.

    2. Enable-PnpDevicePowerManagement:
       Основная функция для включения управления питанием. Использует WMI-класс MSPower_DeviceEnable.
       Это предпочтительный программный метод.

    3. Enable-DevicePowerManagement-Registry:
       Альтернативный, более "силовой" метод, который напрямую изменяет параметры в реестре.
       Может быть полезен, если метод WMI не срабатывает. Требует перезагрузки.

.NOTES
    Все функции, изменяющие настройки системы, требуют запуска PowerShell от имени администратора.
#>

function Enable-PnpDevicePowerManagement {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DeviceInstanceId
    )
    
    try {
        # Поиск устройства по DeviceID для проверки его существования
        $device = Get-WmiObject -Class Win32_PnPEntity -Filter "DeviceID='$DeviceInstanceId'"
        
        if (-not $device) {
            Write-Error "Устройство с ID '$DeviceInstanceId' не найдено."
            return $false
        }
        
        Write-Host "Найдено устройство: $($device.Name)" -ForegroundColor Green
        
        # Получение настроек управления питанием для устройства через специальный WMI-класс
        # Пространство имен Root\WMI неявно используется для этого класса.
        # Необходимо экранировать обратные слэши в DeviceInstanceId для WMI-фильтра.
        $powerMgmt = Get-WmiObject -Class MSPower_DeviceEnable -Filter "InstanceName='$($DeviceInstanceId.Replace('\', '\\'))'"
        
        if (-not $powerMgmt) {
            Write-Warning "Устройство не поддерживает управление питанием или настройки не найдены."
            return $false
        }
        
        # Проверка текущего состояния
        Write-Host "Текущий статус управления питанием: $($powerMgmt.Enable)" -ForegroundColor Yellow
        
        if ($powerMgmt.Enable -eq $true) {
            Write-Host "Управление питанием уже включено для этого устройства." -ForegroundColor Green
            return $true
        }
        
        # Включение управления питанием
        $powerMgmt.Enable = $true
        $updateResult = $powerMgmt.Put()
        
        if ($updateResult.ReturnValue -eq 0) {
            Write-Host "Управление питанием успешно включено для устройства: $($device.Name)" -ForegroundColor Green
            return $true
        } else {
            Write-Error "Не удалось включить управление питанием. Код возврата: $($updateResult.ReturnValue)"
            return $false
        }
        
    } catch {
        Write-Error "Произошла ошибка: $($_.Exception.Message)"
        return $false
    }
}

# Альтернативный подход через реестр
function Enable-DevicePowerManagement-Registry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DeviceInstanceId
    )
    
    try {
        # Путь к реестру для настроек устройств
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$DeviceInstanceId\Device Parameters"
        
        if (-not (Test-Path $registryPath)) {
            Write-Error "Путь в реестре не найден для устройства: $DeviceInstanceId"
            return $false
        }
        
        # Включение управления питанием через реестр
        Set-ItemProperty -Path $registryPath -Name "EnhancedPowerManagementEnabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $registryPath -Name "AllowIdleIrpInD3" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        
        Write-Host "Управление питанием включено через реестр для устройства: $DeviceInstanceId" -ForegroundColor Green
        Write-Warning "Для вступления изменений в силу может потребоваться перезагрузка компьютера."
        
        return $true
        
    } catch {
        Write-Error "Ошибка при изменении реестра: $($_.Exception.Message)"
        return $false
    }
}

# Функция для получения списка устройств с поддержкой управления питанием
function Get-PowerManagementCapableDevices {
    [CmdletBinding()]
    try {
        Write-Host "Поиск устройств с поддержкой управления питанием..." -ForegroundColor Yellow
        
        $devices = Get-WmiObject -Class MSPower_DeviceEnable | ForEach-Object {
            # Приводим InstanceName к стандартному виду DeviceID
            $deviceId = $_.InstanceName.Replace('\\', '\')
            $device = Get-WmiObject -Class Win32_PnPEntity -Filter "DeviceID='$deviceId'"
            
            if ($device) {
                [PSCustomObject]@{
                    Name = $device.Name
                    DeviceID = $deviceId
                    PowerManagementEnabled = $_.Enable
                    Status = $device.Status
                    Class = $device.PNPClass
                }
            }
        }
        
        # Фильтруем пустые результаты на случай, если для какого-то устройства не нашлось описания
        return $devices | Where-Object { $_ -ne $null }
        
    } catch {
        Write-Error "Ошибка при получении списка устройств: $($_.Exception.Message)"
        return $null
    }
}


# --- ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ ---
#
# # 1. Получить список всех устройств, которые поддерживают управление питанием, и вывести в виде таблицы
# $devices = Get-PowerManagementCapableDevices
# $devices | Format-Table -AutoSize
# 
# # 2. Скопируйте DeviceID нужного устройства из таблицы выше и вставьте в команду ниже
# # Пример DeviceID: "USB\VID_046D&PID_C52B\5&2734E50&0&6"
# $targetDeviceId = "ВАШ_DEVICE_ID_ЗДЕСЬ"
# 
# # 3. Включить управление питанием для конкретного устройства (основной метод)
# # Enable-PnpDevicePowerManagement -DeviceInstanceId $targetDeviceId
# 
# # 4. Альтернативный способ через реестр, если основной не сработал
# # Enable-DevicePowerManagement-Registry -DeviceInstanceId $targetDeviceId