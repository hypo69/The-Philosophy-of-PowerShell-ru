function Enable-PnpDevicePowerManagement {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DeviceInstanceId
    )
    
    try {
        # Поиск устройства по DeviceID
        $device = Get-WmiObject -Class Win32_PnPEntity -Filter "DeviceID='$DeviceInstanceId'"
        
        if (-not $device) {
            Write-Error "Device with ID '$DeviceInstanceId' not found"
            return $false
        }
        
        Write-Host "Found device: $($device.Name)" -ForegroundColor Green
        
        # Получение настроек управления питанием для устройства
        $powerMgmt = Get-WmiObject -Class MSPower_DeviceEnable -Filter "InstanceName='$DeviceInstanceId'"
        
        if (-not $powerMgmt) {
            Write-Warning "Device doesn't support power management or power management settings not found"
            return $false
        }
        
        # Проверка текущего состояния
        Write-Host "Current power management status: $($powerMgmt.Enable)" -ForegroundColor Yellow
        
        if ($powerMgmt.Enable -eq $true) {
            Write-Host "Power management is already enabled for this device" -ForegroundColor Green
            return $true
        }
        
        # Включение управления питанием
        $result = $powerMgmt.Enable = $true
        $updateResult = $powerMgmt.Put()
        
        if ($updateResult.ReturnValue -eq 0) {
            Write-Host "Power management successfully enabled for device: $($device.Name)" -ForegroundColor Green
            return $true
        } else {
            Write-Error "Failed to enable power management. Return code: $($updateResult.ReturnValue)"
            return $false
        }
        
    } catch {
        Write-Error "Error occurred: $($_.Exception.Message)"
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
            Write-Error "Registry path not found for device: $DeviceInstanceId"
            return $false
        }
        
        # Включение управления питанием через реестр
        Set-ItemProperty -Path $registryPath -Name "EnhancedPowerManagementEnabled" -Value 1 -Type DWord
        Set-ItemProperty -Path $registryPath -Name "AllowIdleIrpInD3" -Value 1 -Type DWord
        
        Write-Host "Power management enabled via registry for device: $DeviceInstanceId" -ForegroundColor Green
        Write-Warning "Reboot may be required for changes to take effect"
        
        return $true
        
    } catch {
        Write-Error "Error modifying registry: $($_.Exception.Message)"
        return $false
    }
}

# Функция для получения списка устройств с поддержкой управления питанием
function Get-PowerManagementCapableDevices {
    try {
        Write-Host "Searching for devices with power management capabilities..." -ForegroundColor Yellow
        
        $devices = Get-WmiObject -Class MSPower_DeviceEnable | ForEach-Object {
            $deviceId = $_.InstanceName
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
        
        return $devices | Where-Object { $_ -ne $null }
        
    } catch {
        Write-Error "Error retrieving power management capable devices: $($_.Exception.Message)"
        return $null
    }
}

# Пример использования:
# 
# # Получить список устройств с управлением питанием
# $devices = Get-PowerManagementCapableDevices
# $devices | Format-Table -AutoSize
# 
# # Включить управление питанием для конкретного устройства
# Enable-PnpDevicePowerManagement -DeviceInstanceId "USB\VID_046D&PID_C52B\5&2734E50&0&6"
# 
# # Альтернативный способ через реестр
# Enable-DevicePowerManagement-Registry -DeviceInstanceId "USB\VID_046D&PID_C52B\5&2734E50&0&6"