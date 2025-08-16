#requires -Version 5.1
#requires -RunAsAdministrator

# =================================================================================
# Add-SystemPath.ps1 — Добавление директории в СИСТЕМНЫЙ PATH для ВСЕХ ПОЛЬЗОВАТЕЛЕЙ
# PowerShell >= 5.1
# Требует запуска от имени Администратора!
# Автор: hypo69
# Версия: 1.1 (адаптировано Gemini)
# Дата создания: 07/08/2025
# =================================================================================

# =================================================================================
# ЛИЦЕНЗИЯ (MIT) - без изменений
# =================================================================================
<#
.SYNOPSIS
    Добавляет указанную директорию в СИСТЕМНУЮ переменную среды PATH.

.DESCRIPTION
    Скрипт безопасно добавляет путь к директории в системную переменную PATH (для всех пользователей).
    Он требует прав Администратора.
    Проверяет существование директории и создает ее при необходимости. 
    Затем проверяет наличие пути в PATH, чтобы избежать дублирования.

.PARAMETER Path
    Полный путь к директории для добавления в системный PATH.
    По умолчанию: 'C:\Program Files\Scripts'.

.EXAMPLE
    PS C:\> .\Add-SystemPath.ps1 -Path "C:\Tools"
    Добавит 'C:\Tools' в системный PATH.

.NOTES
    Автор: hypo69
    Изменения требуют перезапуска консоли для вступления в силу в новых сессиях.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "C:\Program Files\Scripts"
)

Write-Verbose "Начало выполнения скрипта для добавления '$Path' в системный PATH."

# 1. Проверяем и создаем папку, если необходимо
if (-not (Test-Path -Path $Path)) {
    Write-Host "Папка '$Path' не найдена. Создаю ее..." -ForegroundColor Yellow
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
    Write-Host "✅ Папка '$Path' успешно создана." -ForegroundColor Green
}

# 2. Получаем СИСТЕМНЫЙ PATH
$scope = [System.EnvironmentVariableTarget]::Machine # <--- ИЗМЕНЕНО
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', $scope)

# 3. Проверяем наличие пути в PATH
$pathEntries = $currentPath -split ';' -ne ''
if ($pathEntries -contains $Path) {
    Write-Host "✅ Путь '$Path' уже находится в системной переменной PATH." -ForegroundColor Green
} else {
    # 4. Добавляем новый путь
    $newPath = "$currentPath;$Path"
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, $scope) # <--- ИЗМЕНЕНО
    Write-Host "✅ Путь '$Path' успешно добавлен в СИСТЕМНУЮ переменную PATH." -ForegroundColor Green
    
    # Обновляем PATH для текущей сессии
    $env:Path += ";$Path"
    Write-Host "   Изменения применены для текущей сессии. Перезапустите консоль для постоянного эффекта."
}

Write-Verbose "Выполнение скрипта завершено."