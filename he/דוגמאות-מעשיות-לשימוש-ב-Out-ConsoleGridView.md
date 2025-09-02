### **דוגמאות מעשיות לשימוש ב-Out-ConsoleGridView**

בפרק הקודם, הכרנו את `Out-ConsoleGridView` — כלי רב עוצמה למניפולציה אינטראקטיבית של נתונים ישירות בטרמינל. אם אינך יודע על מה אני מדבר, אני ממליץ לקרוא זאת תחילה.
מאמר זה מוקדש כולו לו. לא אחזור על התיאוריה, אלא אעבור מיד לפרקטיקה ואציג 10 תרחישים שבהם cmdlet זה יכול לחסוך למנהל מערכת או למשתמש מתקדם זמן רב.

`Out-ConsoleGridView` הוא לא רק "מציג". הוא **מסנן אובייקטים אינטראקטיבי** באמצע הצינור שלך.

**דרישות קדם:**
*   PowerShell 7.2 ואילך.
*   מודול `Microsoft.PowerShell.ConsoleGuiTools` מותקן. אם עדיין לא התקנת אותו:
    ```powershell
    Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
    ```

---

### 10 דוגמאות מעשיות

#### דוגמה 1: עצירת תהליכים אינטראקטיבית

משימה קלאסית: מצא וסיים מספר תהליכים "תקועים" או מיותרים.

```powershell
# בחר תהליכים באופן אינטראקטיבי
$procsToStop = Get-Process | Sort-Object -Property CPU -Descending | Out-ConsoleGridView -OutputMode Multiple

# אם משהו נבחר, העבר את האובייקטים לסיום
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```


