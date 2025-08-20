# =================================================================================
# ЗАПУСК GEMINI CLI С ДИНАМИЧЕСКИМ MCP-СЕРВЕРОМ В ТЕКУЩЕМ КАТАЛОГЕ
# PowerShell >= 7.2, Windows PowerShell >= 5.1
# Требует установленного модуля Pode.
# =================================================================================

# --- НАСТРОЙКА ---
# Порт, на котором будет работать наш MCP-сервер
$McpPort = 8090
# -----------------

# --- ШАГ 1: Проверка зависимостей  ---
if (-not (Get-Module -ListAvailable -Name Pode)) {
    Write-Error "Модуль 'Pode' не найден. Пожалуйста, установите его командой: Install-Module -Name Pode -Scope CurrentUser"
    return
}
if (-not (Get-Command gemini -ErrorAction SilentlyContinue)) {
    Write-Error "Команда 'gemini' не найдена. Убедитесь, что Gemini CLI установлен и доступен в PATH."
    return
}

# --- ШАГ 2: Запуск MCP-сервера в фоновой задаче  ---
Write-Host "Запуск MCP-сервера на порту $McpPort в фоновом режиме..." -ForegroundColor Cyan
$mcpJob = Start-Job -ScriptBlock {
    # ... (код сервера остается тем же) ...
} -ArgumentList $McpPort

# ... (проверка запуска задачи остается той же) ...
Write-Host "MCP-сервер успешно запущен (Job ID: $($mcpJob.Id))." -ForegroundColor Green

# --- ШАГ 3 (ИЗМЕНЕННЫЙ): Создание файла конфигурации в ТЕКУЩЕЙ директории ---
$currentDir = Get-Location
$configDir = Join-Path -Path $currentDir -ChildPath ".gemini"
$configFile = Join-Path -Path $configDir -ChildPath "settings.json"
$backupFile = $configFile + ".bak" # Имя для бэкапа существующего файла

# Проверяем, существует ли уже файл настроек, и делаем бэкап
$existingConfig = $null
if (Test-Path $configFile) {
    Write-Warning "Обнаружен существующий файл 'settings.json'. Создается резервная копия..."
    Move-Item -Path $configFile -Destination $backupFile -Force
    $existingConfig = Get-Content -Path $backupFile -Raw
}

# Создаем директорию .gemini, если ее нет
if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory | Out-Null
}

# Создаем JSON-конфигурацию
$mcpConfig = @{
    mcp_servers = @(
        @{
            name = "PowerShell Script Runner"
            url = "http://localhost:$McpPort"
            tools = @("run-script")
        }
    )
} | ConvertTo-Json -Depth 3

# Записываем нашу временную конфигурацию
$mcpConfig | Out-File -FilePath $configFile -Encoding utf8
Write-Host "Временный файл 'settings.json' создан в текущей директории." -ForegroundColor Green


# --- ШАГ 4: Запуск gemini CLI ---
Write-Host "Запуск Gemini CLI... (Для выхода и остановки MCP-сервера введите '/quit')" -ForegroundColor Cyan
try {
    # Запускаем gemini. Он автоматически найдет .gemini/settings.json в текущей папке.
    gemini
}
catch {
    Write-Error "Ошибка при запуске Gemini CLI: $_"
}
finally {
    # --- ШАГ 5: Очистка после завершения работы ---
    Write-Host "Gemini CLI завершил работу. Остановка MCP-сервера..." -ForegroundColor Cyan
    Stop-Job -Job $mcpJob
    Remove-Job -Job $mcpJob -Force

    # Удаляем наш временный файл
    Remove-Item -Path $configFile -Force
    
    # Если был бэкап, восстанавливаем его
    if (Test-Path $backupFile) {
        Write-Host "Восстановление оригинального файла 'settings.json' из бэкапа..."
        Move-Item -Path $backupFile -Destination $configFile -Force
        Write-Host "Оригинальный файл восстановлен."
    } elseif ( (Get-ChildItem -Path $configDir).Count -eq 0 ) {
        # Если папка .gemini стала пустой, удаляем ее
        Remove-Item -Path $configDir -Force
    }
    
    Write-Host "Очистка завершена." -ForegroundColor Green
}