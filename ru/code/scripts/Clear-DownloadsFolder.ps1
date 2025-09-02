# =================================================================================
# Clear-DownloadsFolder.ps1 — Интерактивный скрипт для поиска и удаления больших файлов из папки "Загрузки"
# Windows PowerShell >= 5.1 (требуется для Compress-Archive).
# Автор: hypo69
# Дата создания: 12/06/2025 
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
    Интерактивный скрипт для поиска и удаления больших файлов из папки "Загрузки".
.DESCRIPTION
    Этот скрипт требует ручной настройки пути к папке "Загрузки", чтобы
    гарантированно работать в любой, включая локализованные, версии Windows.
#>

# =============================================================================
# ===                           НАСТРОЙКА                                 ===
# =============================================================================
# Укажите здесь ПОЛНЫЙ путь к вашей папке "Загрузки".
# Этот шаг необходим, чтобы скрипт работал надежно в любой системе.
#
# Пример для русской Windows:
# $DownloadsPath = "C:\Users\ВашеИмя\Загрузки"
#
# Пример, если папка перенесена на другой диск:
# $DownloadsPath = "E:\Users\user\Downloads"

$DownloadsPath = "E:\Users\user\Downloads" # <--- ИЗМЕНИТЕ ЭТУ СТРОКУ

# =============================================================================
# ===                      ОСНОВНАЯ ЛОГИКА СКРИПТА                        ===
# =============================================================================

# Финальная проверка: если путь не указан или папка не существует - выходим.
if ([string]::IsNullOrEmpty($DownloadsPath) -or (-not (Test-Path -Path $DownloadsPath))) {
    Write-Error "Папка 'Загрузки' не найдена по указанному пути: '$DownloadsPath'. Пожалуйста, проверьте путь в блоке НАСТРОЙКА в начале скрипта."
    return
}

# --- ШАГ 2: Информирование пользователя и сбор данных ---
Write-Host "Начинаю сканирование папки '$DownloadsPath'. Это может занять некоторое время..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $DownloadsPath -File -Recurse -ErrorAction SilentlyContinue | 
    Sort-Object -Property Length -Descending

# --- ШАГ 3: Проверка наличия файлов и вызов интерактивного окна ---
if ($files) {
    Write-Host "Сканирование завершено. Найдено $($files.Count) файлов. Открытие окна выбора..." -ForegroundColor Green
    
    $filesToShow = $files | Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime
    
    $filesToDelete = $filesToShow | Out-ConsoleGridView -OutputMode Multiple -Title "Выберите файлы для удаления из '$DownloadsPath'"

    # --- ШАГ 4: Обработка выбора пользователя ---
    if ($filesToDelete) {
        Write-Host "Следующие файлы будут удалены:" -ForegroundColor Yellow
        $filesToDelete | Format-Table -AutoSize
        
        $filesToDelete.FullName | Remove-Item -WhatIf -Verbose
    } else {
        Write-Host "Операция отменена. Не выбрано ни одного файла." -ForegroundColor Yellow
    }
} else {
    Write-Host "В папке '$DownloadsPath' не найдено файлов." -ForegroundColor Yellow
}