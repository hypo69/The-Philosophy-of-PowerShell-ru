# =================================================================================
# Manage-Agents.ps1
# Скрипт для управления и отображения статуса проекта SmartAgents
# =================================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Status', 'Help')]
    [string]$Action
)

$ScriptRoot = $PSScriptRoot

# --- Функции скрипта ---

function Show-ProjectStatus {
    Write-Host "`n--- Статус проекта SmartAgents ---`n" -ForegroundColor Cyan
    
    # Находим всех агентов (по наличию папок)
    $agentDirs = Get-ChildItem -Path $ScriptRoot -Directory | Where-Object { $_.Name -ne '.vscode' -and $_.Name -ne '.git' }
    
    if (-not $agentDirs) {
        Write-Host "Агенты не найдены." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Обнаружено агентов: $($agentDirs.Count)"
    
    foreach ($dir in $agentDirs) {
        $agentName = $dir.Name
        $mainScriptPath = Get-ChildItem -Path $dir.FullName -Filter "*.ps1" | Select-Object -First 1
        $geminiDir = Join-Path $dir.FullName ".gemini"
        
        Write-Host "`nАгент: $($agentName)" -ForegroundColor Green
        
        # Проверка основного скрипта
        if ($mainScriptPath) {
            Write-Host "  [✓] Основной скрипт: $($mainScriptPath.Name)"
        } else {
            Write-Host "  [✗] Основной скрипт: НЕ НАЙДЕН" -ForegroundColor Red
        }
        
        # Проверка конфигурации
        if (Test-Path $geminiDir) {
            Write-Host "  [✓] Папка .gemini: Найдена"
            if (Test-Path (Join-Path $geminiDir "GEMINI.md")) {
                 Write-Host "    [✓] Файл GEMINI.md"
            } else {
                 Write-Host "    [✗] Файл GEMINI.md: НЕ НАЙДЕН" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [✗] Папка .gemini: НЕ НАЙДЕНА" -ForegroundColor Red
        }
    } # <-- ЭТА СКОБКА БЫЛА ПРОПУЩЕНА
}

function Show-Help {
    Write-Host @"

Скрипт управления проектом SmartAgents.

ИСПОЛЬЗОВАНИЕ:
    .\Manage-Agents.ps1 -Action <Действие>

ДЕЙСТВИЯ:
    Status      - Показывает статус всех найденных агентов в проекте,
                  проверяет наличие ключевых файлов.
    
    Help        - Показывает это сообщение.

"@
}

# --- Основная логика ---

switch ($Action) {
    'Status' { Show-ProjectStatus }
    'Help'   { Show-Help }
}