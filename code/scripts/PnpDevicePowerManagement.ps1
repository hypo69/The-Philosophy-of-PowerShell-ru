# =================================================================================
# СКРИПТ ДЛЯ ВКЛЮЧЕНИЯ ЭНЕРГОСБЕРЕЖЕНИЯ СЕТЕВОГО АДАПТЕРА
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
    Включает параметр "Разрешить отключение этого устройства для экономии энергии" для сетевого адаптера.

.DESCRIPTION
    Скрипт находит сетевой адаптер по его имени (или части имени) и устанавливает для него флаг,
    позволяющий Windows отключать устройство для экономии энергии.

    Используется надежный метод через CIM/WMI, который работает в стандартном PowerShell 5.1
    и не требует установки дополнительных модулей.

    Этот скрипт предназначен в первую очередь для СЕТЕВЫХ АДАПТЕРОВ.

.NOTES
    Автор: hypo69
    Дата: 12/06/2025
    Требуются права администратора для изменения системных настроек.
#>

#----------------------------------------------------
# БЛОК 1: НАСТРОЙКИ СКРИПТА
#----------------------------------------------------

# Укажите здесь часть имени устройства, которое вы хотите настроить.
# Например: "*Wi-Fi*", "*Ethernet*", "Intel(R) Ethernet Controller*".
$targetDeviceName = "*Ethernet*"

#----------------------------------------------------
# БЛОК 2: ПОИСК УСТРОЙСТВА
#----------------------------------------------------

Write-Host "--- 1. Поиск устройства по маске: '$targetDeviceName'..." -ForegroundColor Yellow
$device = Get-PnpDevice -FriendlyName $targetDeviceName | Select-Object -First 1

#----------------------------------------------------
# БЛОК 3: ПРИМЕНЕНИЕ НАСТРОЕК
#----------------------------------------------------

# Проверяем, было ли найдено устройство
if ($device) {
    # Получаем точное имя найденного устройства для дальнейшей работы
    $exactDeviceName = $device.FriendlyName
    Write-Host "Найдено устройство: '$exactDeviceName'" -ForegroundColor Green
    
    # Используем блок try...catch для безопасной обработки возможных ошибок
    try {
        # Ищем настройки управления питанием именно для этого сетевого адаптера.
        # Класс MSFT_NetAdapterPowerManagementSettingData предназначен специально для этой задачи.
        $powerSettings = Get-CimInstance -Namespace 'Root\StandardCimv2' -ClassName MSFT_NetAdapterPowerManagementSettingData -Filter "Name = '$exactDeviceName'" -ErrorAction Stop
        
        Write-Host "Текущий статус энергосбережения: $($powerSettings.AllowComputerToTurnOffDevice)"

        # Проверяем, если энергосбережение еще не включено
        if (-not $powerSettings.AllowComputerToTurnOffDevice) {
            Write-Host "--- 2. Включаю энергосбережение..." -ForegroundColor Cyan
            
            # Шаг 1: Изменяем свойство в объекте, который хранится в памяти
            $powerSettings.AllowComputerToTurnOffDevice = $true
            
            # Шаг 2: Сохраняем (применяем) измененный объект обратно в систему
            Set-CimInstance -CimInstance $powerSettings
            
            # Шаг 3 (Верификация): Снова запрашиваем данные из системы, чтобы убедиться, что они применились
            $newSettings = Get-CimInstance -Namespace 'Root\StandardCimv2' -ClassName MSFT_NetAdapterPowerManagementSettingData -Filter "Name = '$exactDeviceName'"
            Write-Host "Готово! Новое состояние энергосбережения: $($newSettings.AllowComputerToTurnOffDevice)" -ForegroundColor Green

        } else {
            Write-Host "Энергосбережение для этого устройства уже включено. Действий не требуется." -ForegroundColor Green
        }

    }
    catch {
        # Этот блок сработает, если на любом этапе в блоке 'try' произойдет ошибка
        Write-Host "`nОШИБКА: Не удалось получить или изменить настройки управления питанием." -ForegroundColor Red
        Write-Host "Возможные причины:" -ForegroundColor Red
        Write-Host " - Устройство '$exactDeviceName' не является сетевым адаптером."
        Write-Host " - Драйвер устройства не поддерживает управление питанием через WMI/CIM."
        Write-Host " - Отсутствуют права администратора."
    }
} 
else {
    # Этот блок сработает, если Get-PnpDevice ничего не нашел
    Write-Host "Устройство с именем, содержащим '$targetDeviceName', не найдено в системе." -ForegroundColor Red
}

Write-Host "`nСкрипт завершил работу."