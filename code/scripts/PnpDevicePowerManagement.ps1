# ----------------------------------------------------------------------------------
# СКРИПТ ДЛЯ ВКЛЮЧЕНИЯ ЭНЕРГОСБЕРЕЖЕНИЯ (УСТАНОВКИ ГАЛОЧКИ) ДЛЯ УСТРОЙСТВА
# Запускать от имени администратора!
# ----------------------------------------------------------------------------------

# 1. Укажите здесь часть имени устройства, которое вы хотите настроить
$targetDeviceName = "*Wi-Fi*" # Например, "*Ethernet*", "*Realtek*", "*USB Root Hub*"

# 2. Поиск устройства
Write-Host "Ищем устройство: '$targetDeviceName'..." -ForegroundColor Yellow
$device = Get-PnpDevice -FriendlyName $targetDeviceName | Select-Object -First 1

# 3. Проверка, найдено ли устройство
if ($device) {
    Write-Host "Найдено: $($device.FriendlyName)"
    Write-Host "Текущий статус энергосбережения: $($device.PowerManagementEnabled)"

    # 4. Если энергосбережение еще не включено, включаем его
    if (-not $device.PowerManagementEnabled) {
        Write-Host "Включаю энергосбережение..." -ForegroundColor Cyan
        Enable-PnpDevicePowerManagement -InstanceId $device.InstanceId -Confirm:$false

        # 5. Проверяем результат
        $newState = (Get-PnpDevice -InstanceId $device.InstanceId).PowerManagementEnabled
        Write-Host "Готово! Новое состояние энергосбережения: $newState" -ForegroundColor Green
    } else {
        Write-Host "Энергосбережение для этого устройства уже включено." -ForegroundColor Green
    }

} else {
    Write-Host "Устройство с именем, содержащим '$targetDeviceName', не найдено." -ForegroundColor Red
}