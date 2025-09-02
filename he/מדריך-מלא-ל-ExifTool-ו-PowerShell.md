# מדריך מלא ל-ExifTool ו-PowerShell

בכל פעם שאתם מצלמים תמונה, המצלמה שלכם רושמת לקובץ לא רק את התמונה עצמה, אלא גם מידע שירות: דגם המצלמה והעדשה, תאריך ושעת הצילום, מהירות תריס, צמצם, ISO, קואורדינטות GPS. נתונים אלו נקראים **EXIF (Exchangeable Image File Format)**.

אף של-PowerShell יש כלים מובנים לקריאת חלק מהמטא-נתונים, הם מוגבלים. כדי לגשת ל**כל** המידע, נדרש כלי מיוחד. במאמר זה אשתמש ב-**ExifTool**.

**ExifTool** הוא כלי עזר חינמי, חוצה פלטפורמות, בקוד פתוח, שנכתב על ידי פיל הארווי. הוא נחשב לסטנדרט הזהב לקריאה, כתיבה ועריכה של מטא-נתונים במגוון רחב של פורמטים (תמונות, אודיו, וידאו, PDF ועוד). ExifTool מכיר אלפי תגים ממאות יצרני מכשירים, מה שהופך אותו לכלי המקיף ביותר בקטגוריה שלו.

### הורדה והגדרה נכונה

לפני כתיבת קוד כלשהו, יש להכין את כלי העזר עצמו.

