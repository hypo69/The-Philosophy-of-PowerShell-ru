# Повний посібник з ExifTool та PowerShell

Щоразу, коли ви робите фотографію, ваша камера записує у файл не лише саме зображення, а й службову інформацію: модель камери та об'єктива, дату та час зйомки, витримку, діафрагму, ISO, GPS-координати. Ці дані називаються **EXIF (Exchangeable Image File Format)**.

Хоча PowerShell має вбудовані засоби для читання деяких метаданих, вони обмежені. Щоб отримати доступ до **всієї** інформації, потрібен спеціалізований інструмент. У цій статті я використовую **ExifTool**.

**ExifTool** — це безкоштовна, кросплатформна утиліта з відкритим вихідним кодом, написана Філом Харві. Вона є золотим стандартом для читання, запису та редагування метаданих у найрізноманітніших форматах файлів (зображення, аудіо, відео, PDF тощо). ExifTool знає тисячі тегів від сотень виробників пристроїв, що робить його найповнішим інструментом у своєму класі.

### Завантаження та правильне налаштування

Перш ніж писати код, потрібно підготувати саму утиліту.

1.  Зайдіть на **офіційний сайт ExifTool: [https://exiftool.org/](https://exiftool.org/)**. На головній сторінці знайдіть і завантажте **"Windows Executable"**.

2.  **Перейменування (Критично важливий крок!):** Завантажений файл називатиметься `exiftool(-k).exe`. Це не випадковість.

Перейменуйте його на **`exiftool.exe`**, щоб **вимкнути режим "паузи"**, який призначений для користувачів, що запускають програму подвійним клацанням миші.
>

3.  **Зберігання:** У вас є два основні варіанти, де зберігати `exiftool.exe`.
    *   **Варіант 1 (Простий): У тій самій папці, що й ваш скрипт.** Це найлегший шлях. Ваш скрипт PowerShell завжди зможе знайти утиліту, оскільки вона лежить поруч. Ідеально для портативних скриптів, які ви переносите з комп'ютера на комп'ютер.
    *   **Варіант 2 (Рекомендований для частого використання): У папці зі системної змінної `PATH`.** Змінна `PATH` — це список директорій, де Windows і PowerShell автоматично шукають виконувані файли.
    Ви можете створити папку (наприклад, `C:\Tools`), покласти туди `exiftool.exe` і додати `C:\Tools` до системної змінної `PATH`.
    Після цього ви зможете викликати `exiftool.exe` з будь-якої папки в будь-якій консолі.

Скрипти для додавання в $PATH:
Додавання директорії в PATH для ПОТОЧНОГО КОРИСТУВАЧА
Додавання директорії в СИСТЕМНИЙ PATH для ВСІХ КОРИСТУВАЧІВ

---

## PowerShell та зовнішні програми

Щоб ефективно використовувати ExifTool, потрібно знати, як PowerShell запускає зовнішні `.exe` файли.
Правильний і найнадійніший спосіб запуску зовнішніх програм — це **оператор виклику `&` (амперсанд)**.
PowerShell видасть помилку у випадку, якщо шлях до програми містить пробіли. Наприклад, `C:\My Tools\exiftool.exe`.
`&` (амперсанд)** говорить PowerShell: "Текст, який слідує за мною в лапках, — це шлях до виконуваного файлу. Запусти його, а все, що йде далі, — це його аргументи".

```powershell
# Правильний синтаксис
& "C:\Path With Spaces\program.exe" "аргумент 1" "аргумент 2"
```

Завжди використовуйте `&`, коли працюєте зі шляхами до програм у змінних або шляхами, які можуть містити пробіли.

---

## Практичні трюки: ExifTool + PowerShell

Тепер об'єднаємо наші знання.

### Приклад №1: Базове вилучення та інтерактивний перегляд

Найпростіший спосіб отримати всі дані з фото та вивчити їх — це запросити їх у форматі JSON та передати в `Out-ConsoleGridView`.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. Запускаємо exiftool з ключем -json для структурованого виводу
# 2. Перетворюємо JSON-текст на об'єкт PowerShell
#    Викликаємо exiftool.exe безпосередньо, без змінної та оператора виклику &.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 3. Перетворюємо "широкий" об'єкт на зручну таблицю "Параметр-Значення"
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 4. Виводимо результат в інтерактивне вікно для аналізу
$reportData | Out-ConsoleGridView -Title "Метадані файлу: $($photoPath | Split-Path -Leaf)"
```

Цей код відкриє інтерактивне вікно, де ви зможете відсортувати дані за іменем параметра або значенням, а також відфільтрувати їх, просто почавши вводити текст. Це неймовірно зручно для швидкого пошуку потрібної інформації.

### Приклад №2: Створення чистого звіту та відправка на різні "пристрої"

`Out-ConsoleGridView` — це лише початок. Ви можете направити оброблені дані куди завгодно, використовуючи інші командлети `Out-*`.

Припустимо, у нас є дані в змінній `$reportData` з попереднього прикладу.

#### **А) Відправка в CSV-файл для Excel**
```powershell
$reportData | Export-Csv -Path "C:\Reports\photo_exif.csv" -NoTypeInformation -Encoding UTF8
```
Команда `Export-Csv` створює ідеально структурований файл, який можна відкрити в Excel або Google Таблицях.

#### **Б) Відправка в текстовий файл**
```powershell
# Для красивого форматування спочатку використовуємо Format-Table
$reportData | Format-Table -AutoSize | Out-File -FilePath "C:\Reports\photo_exif.txt"
```
Команда `Out-File` збереже у файл точну текстову копію того, що ви бачите в консолі.

#### **В) Відправка в буфер обміну**
Хочете швидко вставити дані в лист або чат? Використовуйте `Out-Clipboard`.
```powershell
$reportData | Format-Table -AutoSize | Out-String | Out-Clipboard
```

Тепер ви можете натиснути `Ctrl+V` у будь-якому текстовому редакторі та вставити акуратно відформатовану таблицю.

### Приклад №3: Отримання конкретних даних для використання в скрипті

Часто вам не потрібен весь звіт, а лише одне або два значення. Оскільки `$exifObject` — це звичайний об'єкт PowerShell, ви можете легко звертатися до його властивостей.

```powershell

$photoPath = "D:\Photos\IMG_1234.JPG"

# Викликаємо exiftool.exe безпосередньо за іменем.
# PowerShell автоматично знайде його в одній з папок, перелічених у PATH.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 1. Створюємо один PowerShell-об'єкт зі зрозумілими іменами властивостей.
#    Це схоже на створення структурованого запису.
$reportObject = [PSCustomObject]@{
    "Камера"           = $exifObject.Model
    "Дата зйомки"      = $exifObject.DateTimeOriginal
    "Чутливість" = $exifObject.ISO
    "Ім'я файлу"        = $exifObject.FileName # Додамо ім'я файлу для контексту
}

# 2. Виводимо цей об'єкт в інтерактивне вікно.
#    Out-GridView автоматично створить колонки з імен властивостей.
$reportObject | Out-ConsoleGridView -Title "Метадані файлу: $(Split-Path $photoPath -Leaf)"
```

Цей підхід є основою для будь-якої серйозної автоматизації, такої як перейменування файлів на основі дати зйомки, сортування фотографій за моделлю камери або додавання водяних знаків з інформацією про витримку.

### Приклад №4: Пакетне вилучення метаданих з папки

Іноді потрібно проаналізувати не одне фото, а цілу папку із зображеннями.

```powershell
# Вказуємо лише папку з фотографіями.
$photoFolder = "D:\Photos"

# Викликаємо exiftool.exe безпосередньо. Змінна для шляху та оператор & не потрібні.
$allExif = exiftool.exe -json "$photoFolder\*.jpg" | ConvertFrom-Json

# Перетворюємо на зручний вигляд
$report = foreach ($photo in $allExif) {
    [PSCustomObject]@{
        # --- Основні дані про файл та камеру ---
        FileName       = $photo.FileName
        DateTime       = $photo.DateTimeOriginal
        CameraMake     = $photo.Make                 # Виробник (наприклад, "Canon", "SONY")
        CameraModel    = $photo.Model                 # Модель камери (наприклад, "EOS R5")
        LensModel      = $photo.LensID                # Повна назва моделі об'єктива

        # --- Параметри зйомки (експозиція) ---
        ISO            = $photo.ISO
        ShutterSpeed   = $photo.ShutterSpeed
        Aperture       = $photo.Aperture
        FocalLength    = $photo.FocalLength           # Фокусна відстань (наприклад, "50.0 mm")
        ExposureMode   = $photo.ExposureProgram       # Режим зйомки (наприклад, "Manual", "Aperture Priority")
        Flash          = $photo.Flash                 # Інформація про те, чи спрацював спалах

        # --- GPS та дані зображення ---
        GPSPosition    = $photo.GPSPosition           # Координати GPS у вигляді одного рядка (якщо є)
        Dimensions     = "$($photo.ImageWidth)x$($photo.ImageHeight)" # Розміри зображення в пікселях
    }
}

# Виводимо дані в інтерактивну таблицю в КОНСОЛІ
$report | Out-ConsoleGridView -Title "Зведений звіт по папці: $photoFolder"
```

💡 Ви отримуєте акуратну таблицю для всієї папки одразу.

---

### Приклад №5: Рекурсивний пошук по підпапках

ExifTool вміє сам шукати файли у всіх підпапках при використанні ключа `-r`.

```powershell
& $exifToolPath -r -json "D:\Photos" | ConvertFrom-Json |
    Select-Object FileName, Model, DateTimeOriginal |
    Export-Csv "C:\Reports\all_photos_recursive.csv" -NoTypeInformation -Encoding UTF8
```

---

### Приклад №6: Перейменування файлів за датою зйомки

Це один з найпопулярніших сценаріїв автоматизації — файли отримують імена за датою/часом зйомки.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# Перейменуємо у формат YYYY-MM-DD_HH-MM-SS.jpg
& $exifToolPath -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```

💡 *Ця дія незворотна, тому робіть резервну копію перед виконанням.*

---

### Приклад №7: Вилучення лише GPS-координат

Корисно, якщо ви хочете побудувати карту за вашими фото.

```powershell
# 1. Вкажіть шлях до папки з вашими фотографіями
$photoFolder = "E:\DCIM\Camera"

# 2. Перелічуємо теги, які нам потрібні: ім'я файлу та три GPS-теги.
#    Це робить запит набагато швидшим, ніж якби ми забирали всі теги.
$tagsToExtract = @(
    "-SourceFile", # SourceFile краще, ніж FileName, оскільки зазвичай містить повний шлях
    "-GPSLatitude",
    "-GPSLongitude",
    "-GPSAltitude"
)

# 3. Викликаємо exiftool.exe безпосередньо (оскільки він у PATH).
#    Ключ -r шукає файли у всіх підпапках.
#    Результат одразу конвертуємо з JSON.
$allExifData = exiftool.exe -r -json $tagsToExtract $photoFolder | ConvertFrom-Json

# 4. Фільтруємо результати: залишаємо ЛИШЕ ті об'єкти, у яких є широта та довгота.
$filesWithGps = $allExifData | Where-Object { $_.GPSLatitude -and $_.GPSLongitude }

# 5. Перевіряємо, чи знайшлися взагалі файли з GPS-даними
if ($filesWithGps) {
    # 6. Створюємо красивий звіт з відфільтрованих даних.
    #    Використовуємо Select-Object для перейменування колонок та форматування.
    $report = $filesWithGps | Select-Object @{Name="Ім'я файлу"; Expression={Split-Path $_.SourceFile -Leaf}},
                                             @{Name="Широта"; Expression={$_.GPSLatitude}},
                                             @{Name="Довгота"; Expression={$_.GPSLongitude}},
                                             @{Name="Висота"; Expression={if ($_.GPSAltitude) { "$($_.GPSAltitude) м" } else { "N/A" }}}

    # 7. Виводимо підсумковий звіт в інтерактивну консольну таблицю.
    $report | Out-ConsoleGridView -Title "Файли з GPS-даними в папці: $photoFolder"

} else {
    # Якщо нічого не знайдено, ввічливо повідомляємо про це.
    Write-Host "Файли з GPS-даними в папці '$photoFolder' не знайдені." -ForegroundColor Yellow
}
```

---

### Приклад №8: Масове видалення всіх GPS-даних (для приватності)

```powershell
# Видалимо всі GPS-теги з JPG та PNG
& $exifToolPath -r -overwrite_original -gps:all= "D:\Photos"
```

💡 *Ця дія незворотна, тому робіть резервну копію перед виконанням.*

---

### Приклад №9: Конвертація часу зйомки в місцевий час

Іноді фото зняті в іншому часовому поясі. ExifTool може змістити дату.

```powershell
# Зміщуємо час на +3 години
& $exifToolPath "-AllDates+=3:0:0" "D:\Photos\IMG_*.JPG"
```

---

### Приклад №10: Отримання списку всіх унікальних моделей камер у папці

```powershell
$models = & $exifToolPath -r -Model -s3 "D:\Photos" | Sort-Object -Unique
$models | ForEach-Object { Write-Host "Модель: $_" }
```

---

### Приклад №11: Виведення лише потрібних тегів у табличному вигляді

```powershell
& $exifToolPath -T -Model -DateTimeOriginal -ISO -Aperture -ShutterSpeed "D:\Photos\IMG_1234.JPG"
```

`-T` робить виведення в табличному форматі, розділеному табуляцією — зручно для подальшої обробки.

---

### Приклад №12: Перевірка наявності GPS у великому масиві файлів

```powershell
$files = & $exifToolPath -r -if "$gpslatitude" -p '$FileName' "D:\Photos"
Write-Host "Файли з GPS:"
$files
```

---

### Приклад №13: Копіювання метаданих з одного файлу на інший

```powershell
# 1. Вибираємо еталонний файл
$sourceFile = Get-ChildItem "D:\Photos" -Filter "*.jpg" | Out-ConsoleGridView -Title "Виберіть ЕТАЛОННИЙ файл"

# 2. Якщо еталон вибрано, вибираємо цільові файли
if ($sourceFile) {
    $targetFiles = Get-ChildItem "D:\Photos\New" -Filter "*.jpg" | Out-ConsoleGridView -Title "Виберіть ЦІЛЬОВІ файли для копіювання метаданих" -OutputMode Multiple

    # 3. Якщо цілі вибрано, виконуємо копіювання
    if ($targetFiles) {
        & exiftool.exe -TagsFromFile $sourceFile.FullName ($targetFiles.FullName)
        Write-Host "Метадані скопійовано з $($sourceFile.Name) на $($targetFiles.Count) файлів."
    }
}
```

---

### Приклад №14: Збереження вихідних метаданих в окремий JSON перед зміною

```powershell
$backupPath = "C:\Reports\metadata_backup.json"
& $exifToolPath -r -json "D:\Photos" | Out-File -Encoding UTF8 $backupPath
```

---

### Приклад №15: Використання PowerShell для автоматичної сортування фото за датою

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

### Приклад 16: Пошук усіх унікальних моделей камер у колекції

Хоча це можна зробити одним рядком, виведення в `GridView` дозволяє одразу скопіювати потрібну назву моделі.

```powershell
# Ключ -s3 виводить лише значення, -Model - назву тега
$uniqueModels = & exiftool.exe -r -Model -s3 "D:\Photos" | Sort-Object -Unique

# Виводимо в GridView для зручного перегляду та копіювання
$uniqueModels | Out-ConsoleGridView -Title "Унікальні моделі камер у колекції"
```