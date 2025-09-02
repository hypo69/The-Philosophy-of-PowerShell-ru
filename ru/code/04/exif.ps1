#requires -Version 5.1
#requires -RunAsAdministrator

# =================================================================================
# Discover-AllExifData.ps1 — Скрипт для обнаружения ВСЕХ метаданных в фото
# PowerShell >= 5.1 (на Windows).
# Не требует сторонних утилит.
# Автор: hypo69 (адаптировано Gemini для глубокого анализа)
# Дата создания: 07/08/2025
# =================================================================================

<#
.SYNOPSIS
    Обнаруживает и отображает ВСЕ доступные метаданные из файла изображения, используя только встроенные средства .NET.
.DESCRIPTION
    Скрипт не использует предопределенный список свойств. Вместо этого он читает полный список
    EXIF-тегов, присутствующих в конкретном файле, и пытается расшифровать их значения.
    Результат выводится в интерактивное окно Out-ConsoleGridView для детального изучения.
.PARAMETER PhotoPath
    Необязательный начальный путь к файлу фотографии. Если не указан или неверен, скрипт запросит его.
.EXAMPLE
    .\Discover-AllExifData.ps1
    # Скрипт запросит путь и покажет все найденные метаданные в интерактивном окне.

.EXAMPLE
    .\Discover-AllExifData.ps1 -PhotoPath "C:\Photos\pro_photo.cr2"
#>
param(
    [Parameter(Mandatory = $false, HelpMessage = "Начальный путь к файлу фотографии.")]
    [string]$PhotoPath
)

# --- Блок проверки пути и повторного запроса ---
$PhotoPath = $PhotoPath.Trim().Trim('"')
while (-not (Test-Path -Path $PhotoPath -PathType Leaf)) {
    if (-not [string]::IsNullOrEmpty($PhotoPath)) {
        Write-Warning "Файл не найден по пути: '$PhotoPath'"
    }
    $PhotoPath = Read-Host "➡️ Введите полный путь к файлу фотографии (или 'q' для выхода)"
    if ($PhotoPath -eq 'q') {
        Write-Host "Выход из скрипта." -ForegroundColor Yellow
        return
    }
    $PhotoPath = $PhotoPath.Trim().Trim('"')
}
Write-Host "✅ Файл найден. Начинаю глубокий анализ метаданных..." -ForegroundColor Green
Write-Host "   -> $PhotoPath`n"


# --- Начало основного блока скрипта ---
$image = $null # Инициализируем переменную для блока finally
try {
    # 1. Загружаем сборку .NET для работы с изображениями
    Add-Type -AssemblyName System.Drawing

    # 2. Словарь для расшифровки кодов EXIF-тегов в понятные имена.
    # Это лишь малая часть, но покрывает самое основное.
    $exifTagNames = @{
        0x010F = "Производитель"; 0x0110 = "Модель камеры"; 0x8769 = "Exif IFD";
        0x9000 = "Версия Exif";   0x9003 = "Дата/время съемки"; 0x9004 = "Дата/время создания";
        0x920A = "Фокусное расстояние"; 0x829A = "Выдержка"; 0x829D = "Диафрагма (F-число)";
        0x8827 = "Чувствительность ISO"; 0xA405 = "Объектив"; 0x0132 = "Дата изменения ПО";
        0x010E = "Описание изображения"; 0x013B = "Автор"; 0x828D = "CFAPattern"
    }

    # 3. Загружаем изображение в память. ВНИМАНИЕ: Это блокирует файл!
    $image = [System.Drawing.Bitmap]::new($PhotoPath)

    # 4. Получаем СПИСОК ВСЕХ ID свойств, которые есть в этом файле
    $propertyIdList = $image.PropertyIdList

    Write-Host "Обнаружено $($propertyIdList.Count) тегов метаданных. Расшифровываю..."
    
    # 5. Перебираем каждый найденный тег и извлекаем информацию
    $allExifData = foreach ($id in $propertyIdList) {
        $propertyItem = $image.GetPropertyItem($id)
        
        # Пытаемся декодировать значение в зависимости от его типа
        $decodedValue = switch ($propertyItem.Type) {
            1 { $propertyItem.Value } # Byte
            2 { [System.Text.Encoding]::ASCII.GetString($propertyItem.Value).TrimEnd("`0") } # ASCII String
            3 { [System.BitConverter]::ToUInt16($propertyItem.Value, 0) } # Short (16-bit)
            4 { [System.BitConverter]::ToUInt32($propertyItem.Value, 0) } # Long (32-bit)
            5 { # Rational (дробное, например выдержка)
                $numerator = [System.BitConverter]::ToUInt32($propertyItem.Value, 0)
                $denominator = [System.BitConverter]::ToUInt32($propertyItem.Value, 4)
                if ($denominator -ne 0) { "$numerator/$denominator" } else { "N/A" }
            }
            default { "Неподдерживаемый тип $($propertyItem.Type)" }
        }

        # Создаем объект с полной информацией
        [PSCustomObject]@{
            'ID (Hex)'     = "0x{0:X4}" -f $id
            'Имя тега'     = $exifTagNames[$id] # Если имени нет в словаре, будет пусто
            'Значение'     = $decodedValue
            'Тип данных'   = $propertyItem.Type
            'Длина (байт)' = $propertyItem.Len
        }
    }

    # 6. Выводим все найденные данные в интерактивное окно
    $windowTitle = "Все метаданные файла: $(Split-Path -Leaf $PhotoPath)"
    $allExifData | Out-ConsoleGridView -Title $windowTitle

}
catch {
    Write-Error "Произошла критическая ошибка: $($_.Exception.Message)"
}
finally {
    # 7. КРИТИЧЕСКИ ВАЖНО: Освобождаем файл, даже если была ошибка!
    if ($null -ne $image) {
        $image.Dispose()
    }
}
# --- Конец основного блока скрипта ---