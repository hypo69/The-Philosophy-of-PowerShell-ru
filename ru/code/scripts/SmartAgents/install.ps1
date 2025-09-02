# =================================================================================
# install.ps1
# Скрипт настройки и проверки окружения для SmartAgents
# Автор: hypo69
# Дата создания: 26/08/2025
# Версия: 4.0 (Упрощенная, без проверки файлов)
# =================================================================================

<#
.SYNOPSIS
    Проверяет системные зависимости и настраивает окружение для работы с фреймворком SmartAgents.
.DESCRIPTION
    Этот скрипт НЕ проверяет наличие файлов проекта. Он работает "на месте" и выполняет:
    1. Проверку системных зависимостей (PowerShell 7, Gemini CLI).
    2. Настройку API-ключа для текущей сессии.
.PARAMETER ApiKey
    Gemini API ключ для настройки переменной окружения.
.EXAMPLE
    .\install.ps1 -ApiKey "ВАШ_API_КЛЮЧ"
    # Проверит системные требования и установит ключ для текущей сессии.
#>

[CmdletBinding()]
param(
    [string]$ApiKey
)

# =================================================================================
# ФУНКЦИИ ПРОВЕРКИ И НАСТРОЙКИ
# =================================================================================

function Write-InstallMessage {
    param([string]$Message, [string]$Type = 'Info')
    $color = switch ($Type) { 'Success' { 'Green' } 'Warning' { 'Yellow' } 'Error' { 'Red' } 'Info' { 'Cyan' } default { 'White' } }
    $prefix = switch ($Type) { 'Success' { '[✓]' } 'Warning' { '[!]' } 'Error' { '[✗]' } 'Info' { '[i]' } default { '[-]' } }
    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-InstallMessage "Шаг 1: Проверка системных требований..." -Type 'Info'
    $issues = @()
    if ($PSVersionTable.PSVersion.Major -lt 7) { $issues += "Требуется PowerShell 7+. Текущая версия: $($PSVersionTable.PSVersion)" }
    else { Write-InstallMessage "PowerShell версия: $($PSVersionTable.PSVersion)" -Type 'Success' }
    try { $geminiVersion = & gemini --version 2>&1; Write-InstallMessage "Gemini CLI найден: $geminiVersion" -Type 'Success' }
    catch { $issues += "Gemini CLI не найден в PATH. Убедитесь, что он установлен." }
    try { Get-Command Out-ConsoleGridView -ErrorAction Stop | Out-Null; Write-InstallMessage "Out-ConsoleGridView доступен" -Type 'Success' }
    catch { $issues += "Out-ConsoleGridView недоступен. Установите модуль Microsoft.PowerShell.ConsoleGuiTools." }
    
    if ($issues.Count -gt 0) {
        Write-InstallMessage "Найдены проблемы с системными требованиями:" -Type 'Error'; $issues | ForEach-Object { Write-InstallMessage "  - $_" -Type 'Error' }; return $false
    }
    
    Write-InstallMessage "Системные требования в порядке" -Type 'Success'
    return $true
}

function Set-ApiKeyEnvironment {
    param([string]$ApiKey)
    Write-InstallMessage "Шаг 2: Настройка API-ключа..." -Type 'Info'
    if (-not $ApiKey) {
        Write-InstallMessage "API ключ не предоставлен. Установите его вручную перед использованием агентов:" -Type 'Warning'
        Write-Host "`$env:GEMINI_API_KEY = 'your-key'" -ForegroundColor Gray
        return
    }
    $env:GEMINI_API_KEY = $ApiKey
    Write-InstallMessage "API ключ установлен для текущей сессии" -Type 'Success'
    Write-InstallMessage "Для постоянной установки добавьте в ваш профиль PowerShell:" -Type 'Info'
    Write-Host "`$env:GEMINI_API_KEY = '$ApiKey'" -ForegroundColor Gray
}

function Show-PostInstallInstructions {
    $instructions = @"

`n`e[1;32mПроверка и настройка успешно завершены!`e[0m

Вы готовы к работе.

`e[1;36mПримеры запуска агентов (из текущей директории):`e[0m
1. Запуск поисковика спецификаций:
   `e[33m.\FindSpec\Find-Spec.ps1`e[0m

2. Запуск планировщика перелетов:
   `e[33m.\FlightPlan\Flight-Plan.ps1`e[0m

3. Для управления проектом используйте:
   `e[33m.\Manage-Agents.ps1 -Action Status`e[0m

"@
    Write-Host $instructions
}

# =================================================================================
# ОСНОВНАЯ ЛОГИКА
# =================================================================================

function Start-Setup {
    Write-Host "`n=================================================`n Настройка и проверка SmartAgents Framework`n=================================================`n" -ForegroundColor Cyan

    if (-not (Test-Prerequisites)) { 
        Write-InstallMessage "Настройка прервана из-за проблем с системными требованиями." -Type 'Error'
        return 
    }
    
    Set-ApiKeyEnvironment -ApiKey $ApiKey
    
    Show-PostInstallInstructions
}

# =================================================================================
# ЗАПУСК
# =================================================================================

Start-Setup