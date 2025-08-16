# =================================================================================
# Add-UserPath.ps1 — Добавление директории в PATH для ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ
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
    Добавляет указанную директорию в переменную среды PATH для ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ.

.DESCRIPTION
    Скрипт безопасно добавляет путь к директории в переменную PATH текущего пользователя.
    Он проверяет существование директории и создает ее при необходимости. 
    Затем проверяет наличие пути в PATH, чтобы избежать дублирования.

.PARAMETER Path
    Полный путь к директории для добавления в PATH.
    По умолчанию: 'C:\PowerShell\Scripts'.

.EXAMPLE
    PS C:\> .\Add-UserPath.ps1 -Path "D:\MyTools"
    Добавит 'D:\MyTools' в PATH для текущего пользователя.

.NOTES
    Автор: hypo69
    Изменения требуют перезапуска консоли для вступления в силу в новых сессиях.
#>
[CmdletBinding()] # <--- ДОБАВЛЕНО: Включает стандартные параметры, например -Verbose
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "C:\PowerShell\Scripts"
)

Write-Verbose "Начало выполнения скрипта для пути '$Path'."

# 1. Проверяем и создаем папку, если необходимо
if (-not (Test-Path -Path $Path)) {
    Write-Host "Папка '$Path' не найдена. Создаю ее..." -ForegroundColor Yellow
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
    Write-Host "✅ Папка '$Path' успешно создана." -ForegroundColor Green
}

# 2. Получаем PATH для текущего пользователя
$scope = [System.EnvironmentVariableTarget]::User
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', $scope)

# 3. Проверяем наличие пути в PATH
$pathEntries = $currentPath -split ';' -ne ''
if ($pathEntries -contains $Path) {
    Write-Host "✅ Путь '$Path' уже находится в пользовательской переменной PATH." -ForegroundColor Green
} else {
    # 4. Добавляем новый путь, избегая лишней ';' в начале
    $newPath = if ([string]::IsNullOrEmpty($currentPath)) { $Path } else { "$currentPath;$Path" }
    
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, $scope)
    Write-Host "✅ Путь '$Path' успешно добавлен в PATH для вашего пользователя." -ForegroundColor Green
    
    # Обновляем PATH для текущей сессии
    $env:Path += ";$Path"
    Write-Host "   Изменения применены для текущей сессии. Перезапустите консоль для постоянного эффекта."
}

Write-Verbose "Выполнение скрипта завершено."