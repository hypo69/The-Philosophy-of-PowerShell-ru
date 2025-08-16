

# Полное руководство по ExifTool и PowerShell

Каждый раз, когда вы делаете фотографию, ваша камера записывает в файл не только само изображение, но и служебную информацию: модель камеры и объектива, дату и время съемки, выдержку, диафрагму, 
ISO, GPS-координаты. Эти данные называются **EXIF (Exchangeable Image File Format)**.

Хотя PowerShell имеет встроенные средства для чтения некоторых метаданных, они ограничены. Чтобы получить доступ ко **всей** информации, нужен специализированный инструмент. 
В этой статье я использую **ExifTool**.


**ExifTool** — это бесплатная, кросс-платформенная утилита с открытым исходным кодом, написанная Филом Харви. Она является золотым стандартом для чтения, записи и редактирования метаданных в самых разных форматах файлов (изображения, аудио, видео, PDF и др.). ExifTool знает тысячи тегов от сотен производителей устройств, что делает его самым всеобъемлющим инструментом в своем классе.

### Скачивание и правильная настройка

Прежде чем писать код, нужно подготовить саму утилиту.

1.  Зайдите на **официальный сайт ExifTool: [https://exiftool.org/](https://exiftool.org/)**. На главной странице найдите и скачайте **"Windows Executable"**.

2.  **Переименование (Критически важный шаг!):** Скачанный файл будет называться `exiftool(-k).exe`. Это не случайность.

Переименуйте его в  **`exiftool.exe`**, чтобы **отключить режим "паузы"**, который предназначен для пользователей, запускающих программу двойным щелчком мыши.
>

3.  **Хранение:** У вас есть два основных варианта, где хранить `exiftool.exe`. 
    *   **Вариант 1 (Простой): В той же папке, что и ваш скрипт.** Это самый легкий путь. Ваш скрипт PowerShell всегда сможет найти утилиту, так как она лежит рядом. Идеально для портативных скриптов, которые вы переносите с компьютера на компьютер.
    *   **Вариант 2 (Рекомендуемый для частого использования): В папке из системной переменной `PATH`.** Переменная `PATH` — это список директорий, где Windows и PowerShell автоматически ищут исполняемые файлы. 
    Вы можете создать папку (например, `C:\Tools`), положить туда `exiftool.exe` и добавить `C:\Tools` в системную переменную `PATH`. 
    После этого вы сможете вызывать `exiftool.exe` из любой папки в любой консоли.


Скрипты для добавления в $PATH: 
Добавление директории в PATH для ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ 
Добавление директории в СИСТЕМНЫЙ PATH для ВСЕХ ПОЛЬЗОВАТЕЛЕЙ

---

## PowerShell и внешние программы

Чтобы эффективно использовать ExifTool, нужно знать, как PowerShell запускает внешние `.exe` файлы.
Правильный и самый надежный способ запуска внешних программ — это **оператор вызова `&` (амперсанд)**.
PowerShell выдаст ошибку в случае, если путь к программе содержит пробелы. Например, `C:\My Tools\exiftool.exe`. 
`&` (амперсанд)** говорит PowerShell: "Текст, который следует за мной в кавычках, — это путь к исполняемому файлу. Запусти его, а всё, что идет дальше, — это его аргументы".

```powershell
# Правильный синтаксис
& "C:\Path With Spaces\program.exe" "аргумент 1" "аргумент 2"
```

Всегда используйте `&`, когда работаете с путями к программам в переменных или путями, которые могут содержать пробелы.

---

## Практические трюки: ExifTool + PowerShell

Теперь объединим наши знания.

### Пример №1: Базовое извлечение и интерактивный просмотр

Самый простой способ получить все данные из фото и изучить их — это запросить их в формате JSON и передать в `Out-ConsoleGridView`.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. Запускаем exiftool с ключом -json для структурированного вывода
# 2. Преобразуем JSON-текст в объект PowerShell
#    Вызываем exiftool.exe напрямую, без переменной и оператора вызова &.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 3. Превращаем "широкий" объект в удобную таблицу "Параметр-Значение"
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 4. Выводим результат в интерактивное окно для анализа
$reportData | Out-ConsoleGridView -Title "Метаданные файла: $($photoPath | Split-Path -Leaf)"
```

Этот код откроет интерактивное окно, где вы сможете отсортировать данные по имени параметра или значению, а также отфильтровать их, просто начав вводить текст. Это невероятно удобно для быстрого поиска нужной информации.

### Пример №2: Создание чистого отчета и отправка на разные "устройства"

`Out-ConsoleGridView` — это только начало. Вы можете направить обработанные данные куда угодно, используя другие командлеты `Out-*`.

Предположим, у нас есть данные в переменной `$reportData` из предыдущего примера.

#### **А) Отправка в CSV-файл для Excel**
```powershell
$reportData | Export-Csv -Path "C:\Reports\photo_exif.csv" -NoTypeInformation -Encoding UTF8
```
Команда `Export-Csv` создает идеально структурированный файл, который можно открыть в Excel или Google Таблицах.

#### **Б) Отправка в текстовый файл**
```powershell
# Для красивого форматирования сначала используем Format-Table
$reportData | Format-Table -AutoSize | Out-File -FilePath "C:\Reports\photo_exif.txt"
```
Команда `Out-File` сохранит в файл точную текстовую копию того, что вы видите в консоли.

#### **В) Отправка в буфер обмена**
Хотите быстро вставить данные в письмо или чат? Используйте `Out-Clipboard`.
```powershell
$reportData | Format-Table -AutoSize | Out-String | Out-Clipboard
```

Теперь вы можете нажать `Ctrl+V` в любом текстовом редакторе и вставить аккуратно отформатированную таблицу.

### Пример №3: Получение конкретных данных для использования в скрипте

Часто вам не нужен весь отчет, а лишь одно или два значения. Поскольку `$exifObject` — это обычный объект PowerShell, вы можете легко обращаться к его свойствам.

```powershell
# Получаем данные, как и раньше
$exifToolPath = "C:\Tools\exiftool.exe"
$photoPath = "D:\Photos\IMG_1234.JPG"
$exifObject = & $exifToolPath -json $photoPath | ConvertFrom-Json

# Извлекаем конкретные свойства
$cameraModel = $exifObject.Model
$dateTime = $exifObject.DateTimeOriginal
$iso = $exifObject.ISO

# Используем их в скрипте
Write-Host "Фотография была сделана на камеру $cameraModel"
Write-Host "Дата съемки: $dateTime"
Write-Host "Чувствительность ISO: $iso"
```

Этот подход является основой для любой серьезной автоматизации, такой как переименование файлов на основе даты съемки, сортировка фотографий по модели камеры или добавление водяных знаков с информацией о выдержке.

### Пример №4: Пакетное извлечение метаданных из папки

Иногда нужно проанализировать не одно фото, а целую папку с изображениями.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# Получаем метаданные для всех JPG в папке (без рекурсии)
$allExif = & $exifToolPath -json "$photoFolder\*.jpg" | ConvertFrom-Json

# Превращаем в удобный вид и сохраняем в CSV
$report = foreach ($photo in $allExif) {
    [PSCustomObject]@{
        FileName       = $photo.FileName
        DateTime       = $photo.DateTimeOriginal
        CameraModel    = $photo.Model
        ISO            = $photo.ISO
        ShutterSpeed   = $photo.ShutterSpeed
        Aperture       = $photo.Aperture
    }
}

$report | Export-Csv "C:\Reports\photos_summary.csv" -NoTypeInformation -Encoding UTF8
```

💡 Вы получаете аккуратную таблицу для всей папки сразу.

---

### Пример №5: Рекурсивный поиск по подпапкам

ExifTool умеет сам искать файлы во всех подпапках при использовании ключа `-r`.

```powershell
& $exifToolPath -r -json "D:\Photos" | ConvertFrom-Json |
    Select-Object FileName, Model, DateTimeOriginal |
    Export-Csv "C:\Reports\all_photos_recursive.csv" -NoTypeInformation -Encoding UTF8
```

---

### Пример №6: Переименование файлов по дате съемки

Это один из самых популярных сценариев автоматизации — файлы получают имена по дате/времени съемки.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# Переименуем в формат YYYY-MM-DD_HH-MM-SS.jpg
& $exifToolPath -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```

💡 *ExifTool подставит расширение исходного файла автоматически через `%%e`.*

---

### Пример №7: Извлечение только GPS-координат

Полезно, если вы хотите построить карту по вашим фото.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"
$gpsData = & $exifToolPath -json -GPSLatitude -GPSLongitude -GPSAltitude $photoPath | ConvertFrom-Json

if ($gpsData.GPSLatitude -and $gpsData.GPSLongitude) {
    Write-Host "Широта: $($gpsData.GPSLatitude)"
    Write-Host "Долгота: $($gpsData.GPSLongitude)"
    Write-Host "Высота: $($gpsData.GPSAltitude) м"
} else {
    Write-Host "GPS-данные отсутствуют"
}
```

---

### Пример №8: Массовое удаление всех GPS-данных (для приватности)

```powershell
# Удалим все GPS-теги из JPG и PNG
& $exifToolPath -r -overwrite_original -gps:all= "D:\Photos"
```

💡 *Это действие необратимо, поэтому делайте бэкап перед выполнением.*

---

### Пример №9: Конвертация времени съемки в местное время

Иногда фото сняты в другом часовом поясе. ExifTool может сместить дату.

```powershell
# Смещаем время на +3 часа
& $exifToolPath "-AllDates+=3:0:0" "D:\Photos\IMG_*.JPG"
```

---

### Пример №10: Получение списка всех уникальных моделей камер в папке

```powershell
$models = & $exifToolPath -r -Model -s3 "D:\Photos" | Sort-Object -Unique
$models | ForEach-Object { Write-Host "Модель: $_" }
```

---

### Пример №11: Вывод только нужных тегов в табличном виде

```powershell
& $exifToolPath -T -Model -DateTimeOriginal -ISO -Aperture -ShutterSpeed "D:\Photos\IMG_1234.JPG"
```

`-T` делает вывод в табличном формате, разделённом табуляцией — удобно для дальнейшей обработки.

---

### Пример №12: Проверка наличия GPS в большом массиве файлов

```powershell
$files = & $exifToolPath -r -if "$gpslatitude" -p '$FileName' "D:\Photos"
Write-Host "Файлы с GPS:"
$files
```

---

### Пример №13: Копирование метаданных с одного файла на другой

```powershell
& $exifToolPath -TagsFromFile "source.jpg" "target.jpg"
```

---

### Пример №14: Сохранение исходных метаданных в отдельный JSON перед изменением

```powershell
$backupPath = "C:\Reports\metadata_backup.json"
& $exifToolPath -r -json "D:\Photos" | Out-File -Encoding UTF8 $backupPath
```

---

### Пример №15: Использование PowerShell для автоматической сортировки фото по дате

```powershell
$photos = Get-ChildItem "D:\Photos" -Filter *.jpg -Recurse
foreach ($photo in $photos) {
    $meta = & $exifToolPath -json $photo.FullName | ConvertFrom-Json
    $date = Get-Date $meta.DateTimeOriginal -ErrorAction SilentlyContinue
    if ($date) {
        $targetFolder = "D:\Sorted\{0:yyyy}\{0:MM}" -f $date
        if (-not (Test-Path $targetFolder)) { New-Item -Path $targetFolder -ItemType Directory }
        Move-Item $photo.FullName -Destination $targetFolder
    }
}
```

---

## Часть 3: Практические трюки: ExifTool + PowerShell

Вот коллекция "рецептов" для решения самых частых задач. Мы будем использовать `Out-ConsoleGridView` там, где он приносит максимальную пользу (для анализа и выбора), а другие примеры, ориентированные на прямое действие, оставим в их оригинальном, эффективном виде.

### Пример 1: Интерактивный обозреватель метаданных для одного файла

Самый простой способ получить все данные из фото и изучить их — это запросить их в формате JSON и передать в `Out-ConsoleGridView`.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. Получаем все метаданные в виде объекта
$exifObject = & exiftool.exe -json $photoPath | ConvertFrom-Json

# 2. Превращаем в удобную таблицу "Параметр-Значение"
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 3. Выводим результат в интерактивное окно для анализа
$reportData | Out-ConsoleGridView -Title "Метаданные: $($photoPath | Split-Path -Leaf)"
```

### Пример 2: Создание сводного отчета по целой папке

Часто нужен не полный отчет по каждому файлу, а краткая сводка по основным параметрам для всей папки.

```powershell
$photoFolder = "D:\Photos"

# 1. Получаем метаданные для всех JPG в папке (без рекурсии)
$allExif = & exiftool.exe -json -FileName -Model -DateTimeOriginal -ISO -LensID "$photoFolder\*.jpg" | ConvertFrom-Json

# 2. Выводим сводную таблицу в интерактивное окно
$allExif | Out-ConsoleGridView -Title "Сводный отчет по папке: $photoFolder"
```
**Дополнительно:** Вы можете выбрать в этом окне несколько строк и сохранить их в CSV:
```powershell
$selectedPhotos = $allExif | Out-ConsoleGridView -Title "Выберите фото для сохранения в CSV" -OutputMode Multiple
if ($selectedPhotos) {
    $selectedPhotos | Export-Csv "C:\Reports\selected_photos.csv" -NoTypeInformation
}
```

### Пример 3: Пакетное переименование файлов по дате съемки

Это задача для прямого действия, где интерактивность не нужна. ExifTool отлично справляется с ней самостоятельно.

```powershell
$photoFolder = "D:\PhotosToRename"

# Переименовать все файлы в папке в формат YYYY-MM-DD_HH-MM-SS.jpg
# Ключ -d форматирует дату, "-FileName<DateTimeOriginal" выполняет переименование
& exiftool.exe -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```
💡 *ExifTool подставит расширение исходного файла автоматически через `%%e`.*

### Пример 4: Интерактивный выбор фото для удаления GPS-данных

Прежде чем выполнять необратимое действие, такое как удаление метаданных, лучше предоставить пользователю выбор.

```powershell
# 1. Сначала найдем все файлы, у которых есть GPS-данные
Write-Host "Идет поиск файлов с GPS-координатами..."
$filesWithGps = & exiftool.exe -r -if "$gpslatitude" -json -FileName -Model "D:\Photos" | ConvertFrom-Json

# 2. Если такие файлы найдены, даем пользователю выбрать, какие из них очистить
if ($filesWithGps) {
    $filesToClean = $filesWithGps | Out-ConsoleGridView -Title "Выберите фото для УДАЛЕНИЯ GPS-данных" -OutputMode Multiple
    
    # 3. Если что-то выбрано, выполняем действие с подтверждением
    if ($filesToClean) {
        # -overwrite_original -gps:all= удаляет все теги из группы GPS
        & exiftool.exe -overwrite_original -gps:all= ($filesToClean.SourceFile)
        Write-Host "GPS-данные удалены из $($filesToClean.Count) файлов." -ForegroundColor Green
    }
} else {
    Write-Host "Файлы с GPS-данными не найдены."
}
```
💡 *Действие `-overwrite_original` необратимо. Всегда делайте резервные копии.*

### Пример 5: Копирование метаданных с одного файла на другие

Представьте, у вас есть "эталонный" файл с правильными метаданными (например, автор, копирайт), и вы хотите скопировать их на другие фото.

```powershell
# 1. Выбираем эталонный файл
$sourceFile = Get-ChildItem "D:\Photos" -Filter "*.jpg" | Out-ConsoleGridView -Title "Выберите ЭТАЛОННЫЙ файл"

# 2. Если эталон выбран, выбираем целевые файлы
if ($sourceFile) {
    $targetFiles = Get-ChildItem "D:\Photos\New" -Filter "*.jpg" | Out-ConsoleGridView -Title "Выберите ЦЕЛЕВЫЕ файлы для копирования метаданных" -OutputMode Multiple
    
    # 3. Если цели выбраны, выполняем копирование
    if ($targetFiles) {
        & exiftool.exe -TagsFromFile $sourceFile.FullName ($targetFiles.FullName)
        Write-Host "Метаданные скопированы с $($sourceFile.Name) на $($targetFiles.Count) файлов."
    }
}
```

### Пример 6: Поиск всех уникальных моделей камер в коллекции

Хотя это можно сделать одной строкой, вывод в `GridView` позволяет сразу скопировать нужное название модели.

```powershell
# Ключ -s3 выводит только значения, -Model - название тега
$uniqueModels = & exiftool.exe -r -Model -s3 "D:\Photos" | Sort-Object -Unique

# Выводим в GridView для удобного просмотра и копирования
$uniqueModels | Out-ConsoleGridView -Title "Уникальные модели камер в коллекции"
```