[1](https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/9d17f7d3-6efb-4069-a5f4-829e7e63b63f" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  `Get-Process` מאחזר את כל התהליכים הפועלים.
2.  `Sort-Object` ממיין אותם לפי שימוש במעבד, כך שה"זללנים" ביותר נמצאים למעלה.
3.  `Out-ConsoleGridView` מציג את הטבלה. אתה יכול להקליד `chrome` או `notepad` כדי לסנן את הרשימה באופן מיידי, ולבחור את התהליכים הרצויים באמצעות מקש `Space`.
4.  לאחר לחיצה על `Enter`, **אובייקטי** התהליכים שנבחרו מועברים למשתנה `$procsToStop` ולאחר מכן ל-`Stop-Process`.

#### דוגמה 2: ניהול שירותי Windows

צריך להפעיל מחדש במהירות מספר שירותים הקשורים ליישום אחד (לדוגמה, SQL Server).

```powershell
$services = Get-Service | Out-ConsoleGridView -OutputMode Multiple -Title "בחר שירותים להפעלה מחדש"

if ($services) {
    $services | Restart-Service -WhatIf
}
```

[1](https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/37986608-21d6-4013-b421-16072d1cf128" type="video/mp4">
  Your browser does not support the video tag.
</video>

1.  אתה מקבל רשימה של כל השירותים.
2.  בתוך `Out-ConsoleGridView`, אתה מקליד `sql` במסנן ורואה מיד את כל השירותים הקשורים ל-SQL Server.
3.  אתה בוחר את השירותים הדרושים ולוחץ `Enter`. אובייקטי השירותים שנבחרו מועברים להפעלה מחדש.

#### דוגמה 3: ניקוי תיקיית "הורדות" מקבצים גדולים

עם הזמן, תיקיית "הורדות" מתמלאת בקבצים מיותרים. בואו נמצא ונמחק את הגדולים שבהם.

```powershell

# --- שלב 1: הגדרת הנתיב לתיקיית 'Downloads'
$DownloadsPath = "E:\Users\user\Downloads" # <--- שנה שורה זו לנתיב שלך
===========================================================================

# בדיקה: אם הנתיב לא צוין או שהתיקייה לא קיימת - צא.
if ([string]::IsNullOrEmpty($DownloadsPath) -or (-not (Test-Path -Path $DownloadsPath))) {
    Write-Error "תיקיית 'הורדות' לא נמצאה בנתיב שצוין: '$DownloadsPath'. אנא בדוק את הנתיב בבלוק ההגדרות בתחילת הסקריפט."
    return
}

# --- שלב 2: יידוע המשתמש ואיסוף נתונים ---
Write-Host "מתחיל סריקה של תיקייה '$DownloadsPath'. זה עשוי לקחת זמן..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $DownloadsPath -File -Recurse -ErrorAction SilentlyContinue | 
    Sort-Object -Property Length -Descending

# --- שלב 3: בדיקת קבצים וקריאה לחלון האינטראקטיבי ---
if ($files) {
    Write-Host "הסריקה הושלמה. נמצאו $($files.Count) קבצים. פותח חלון בחירה..." -ForegroundColor Green
    
    $filesToShow = $files | Select-Object FullName, @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime
    
    $filesToDelete = $filesToShow | Out-ConsoleGridView -OutputMode Multiple -Title "בחר קבצים למחיקה מ-'$DownloadsPath'"

    # --- שלב 4: עיבוד בחירת המשתמש ---
    if ($filesToDelete) {
        Write-Host "הקבצים הבאים יימחקו:" -ForegroundColor Yellow
        $filesToDelete | Format-Table -AutoSize
        
        $filesToDelete.FullName | Remove-Item -WhatIf -Verbose
    } else {
        Write-Host "הפעולה בוטלה. לא נבחרו קבצים." -ForegroundColor Yellow
    }
} else {
    Write-Host "לא נמצאו קבצים בתיקייה '$DownloadsPath'." -ForegroundColor Yellow
}
```
[Clear-DownloadsFolder.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/scripts/Clear-DownloadsFolder.ps1)

[תוכן הורדות](https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/e7402188-5ffe-4e11-92ca-6f7eb4da709a" type="video/mp4">
  Your browser does not support the video tag.
</video>


1.  אנו מקבלים את כל הקבצים, ממיינים אותם לפי גודל, ובעזרת `Select-Object` יוצרים עמודת `SizeMB` נוחה.
2.  ב-`Out-ConsoleGridView` אתה רואה רשימה ממוינת שבה תוכל לבחור בקלות קבצי `.iso` או `.zip` ישנים וגדולים.
3.  לאחר הבחירה, נתיביהם המלאים מועברים ל-`Remove-Item`.

#### דוגמה 4: הוספת משתמשים לקבוצת Active Directory

דבר חיוני למנהלי AD.

```powershell
# קבל משתמשים ממחלקת השיווק
$users = Get-ADUser -Filter 'Department -eq "Marketing"' -Properties DisplayName

# בחר באופן אינטראקטיבי את מי להוסיף
$usersToAdd = $users | Select-Object Name, DisplayName | Out-ConsoleGridView -OutputMode Multiple

if ($usersToAdd) {
    Add-ADGroupMember -Identity "Marketing-Global-Group" -Members $usersToAdd -WhatIf
}
```

במקום להזין ידנית שמות משתמשים, אתה מקבל רשימה נוחה שבה תוכל למצוא ולבחור במהירות את העובדים הדרושים לפי שם משפחה או שם משתמש.



---

#### דוגמה 5: גלה אילו תוכניות משתמשות באינטרנט כרגע

אחת המשימות הנפוצות: "איזו תוכנית מאטה את האינטרנט?" או "מי שולח נתונים לאן?". עם `Out-ConsoleGridView`, תוכל לקבל תשובה ברורה ואינטראקטיבית.

**בתוך הטבלה:**
*   **הקלד `chrome` או `msedge`** בשדה הסינון כדי לראות את כל החיבורים הפעילים של הדפדפן שלך.
*   **הזן כתובת IP** (לדוגמה, `151.101.1.69` מהעמודה `RemoteAddress`) כדי לראות אילו תהליכים אחרים מחוברים לאותו שרת.

```powershell
# קבל את כל חיבורי ה-TCP הפעילים
$connections = Get-NetTCPConnection -State Established | 
    Select-Object RemoteAddress, RemotePort, OwningProcess, @{Name="ProcessName"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

# הצג בטבלה אינטראקטיבית לניתוח
$connections | Out-ConsoleGridView -Title "חיבורי אינטרנט פעילים"
```

1.  `Get-NetTCPConnection -State Established` אוסף את כל חיבורי הרשת המבוססים.
2.  באמצעות `Select-Object`, אנו יוצרים דוח נוח: אנו מוסיפים את שם התהליך (`ProcessName`) למזהה שלו (`OwningProcess`) כדי שיהיה ברור איזו תוכנית יצרה את החיבור.
3.  `Out-ConsoleGridView` מציג לך תמונה חיה של פעילות הרשת.

[Net](https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1ba78f04-bad8-4717-853b-27317cac72ec" type="video/mp4">
  Your browser does not support the video tag.
</video>

---



### דוגמה 6: ניתוח התקנת תוכנה ועדכונים

נחפש אירועים מהמקור **"MsiInstaller"**. הוא אחראי על התקנה, עדכון והסרה של רוב התוכניות (בפורמט `.msi`), וכן על רכיבי עדכון רבים של Windows.

```powershell
# מצא את 100 האירועים האחרונים מהמתקין של Windows (MsiInstaller)
# אירועים אלה קיימים בכל מערכת
$installEvents = Get-WinEvent -ProviderName 'MsiInstaller' -MaxEvents 100

# אם נמצאו אירועים, הצג אותם בצורה נוחה
if ($installEvents) {
    $installEvents | 
        # בחר רק את השימושיים ביותר: זמן, הודעה ומזהה אירוע
        # מזהה 11707 - התקנה מוצלחת, מזהה 11708 - התקנה נכשלה
        Select-Object TimeCreated, Id, Message |
        Out-ConsoleGridView -Title "יומן התקנת תוכנה (MsiInstaller)"
} else {
    Write-Warning "לא נמצאו אירועים מ-'MsiInstaller'. זה מאוד חריג."
}
```

**בתוך הטבלה:**
*   אתה יכול לסנן את הרשימה לפי שם התוכנית (לדוגמה, `Edge` או `Office`) כדי לראות את כל היסטוריית העדכונים שלה.
*   אתה יכול למיין לפי `Id` כדי למצוא התקנות שנכשלו (`11708`).


---



#### דוגמה 7: הסרת התקנה אינטראקטיבית של תוכניות

```powershell
# נתיבי רישום שבהם מאוחסן מידע על תוכניות מותקנות
$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# אסוף נתונים מהרישום, הסר רכיבי מערכת שאין להם שם
$installedPrograms = Get-ItemProperty $registryPaths | 
    Where-Object { $_.DisplayName -and $_.UninstallString } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

# אם נמצאו תוכניות, הצג אותן בטבלה אינטראקטיבית
if ($installedPrograms) {
    $programsToUninstall = $installedPrograms | Out-ConsoleGridView -OutputMode Multiple -Title "בחר תוכניות להסרה"
    
    if ($programsToUninstall) {
        Write-Host "התוכניות הבאות יוסרו:" -ForegroundColor Yellow
        $programsToUninstall | Format-Table -AutoSize
        
        # בלוק זה מורכב יותר, מכיוון ש-Uninstall-Package לא יעבוד כאן.
        # אנו מריצים את פקודת הסרת ההתקנה מהרישום.
        foreach ($program in $programsToUninstall) {
            # מצא את אובייקט התוכנית המקורי עם מחרוזת הסרת ההתקנה
            $fullProgramInfo = Get-ItemProperty $registryPaths | Where-Object { $_.DisplayName -eq $program.DisplayName }
            
            if ($fullProgramInfo.UninstallString) {
                Write-Host "מפעיל את תוכנית הסרת ההתקנה עבור '$($program.DisplayName)'..."
                # אזהרה: זה יפעיל את תוכנית הסרת ההתקנה הגרפית הסטנדרטית של התוכנית.
                # WhatIf לא יעבוד כאן, היזהר.
                # cmd.exe /c $fullProgramInfo.UninstallString
            }
        }
        Write-Warning "כדי להסיר תוכניות בפועל, בטל את ההערה מהשורה 'cmd.exe /c ...' בסקריפט."
    }
} else {
    Write-Warning "לא ניתן למצוא תוכניות מותקנות ברישום."
}
```

---


אתה צודק לחלוטין. דוגמת Active Directory אינה מתאימה למשתמש רגיל ודורשת סביבה מיוחדת.

בואו נחליף אותה בתרחיש אוניברסלי ומובן הרבה יותר, המדגים בצורה מושלמת את עוצמת השרשור של `Out-ConsoleGridView` ויהיה שימושי לכל משתמש.

---

#### דוגמה 8: שרשור `Out-ConsoleGridView`

זוהי הטכניקה החזקה ביותר. הפלט של סשן אינטראקטיבי אחד הופך לקלט עבור אחר. **משימה:** בחר אחת מתיקיות הפרויקט שלך, ולאחר מכן בחר מתוכה קבצים ספציפיים ליצירת ארכיון ZIP.

```powershell
# --- שלב 1: מצא באופן אוניברסלי את תיקיית "מסמכים" ---
$SearchPath = [System.Environment]::GetFolderPath('MyDocuments')

# --- שלב 2: בחר באופן אינטראקטיבי תיקייה אחת מהמיקום שצוין ---
$selectedFolder = Get-ChildItem -Path $SearchPath -Directory | 
    Out-ConsoleGridView -Title "בחר תיקייה לארכיון"

if ($selectedFolder) {
    # --- שלב 3: אם נבחרה תיקייה, קבל את קבציה ובחר אילו מהם לארכיון ---
    $filesToArchive = Get-ChildItem -Path $selectedFolder.FullName -File | 
        Out-ConsoleGridView -OutputMode Multiple -Title "בחר קבצים לארכיון מ-'$($selectedFolder.Name)'"

    if ($filesToArchive) {
        # --- שלב 4: בצע פעולה עם נתיבים אוניברסליים ---
        $archiveName = "Archive-$($selectedFolder.Name)-$(Get-Date -Format 'yyyy-MM-dd').zip"
        
        # דרך אוניברסלית לקבל נתיב שולחן עבודה
        $desktopPath = [System.Environment]::GetFolderPath('Desktop')
        $destinationPath = Join-Path -Path $desktopPath -ChildPath $archiveName
        
        # צור ארכיון
        Compress-Archive -Path $filesToArchive.FullName -DestinationPath $destinationPath -WhatIf
        
        Write-Host "ארכיון '$archiveName' ייווצר בשולחן העבודה שלך בנתיב '$destinationPath'." -ForegroundColor Green
    }
}
```


1.  ה-`Out-ConsoleGridView` הראשון מציג לך רשימה של תיקיות בתוך "המסמכים" שלך. אתה יכול למצוא במהירות את התיקייה הדרושה לך על ידי הקלדת חלק משמה, ולבחור **תיקייה אחת**.
2.  אם נבחרה תיקייה, הסקריפט פותח מיד `Out-ConsoleGridView` **שני**, המציג כעת את **הקבצים שבתוך** תיקייה זו.
3.  אתה בוחר **קובץ אחד או יותר** באמצעות מקש `Space` ולוחץ `Enter`.
4.  הסקריפט לוקח את הקבצים שנבחרו ויוצר מהם ארכיון ZIP בשולחן העבודה שלך.

זה הופך משימה מורכבת מרובת שלבים (מצא תיקייה, מצא בה קבצים, העתק את נתיביהם, הפעל את פקודת הארכיון) לתהליך אינטראקטיבי אינטואיטיבי דו-שלבי.


#### דוגמה 9: ניהול רכיבי Windows אופציונליים

```powershell
# --- דוגמה 9: ניהול רכיבי Windows אופציונליים ---

# קבל רק רכיבים מופעלים
$features = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }

$featuresToDisable = $features | Select-Object FeatureName, DisplayName | 
    Out-ConsoleGridView -OutputMode Multiple -Title "בחר רכיבים לביטול"

if ($featuresToDisable) {
    # אזהר את המשתמש מפני אי-הפיכות
    Write-Host "אזהרה! הרכיבים הבאים יושבתו באופן מיידי." -ForegroundColor Red
    Write-Host "פעולה זו אינה תומכת במצב בטוח -WhatIf."
    $featuresToDisable | Select-Object DisplayName

    # בקש אישור ידני
    $confirmation = Read-Host "להמשיך? (y/n)"
    
    if ($confirmation -eq 'y') {
        foreach($feature in $featuresToDisable){
            Write-Host "מבטל רכיב '$($feature.DisplayName)'..." -ForegroundColor Yellow
            Disable-WindowsOptionalFeature -Online -FeatureName $feature.FeatureName
        }
        Write-Host "הפעולה הושלמה. ייתכן שתידרש הפעלה מחדש." -ForegroundColor Green
    } else {
        Write-Host "הפעולה בוטלה."
    }
}
```

אתה יכול למצוא ולבטל בקלות רכיבים מיותרים, כגון `Telnet-Client` או `Windows-Sandbox`.

#### דוגמה 10: ניהול מכונות וירטואליות של Hyper-V

עצור במהירות מספר מכונות וירטואליות לצורך תחזוקת המארח.

```powershell
# קבל רק מכונות וירטואליות פועלות
$vms = Get-VM | Where-Object { $_.State -eq 'Running' }

$vmsToStop = $vms | Select-Object Name, State, Uptime | 
    Out-ConsoleGridView -OutputMode Multiple -Title "בחר מכונות וירטואליות לעצירה"

if ($vmsToStop) {
    $vmsToStop | Stop-VM -WhatIf
}
```

אתה מקבל רשימה של מכונות פועלות בלבד ויכול לבחור באופן אינטראקטיבי את אלה שצריך לכבות בבטחה.
