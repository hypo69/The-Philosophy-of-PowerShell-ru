#requires -Version 7.2
#requires -RunAsAdministrator

# =================================================================================
# Add-Path.ps1 — Безопасное добавление директории в переменную среды PATH
# PowerShell >= 5.1
# Запускать от имени администратора!
# Автор: hypo69
# Дата создания: 07/08/2025
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
    Добавляет указанную директорию в переменную среды PATH для текущего пользователя.

.DESCRIPTION
    Этот скрипт безопасно добавляет путь к директории в переменную среды PATH. 
    Сначала он проверяет, существует ли директория, и создает ее, если она отсутствует. 
    Затем он проверяет, присутствует ли путь в переменной PATH, чтобы избежать дублирования. 
    Изменения применяются перманентно для текущего пользователя, а также для текущей сессии PowerShell.

.PARAMETER Path
    Полный путь к директории, которую вы хотите добавить в PATH.
    Если не указан, по умолчанию используется 'C:\PowerShell\Scripts'.

.EXAMPLE
    PS C:\> .\Add-Path.ps1
    
    Создаст (если необходимо) директорию 'C:\PowerShell\Scripts' и добавит ее в PATH.

.EXAMPLE
    PS C:\> .\Add-Path.ps1 -Path "D:\MyTools"
    
    Создаст (если необходимо) директорию 'D:\MyTools' и добавит ее в PATH.

.NOTES
    Изменения переменной PATH требуют перезапуска PowerShell, чтобы они вступили в силу в новых сессиях.
    Скрипт является идемпотентным: его можно безопасно запускать многократно.
#>
param(
    [string]$Path = "C:\PowerShell\Scripts"
)

# --- НАЧАЛО БЛОКА: Создание папки и добавление в PATH ---

# 1. Проверяем, существует ли папка. Если нет - создаем.
if (-not (Test-Path -Path $Path)) {
    Write-Host "Папка '$Path' не найдена. Создаю ее..." -ForegroundColor Yellow
    # Создаем папку. Ключ -Force подавляет ошибку, если папка уже есть, и создает родительские папки при необходимости.
    # | Out-Null скрывает вывод команды New-Item.
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
    Write-Host "✅ Папка '$Path' успешно создана." -ForegroundColor Green
}

# 2. Получаем текущее значение переменной PATH для пользователя
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')

# 3. Разбиваем PATH на отдельные пути и проверяем, есть ли уже наш
# Используем -ne '' для удаления пустых записей, которые могут возникнуть из-за ";;"
$pathEntries = $userPath -split ';' -ne ''
if ($pathEntries -contains $Path) {
    Write-Host "✅ Путь '$Path' уже находится в переменной PATH." -ForegroundColor Green
} else {
    # 4. Если пути нет, добавляем его
    $newPath = "$userPath;$Path"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "✅ Путь '$Path' успешно добавлен в переменную PATH для вашего пользователя." -ForegroundColor Green
    Write-Host "   Пожалуйста, перезапустите ваше окно PowerShell, чтобы изменения вступили в силу."
    
    # Бонус: Обновляем PATH для ТЕКУЩЕЙ сессии, чтобы не перезапускать окно прямо сейчас
    $env:Path += ";$Path"
}

# --- КОНЕЦ БЛОКА ---