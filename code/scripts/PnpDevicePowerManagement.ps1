# =================================================================================
# ИСПРАВЛЕННЫЙ СКРИПТ ДЛЯ ВКЛЮЧЕНИЯ ЭНЕРГОСБЕРЕЖЕНИЯ (УСТАНОВКИ ГАЛОЧКИ)
# Этот метод работает в стандартном Windows PowerShell 5.1 и новее.
# Запускать от имени администратора!
# =================================================================================

# 1. Укажите здесь часть имени устройства, которое вы хотите настроить
# Важно: Этот метод лучше всего работает с сетевыми адаптерами.
$targetDeviceName = "*Wi-Fi*" # Например, "*Ethernet*", "Intel(R) Ethernet Controller*", "*USB Root Hub*"

# 2. Поиск устройства (этот шаг оставляем для нахождения точного имени)
Write-Host "Ищем устройство по маске: '$targetDeviceName'..." -ForegroundColor Yellow
$device = Get-PnpDevice -FriendlyName $targetDeviceName | Select-Object -First 1

# 3. Проверка, найдено ли устройство
if ($device) {
    # Получаем точное имя найденного устройства
    $exactDeviceName = $device.FriendlyName
    Write-Host "Найдено устройство: '$exactDeviceName'" -ForegroundColor Green
    
    # ------------------ НАЧАЛО ИСПРАВЛЕНИЯ ------------------
    # Вместо несуществующего командлета используем CIM для доступа к настройкам
    try {
        # Ищем настройки управления питанием именно для этого устройства
        $powerSettings = Get-CimInstance -Namespace 'Root\StandardCimv2' -ClassName MSFT_NetAdapterPowerManagementSettingData -Filter "Name = '$exactDeviceName'" -ErrorAction Stop
        
        Write-Host "Текущий статус энергосбережения: $($powerSettings.AllowComputerToTurnOffDevice)"

        # 4. Если энергосбережение еще не включено, включаем его
        if (-not $powerSettings.AllowComputerToTurnOffDevice) {
            Write-Host "Включаю энергосбережение..." -ForegroundColor Cyan
            
            # Изменяем свойство в объекте
            $powerSettings.AllowComputerToTurnOffDevice = $true
            
            # Сохраняем измененный объект обратно в систему
            Set-CimInstance -CimInstance $powerSettings
            
            # 5. Проверяем результат
            $newSettings = Get-CimInstance -Namespace 'Root\StandardCimv2' -ClassName MSFT_NetAdapterPowerManagementSettingData -Filter "Name = '$exactDeviceName'"
            Write-Host "Готово! Новое состояние энергосбережения: $($newSettings.AllowComputerToTurnOffDevice)" -ForegroundColor Green

        } else {
            Write-Host "Энергосбережение для этого устройства уже включено." -ForegroundColor Green
        }

    }
    catch {
        Write-Host "ОШИБКА: Не удалось получить или изменить настройки управления питанием." -ForegroundColor Red
        Write-Host "Возможные причины:" -ForegroundColor Red
        Write-Host " - Устройство '$exactDeviceName' не является сетевым адаптером." -ForegroundColor Red
        Write-Host " - Устройство не поддерживает управление питанием через WMI/CIM." -ForegroundColor Red
        Write-Host " - Отсутствуют права администратора." -ForegroundColor Red
    }
    # ------------------- КОНЕЦ ИСПРАВЛЕНИЯ ------------------

} else {
    Write-Host "Устройство с именем, содержащим '$targetDeviceName', не найдено." -ForegroundColor Red
}