1.  היכנסו ל**אתר הרשמי של ExifTool: [https://exiftool.org/](https://exiftool.org/)**. בעמוד הראשי, מצאו והורידו את **"Windows Executable"**.

2.  **שינוי שם (שלב קריטי!):** הקובץ שהורדתם ייקרא `exiftool(-k).exe`. זו לא מקריות.

    שנו את שמו ל-**`exiftool.exe`**, כדי **לבטל את מצב ה"השהיה"**, המיועד למשתמשים המפעילים את התוכנה בלחיצה כפולה.

3.  **אחסון:** יש לכם שתי אפשרויות עיקריות היכן לאחסן את `exiftool.exe`.
    *   **אפשרות 1 (פשוטה): באותה תיקיה כמו הסקריפט שלכם.** זו הדרך הקלה ביותר. סקריפט ה-PowerShell שלכם תמיד יוכל למצוא את כלי העזר, מכיוון שהוא נמצא בסמוך. אידיאלי לסקריפטים ניידים שאתם מעבירים ממחשב למחשב.
    *   **אפשרות 2 (מומלצת לשימוש תכוף): בתיקיה מתוך משתנה המערכת `PATH`.** משתנה `PATH` הוא רשימת ספריות שבהן Windows ו-PowerShell מחפשים אוטומטית קבצי הפעלה.
        אתם יכולים ליצור תיקיה (לדוגמה, `C:\Tools`), לשים בה את `exiftool.exe` ולהוסיף את `C:\Tools` למשתנה המערכת `PATH`.
        לאחר מכן תוכלו להפעיל את `exiftool.exe` מכל תיקיה בכל קונסולה.

סקריפטים להוספה ל-`$PATH`:
הוספת ספרייה ל-`PATH` עבור המשתמש הנוכחי
הוספת ספרייה ל-`PATH` המערכתי עבור כל המשתמשים

--- 

## PowerShell ותוכניות חיצוניות

כדי להשתמש ב-ExifTool ביעילות, יש לדעת כיצד PowerShell מפעיל קבצי `.exe` חיצוניים.
הדרך הנכונה והאמינה ביותר להפעלת תוכניות חיצוניות היא **אופרטור הקריאה `&` (אמפרסנד)**.
PowerShell יחזיר שגיאה במקרה שנתיב התוכנית מכיל רווחים. לדוגמה, `C:\My Tools\exiftool.exe`.
`&` (אמפרסנד) אומר ל-PowerShell: "הטקסט שאחרי בגרשיים, – זהו הנתיב לקובץ ההפעלה. הפעל אותו, וכל מה שאחריו, – אלו הארגומנטים שלו".

```powershell
# תחביר נכון
& "C:\Path With Spaces\program.exe" "argument 1" "argument 2"
```

תמיד השתמשו ב-`&`, כאשר אתם עובדים עם נתיבים לתוכניות במשתנים או נתיבים שעשויים להכיל רווחים.

--- 

## טריקים מעשיים: ExifTool + PowerShell

כעת נשלב את הידע שלנו.

### דוגמה מס' 1: חילוץ בסיסי וצפייה אינטראקטיבית

הדרך הפשוטה ביותר לקבל את כל הנתונים מתמונה ולבחון אותם – היא לבקש אותם בפורמט JSON ולהעביר אותם ל-`Out-ConsoleGridView`.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. מפעילים את exiftool עם המתג -json לפלט מובנה
# 2. ממירים את טקסט ה-JSON לאובייקט PowerShell
#    מפעילים את exiftool.exe ישירות, ללא משתנה ואופרטור קריאה &.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 3. הופכים את האובייקט ה"רחב" לטבלת "פרמטר-ערך" נוחה
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 4. מציגים את התוצאה בחלון אינטראקטיבי לניתוח
$reportData | Out-ConsoleGridView -Title "מטא-נתונים של קובץ: $($photoPath | Split-Path -Leaf)"
```

קוד זה יפתח חלון אינטראקטיבי שבו תוכלו למיין נתונים לפי שם פרמטר או ערך, ולסנן אותם, פשוט על ידי התחלת הקלדת טקסט. זה נוח להפליא למציאת מידע נחוץ במהירות.

### דוגמה מס' 2: יצירת דוח נקי ושליחה ל"התקנים" שונים

`Out-ConsoleGridView` – זו רק ההתחלה. אתם יכולים להפנות נתונים מעובדים לכל מקום, באמצעות פקודות `Out-*` אחרות.

נניח שיש לנו נתונים במשתנה `$reportData` מהדוגמה הקודמת.

#### **א) שליחה לקובץ CSV עבור Excel**
```powershell
$reportData | Export-Csv -Path "C:\Reports\photo_exif.csv" -NoTypeInformation -Encoding UTF8
```
הפקודה `Export-Csv` יוצרת קובץ מובנה באופן מושלם שניתן לפתוח ב-Excel או ב-Google Sheets.

#### **ב) שליחה לקובץ טקסט**
```powershell
# לעיצוב יפה, השתמשו תחילה ב-Format-Table
$reportData | Format-Table -AutoSize | Out-File -FilePath "C:\Reports\photo_exif.txt"
```
הפקודה `Out-File` תשמור לקובץ עותק טקסט מדויק של מה שאתם רואים בקונסולה.

#### **ג) שליחה ללוח הגזירים**
רוצים להדביק נתונים במהירות למייל או לצ'אט? השתמשו ב-`Out-Clipboard`.
```powershell
$reportData | Format-Table -AutoSize | Out-String | Out-Clipboard
```

כעת תוכלו ללחוץ `Ctrl+V` בכל עורך טקסט ולהדביק טבלה מעוצבת בקפידה.

### דוגמה מס' 3: קבלת נתונים ספציפיים לשימוש בסקריפט

לעתים קרובות אינכם זקוקים לכל הדוח, אלא רק לערך אחד או שניים. מכיוון ש-`$exifObject` – זהו אובייקט PowerShell רגיל, תוכלו לגשת בקלות למאפייניו.

```powershell


$photoPath = "D:\Photos\IMG_1234.JPG"

# מפעילים את exiftool.exe ישירות לפי שם.
# PowerShell ימצא אותו אוטומטית באחת מהתיקיות, המפורטות ב-PATH.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 1. יוצרים אובייקט PowerShell אחד עם שמות מאפיינים מובנים.
#    זה דומה ליצירת רשומה מובנית.
$reportObject = [PSCustomObject]@{ 
    "מצלמה"           = $exifObject.Model
    "תאריך צילום"      = $exifObject.DateTimeOriginal
    "רגישות" = $exifObject.ISO
    "שם קובץ"        = $exifObject.FileName # נוסיף את שם הקובץ להקשר
}

# 2. מציגים את האובייקט הזה בחלון אינטראקטיבי.
#    Out-GridView תיצור אוטומטית עמודות משמות המאפיינים.
$reportObject | Out-ConsoleGridView -Title "מטא-נתונים של קובץ: $(Split-Path $photoPath -Leaf)"
```

גישה זו היא הבסיס לכל אוטומציה רצינית, כגון שינוי שמות קבצים על בסיס תאריך הצילום, מיון תמונות לפי דגם מצלמה או הוספת סימני מים עם מידע על חשיפה.

### דוגמה מס' 4: חילוץ אצווה של מטא-נתונים מתיקיה

לפעמים צריך לנתח לא תמונה אחת, אלא תיקיה שלמה עם תמונות.

```powershell
# מציינים רק את תיקיית התמונות.
$photoFolder = "D:\Photos"

# מפעילים את exiftool.exe ישירות.
$allExif = exiftool.exe -json "$photoFolder\*.jpg" | ConvertFrom-Json

# הופכים לתצוגה נוחה 
$report = foreach ($photo in $allExif) {
    [PSCustomObject]@{
        # --- נתונים בסיסיים על הקובץ והמצלמה ---
        FileName       = $photo.FileName
        DateTime       = $photo.DateTimeOriginal
        CameraMake     = $photo.Make                 # יצרן (לדוגמה, "Canon", "SONY")
        CameraModel    = $photo.Model                 # דגם מצלמה (לדוגמה, "EOS R5")
        LensModel      = $photo.LensID                # שם מלא של דגם העדשה
        
        # --- פרמטרי צילום (חשיפה) ---
        ISO            = $photo.ISO
        ShutterSpeed   = $photo.ShutterSpeed
        Aperture       = $photo.Aperture
        FocalLength    = $photo.FocalLength           # אורך מוקד (לדוגמה, "50.0 mm")
        ExposureMode   = $photo.ExposureProgram       # מצב צילום (לדוגמה, "Manual", "Aperture Priority")
        Flash          = $photo.Flash                 # מידע האם הפלאש הופעל
        
        # --- GPS ונתוני תמונה ---
        GPSPosition    = $photo.GPSPosition           # קואורדינטות GPS כמחרוזת אחת (אם קיימות)
        Dimensions     = "$($photo.ImageWidth)x$($photo.ImageHeight)" # מימדי תמונה בפיקסלים
    }
}

# מציגים נתונים בטבלה אינטראקטיבית בקונסולה
$report | Out-ConsoleGridView -Title "דוח סיכום לתיקיה: $photoFolder"
```

💡 אתם מקבלים טבלה מסודרת לכל התיקיה בבת אחת.

--- 

### דוגמה מס' 5: חיפוש רקורסיבי בתיקיות משנה

ExifTool יודע לחפש קבצים בכל תיקיות המשנה בעצמו בעת שימוש במתג `-r`.

```powershell
& $exifToolPath -r -json "D:\Photos" | ConvertFrom-Json |
    Select-Object FileName, Model, DateTimeOriginal |
    Export-Csv "C:\Reports\all_photos_recursive.csv" -NoTypeInformation -Encoding UTF8
```

--- 

### דוגמה מס' 6: שינוי שמות קבצים לפי תאריך צילום

זהו אחד מתרחישי האוטומציה הפופולריים ביותר – קבצים מקבלים שמות לפי תאריך/שעת הצילום.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# נשנה שם לפורמט YYYY-MM-DD_HH-MM-SS.jpg
& $exifToolPath -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```

💡 *ExifTool יכניס אוטומטית את סיומת הקובץ המקורית באמצעות `%%e`.*

--- 

### דוגמה מס' 7: חילוץ קואורדינטות GPS בלבד

שימושי אם אתם רוצים לבנות מפה מהתמונות שלכם.

```powershell
# 1. ציינו את הנתיב לתיקיה עם התמונות שלכם
$photoFolder = "E:\DCIM\Camera"

# 2. מפרטים את התגים שאנו צריכים: שם קובץ ושלושה תגי GPS.
#    זה הופך את השאילתה למהירה הרבה יותר מאשר אם היינו מאחזרים את כל התגים.
$tagsToExtract = @(
    "-SourceFile", # SourceFile עדיף על FileName, מכיוון שהוא בדרך כלל מכיל את הנתיב המלא
    "-GPSLatitude",
    "-GPSLongitude",
    "-GPSAltitude"
)

# 3. מפעילים את exiftool.exe ישירות (מכיוון שהוא ב-PATH).
#    המתג -r מחפש קבצים בכל תיקיות המשנה.
#    התוצאה מומרת מיד מ-JSON.
$allExifData = exiftool.exe -r -json $tagsToExtract $photoFolder | ConvertFrom-Json

# 4. מסננים את התוצאות: משאירים רק את האובייקטים שיש להם קו רוחב וקו אורך.
$filesWithGps = $allExifData | Where-Object { $_.GPSLatitude -and $_.GPSLongitude }

# 5. בודקים אם בכלל נמצאו קבצים עם נתוני GPS
if ($filesWithGps) {
    # 6. יוצרים דוח יפה מהנתונים המסוננים.
    #    משתמשים ב-Select-Object לשינוי שמות עמודות ועיצוב.
    $report = $filesWithGps | Select-Object @{Name="שם קובץ"; Expression={Split-Path $_.SourceFile -Leaf}},
                                             @{Name="קו רוחב"; Expression={$_.GPSLatitude}},
                                             @{Name="קו אורך"; Expression={$_.GPSLongitude}},
                                             @{Name="גובה"; Expression={if ($_.GPSAltitude) { "$($_.GPSAltitude) מ" } else { "N/A" }}}
    
    # 7. מציגים את הדוח הסופי בטבלה אינטראקטיבית בקונסולה.
    $report | Out-ConsoleGridView -Title "קבצים עם נתוני GPS בתיקיה: $photoFolder"

} else {
    # אם לא נמצא דבר, מודיעים על כך בנימוס.
    Write-Host "קבצים עם נתוני GPS בתיקיה '$photoFolder' לא נמצאו." -ForegroundColor Yellow
}
```

--- 

### דוגמה מס' 8: מחיקה המונית של כל נתוני GPS (לצורך פרטיות)

```powershell
# נמחק את כל תגי ה-GPS מקבצי JPG ו-PNG
& $exifToolPath -r -overwrite_original -gps:all= "D:\Photos"
```

💡 *פעולה זו בלתי הפיכה, לכן גבו את הקבצים לפני הביצוע.*

--- 

### דוגמה מס' 9: המרת זמן צילום לזמן מקומי

לפעמים תמונות צולמו באזור זמן אחר. ExifTool יכול להזיז את התאריך.

```powershell
# מזיזים את הזמן ב-3 שעות
& $exifToolPath "-AllDates+=3:0:0" "D:\Photos\IMG_*.JPG"
```

--- 

### דוגמה מס' 10: קבלת רשימה של כל דגמי המצלמות הייחודיים בתיקיה

```powershell
$models = & $exifToolPath -r -Model -s3 "D:\Photos" | Sort-Object -Unique
$models | ForEach-Object { Write-Host "דגם: $_" }
```

--- 

### דוגמה מס' 11: הצגת תגים נחוצים בלבד בפורמט טבלאי

```powershell
& $exifToolPath -T -Model -DateTimeOriginal -ISO -Aperture -ShutterSpeed "D:\Photos\IMG_1234.JPG"
```

-T מציג פלט בפורמט טבלאי, מופרד בטאבים – נוח לעיבוד נוסף.

--- 

### דוגמה מס' 12: בדיקת נוכחות GPS במערך גדול של קבצים

```powershell
$files = & $exifToolPath -r -if "$gpslatitude" -p '$FileName' "D:\Photos"
Write-Host "קבצים עם GPS:"
$files
```

--- 

### דוגמה מס' 13: העתקת מטא-נתונים מקובץ אחד לאחר

```powershell
# 1. בוחרים קובץ ייחוס
$sourceFile = Get-ChildItem "D:\Photos" -Filter "*.jpg" | Out-ConsoleGridView -Title "בחרו קובץ ייחוס"

# 2. אם קובץ ייחוס נבחר, בוחרים קבצי יעד
if ($sourceFile) {
    $targetFiles = Get-ChildItem "D:\Photos\New" -Filter "*.jpg" | Out-ConsoleGridView -Title "בחרו קבצי יעד להעתקת מטא-נתונים" -OutputMode Multiple
    
    # 3. אם קבצי יעד נבחרו, מבצעים את ההעתקה
    if ($targetFiles) {
        & exiftool.exe -TagsFromFile $sourceFile.FullName ($targetFiles.FullName)
        Write-Host "מטא-נתונים הועתקו מ-$($sourceFile.Name) ל-$($targetFiles.Count) קבצים."
    }
}
```

--- 

### דוגמה מס' 14: שמירת מטא-נתונים מקוריים לקובץ JSON נפרד לפני שינוי

```powershell
$backupPath = "C:\Reports\metadata_backup.json"
& $exifToolPath -r -json "D:\Photos" | Out-File -Encoding UTF8 $backupPath
```

--- 

### דוגמה מס' 15: שימוש ב-PowerShell למיון אוטומטי של תמונות לפי תאריך

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

### דוגמה 16: מציאת כל דגמי המצלמות הייחודיים באוסף

אף שניתן לעשות זאת בשורה אחת, הצגה ב-`GridView` מאפשרת להעתיק מיד את שם הדגם הרצוי.

```powershell
# המתג -s3 מציג רק ערכים, -Model - את שם התג
$uniqueModels = & exiftool.exe -r -Model -s3 "D:\Photos" | Sort-Object -Unique

# מציגים ב-GridView לצפייה והעתקה נוחות
$uniqueModels | Out-ConsoleGridView -Title "דגמי מצלמות ייחודיים באוסף"
```