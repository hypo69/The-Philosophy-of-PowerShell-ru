# =================================================================================
# Backup-FolderToZip.ps1 — Функция для создания ZIP-архива папки
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

function Backup-FolderToZip {
<#
.SYNOPSIS
    Создает ZIP-архив указанной папки с временной меткой в имени файла.

.DESCRIPTION
    Эта функция архивирует содержимое исходной папки в ZIP-файл.
    Имя архива генерируется автоматически по шаблону "Backup_[ИмяПапки]_[Дата_Время].zip".
    Если папка назначения не существует, она будет создана.

.PARAMETER SourcePath
    Путь к папке, которую необходимо заархивировать.

.PARAMETER DestinationPath
    Путь к папке, где будет сохранен ZIP-архив.

.EXAMPLE
    Backup-FolderToZip -SourcePath "C:\Users\User\Documents" -DestinationPath "D:\Backups"
    Создаст архив папки 'Documents' в 'D:\Backups'. Имя файла будет примерно 'Backup_Documents_2025-06-12_15-30.zip'.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory, HelpMessage = "Укажите путь к исходной папке.")]
        [string]$SourcePath,

        [Parameter(Mandatory, HelpMessage = "Укажите путь для сохранения архива.")]
        [string]$DestinationPath
    )

    # Проверяем, существует ли исходная папка
    if (-not (Test-Path -Path $SourcePath)) {
        # Используем Throw для генерации ошибки, которая остановит выполнение
        Throw "Исходная папка не найдена по пути: '$SourcePath'"
    }

    # Генерируем имя файла для архива
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $archiveFileName = "Backup_{0}_{1}.zip" -f (Split-Path $SourcePath -Leaf), $timestamp
    $fullArchivePath = Join-Path $DestinationPath $archiveFileName

    # Проверяем и создаем папку назначения, если нужно
    if (-not (Test-Path -Path $DestinationPath)) {
        Write-Verbose "Создание папки назначения: $DestinationPath"
        New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
    }

    # Основное действие - архивация
    if ($PSCmdlet.ShouldProcess($SourcePath, "Архивировать в '$fullArchivePath'")) {
        Compress-Archive -Path "$SourcePath\*" -DestinationPath $fullArchivePath -Force
        Write-Host "Резервное копирование успешно завершено: $fullArchivePath" -ForegroundColor Green
    }
}


# --- ПРИМЕР ИСПОЛЬЗОВАНИЯ ---
#
# # Раскомментируйте строку ниже и укажите свои пути для теста
# # Backup-FolderToZip -SourcePath "C:\Temp\MyImportantData" -DestinationPath "D:\Backups\Temp"
