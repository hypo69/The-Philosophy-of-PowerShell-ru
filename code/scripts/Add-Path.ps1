# --- НАЧАЛО БЛОКА: Создание папки и добавление в PATH ---

# 1. Задайте путь к вашей целевой папке со скриптами
$scriptsPath = "C:\PowerShell\Scripts"

# 2. Проверяем, существует ли папка. Если нет - создаем.
if (-not (Test-Path -Path $scriptsPath)) {
    Write-Host "Папка '$scriptsPath' не найдена. Создаю ее..." -ForegroundColor Yellow
    # Создаем папку. Ключ -Force подавляет ошибку, если папка уже есть, и создает родительские папки при необходимости.
    # | Out-Null скрывает вывод команды New-Item.
    New-Item -Path $scriptsPath -ItemType Directory -Force | Out-Null
    Write-Host "✅ Папка '$scriptsPath' успешно создана." -ForegroundColor Green
}

# 3. Получаем текущее значение переменной PATH для пользователя
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')

# 4. Разбиваем PATH на отдельные пути и проверяем, есть ли уже наш
# Используем -ne '' для удаления пустых записей, которые могут возникнуть из-за ";;"
$pathEntries = $userPath -split ';' -ne ''
if ($pathEntries -contains $scriptsPath) {
    Write-Host "✅ Путь '$scriptsPath' уже находится в переменной PATH." -ForegroundColor Green
} else {
    # 5. Если пути нет, добавляем его
    $newPath = "$userPath;$scriptsPath"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "✅ Путь '$scriptsPath' успешно добавлен в переменную PATH для вашего пользователя." -ForegroundColor Green
    Write-Host "   Пожалуйста, перезапустите ваше окно PowerShell, чтобы изменения вступили в силу."
    
    # Бонус: Обновляем PATH для ТЕКУЩЕЙ сессии, чтобы не перезапускать окно прямо сейчас
    $env:Path += ";$scriptsPath"
}

# --- КОНЕЦ БЛОКА ---