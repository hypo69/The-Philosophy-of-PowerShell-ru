# =================================================================================
# Find-DuplicateFiles.ps1 — Функция для поиска дубликатов файлов
# Windows PowerShell >= 5.1.
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

function Find-DuplicateFiles {
<#
.SYNOPSIS
    Находит файлы-дубликаты в указанной директории на основе имени и размера.

.DESCRIPTION
    Функция рекурсивно сканирует указанную директорию и группирует файлы по их имени и размеру.
    В качестве дубликатов выводятся группы, содержащие более одного файла.

    ВАЖНО: Этот метод не сравнивает хэш-суммы файлов, поэтому файлы с одинаковым именем и
    размером, но разным содержимым, могут быть ошибочно помечены как дубликаты.
    Это быстрый метод для предварительного поиска, а не для гарантированного удаления.

.PARAMETER Path
    Путь к корневой директории для поиска дубликатов.

.EXAMPLE
    Find-DuplicateFiles -Path "C:\Users\User\Downloads"
    
    Эта команда выполнит поиск потенциальных дубликатов во всех подпапках директории "Downloads".

.OUTPUTS
    Выводит в консоль группы объектов System.IO.FileInfo.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = "Укажите путь к директории для поиска дубликатов.")]
        [string]$Path
    )

    Write-Verbose "Начинаю рекурсивный поиск файлов в '$Path'..."
    
    # Основная логика в виде конвейера:
    Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue | 
        # Шаг 1: Группируем все файлы по двум критериям - Имя и Размер (Длина)
        Group-Object Name, Length | 
        # Шаг 2: Отбираем только те группы, в которых больше одного файла (т.е. есть дубликаты)
        Where-Object { $_.Count -gt 1 } | 
        # Шаг 3: Проходим по каждой группе дубликатов для красивого вывода
        ForEach-Object {
            # Выводим заголовок для группы найденных дубликатов
            Write-Host "`nНайдены дубликаты для файла '$($_.Name)' (Размер: $($_.Group[0].Length) байт):" -ForegroundColor Yellow
            # Выводим подробную информацию о каждом файле в группе
            $_.Group | Select-Object FullName, Length, LastWriteTime
        }
}

# --- ПРИМЕР ИСПОЛЬЗОВАНИЯ ---
#
# # Раскомментируйте строку ниже и укажите свой путь для теста
# # Find-DuplicateFiles -Path "C:\Temp"