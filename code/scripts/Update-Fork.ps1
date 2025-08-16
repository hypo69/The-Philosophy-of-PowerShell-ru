# =================================================================================
# Update-Fork.ps1 — Обновляет локальную ветку master из upstream репозитория и принудительно пушит в origin.
# PowerShell >= 5.1
# НЕ требует прав администратора.
# Автор: hypo69
# Версия: 1.1 (адаптировано Gemini)
# Дата создания: 07/08/2025
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
    Обновляет локальную ветку master из upstream репозитория и принудительно пушит в origin.

.DESCRIPTION
    Скрипт выполняет последовательность команд:
    1. git fetch upstream
    2. git rebase upstream/master
    3. git push origin master --force
    Предназначен для быстрой синхронизации форков.

.PARAMETER GitDirectory
    Путь к локальному git-репозиторию. По умолчанию используется текущая директория.

.EXAMPLE
    PS C:\my-repo> Update-Fork.ps1
    Обновит репозиторий 'C:\my-repo'.

.EXAMPLE
    PS C:\> Update-Fork.ps1 -GitDirectory "D:\projects\another-repo"
    Обновит репозиторий в указанной директории.
#>
[CmdletBinding()]
param(
    [string]$GitDirectory = (Get-Location).Path
)

# --- Улучшение: Проверяем, существует ли модуль для уведомлений ---
$BurntToastModule = Get-Module -Name BurntToast -ListAvailable
if ($null -eq $BurntToastModule) {
    Write-Warning "Модуль 'BurntToast' для уведомлений не найден. Уведомления будут отключены."
}

# --- Улучшение: Используем Push/Pop-Location для безопасной смены директории ---
# Это гарантирует, что после выполнения скрипта вы вернетесь в исходную папку.
Push-Location -Path $GitDirectory

Write-Host "🔄 Начинаем обновление форка в директории: $(Get-Location)" -ForegroundColor Cyan

# --- Улучшение: Убрана неиспользуемая переменная $currentBranch ---

Write-Host "📥 Забираем изменения из upstream..." -ForegroundColor Cyan
git fetch upstream

Write-Host "🛠  Делаем rebase с upstream/master..." -ForegroundColor Cyan
git rebase upstream/master

if ($LASTEXITCODE -ne 0) {
    Write-Host "❗ При ребейсе возникли конфликты. Разреши их и выполни: git rebase --continue" -ForegroundColor Red
    if ($BurntToastModule) {
        New-BurntToastNotification -Text "❗ Конфликт при rebase!", "Требуется ручное вмешательство."
    }
    Pop-Location # <--- Возвращаемся в исходную директорию
    return
}

Write-Host "🚀 Пушим изменения в свой форк (с --force)..." -ForegroundColor Cyan
git push origin master --force

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Форк успешно обновлён!" -ForegroundColor Green
    if ($BurntToastModule) {
        New-BurntToastNotification -Text "✅ Форк обновлён!", "Можешь продолжать работу!"
    }
} else {
    Write-Host "❌ Не удалось запушить. Проверь ошибки." -ForegroundColor Red
    if ($BurntToastModule) {
        # --- Улучшение: Исправлена опечатка и улучшен текст сообщения ---
        New-BurntToastNotification -Text "❌ Ошибка при пуше!", "Проверь вывод в консоли."
    }
}

# Возвращаемся в исходную директорию, из которой был запущен скрипт
Pop-Location