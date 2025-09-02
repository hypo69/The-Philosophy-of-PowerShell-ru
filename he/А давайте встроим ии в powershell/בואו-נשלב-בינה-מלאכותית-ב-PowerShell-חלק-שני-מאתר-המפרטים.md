# בואו נשלב בינה מלאכותית ב-PowerShell. חלק שני: מאתר המפרטים

בפעם הקודמת ראינו כיצד אנו יכולים לתקשר עם מודל Gemini דרך ממשק שורת הפקודה באמצעות PowerShell. במאמר זה אראה כיצד להפיק תועלת מהידע שלנו. נהפוך את הקונסולה שלנו למדריך עזר אינטראקטיבי שיקבל מזהה רכיב (מותג, דגם, קטגוריה, מספר חלק וכו') כקלט, ויחזיר טבלה אינטראקטיבית עם מאפיינים שהתקבלו ממודל Gemini.

מהנדסים, מפתחים ומומחים אחרים נתקלים בצורך לברר פרמטרים מדויקים, למשל, של לוח אם, מפסק חשמל בלוח חשמל, או מתג רשת. מדריך העזר שלנו יהיה תמיד בהישג יד ועל פי בקשה יאסוף מידע, יבהיר פרמטרים באינטרנט ויחזיר את הטבלה הרצויה. בטבלה ניתן לבחור את הפרמטר/ים הדרושים ובמידת הצורך להמשיך בחיפוש מעמיק יותר. בעתיד נלמד כיצד להעביר את התוצאה דרך צינור עיבוד נוסף: ייצוא לטבלת Excel, גיליון Google, אחסון במסד נתונים או העברה לתוכנה אחרת. במקרה של כשל, המודל ימליץ אילו פרמטרים יש לברר. עם זאת, ראו בעצמכם:

[וידאו](https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/0e6690c1-5d49-4c75-89fc-ede2c7642c5f" type="video/mp4">
  Your browser does not support the video tag.
</video>

## כיצד פועל מאתר המפרטים מבוסס AI: מההפעלה ועד לתוצאה

בואו נעקוב אחר מחזור החיים המלא של הסקריפט שלנו - מה קורה מרגע ההפעלה ועד לקבלת התוצאות.

## אתחול: הכנה לעבודה

הסקריפט מקבל את הפרמטר `$Model` עם אימות - ניתן לבחור 'gemini-2.5-flash' (ברירת מחדל, מודל מהיר) או 'gemini-2.5-pro' (חזק יותר). עם ההפעלה, הסקריפט מגדיר תחילה את סביבת העבודה. הוא מגדיר את מפתח ה-API לגישה ל-Gemini AI, מגדיר את התיקיה הנוכחית כספריית הבסיס, ויוצר מבנה לאחסון קבצים. עבור כל סשן, נוצר קובץ עם חותמת זמן, לדוגמה, `ai_session_2025-08-26_14-30-15.jsonl`. זוהי היסטוריית הדיאלוג.

לאחר מכן המערכת בודקת שכל הכלים הדרושים מותקנים. היא מחפשת את Gemini CLI במערכת, בודקת קיומם של קבצי תצורה בתיקיית `.gemini/`. קובץ `GEMINI.md` חשוב במיוחד - הוא מכיל את הפרומפט המערכתי למודל ונטען אוטומטית על ידי Gemini CLI בעת ההפעלה. זהו המיקום הסטנדרטי להוראות מערכת. קובץ `ShowHelp.md` עם מידע עזר נבדק גם הוא. אם חסר משהו קריטי, הסקריפט מזהיר את המשתמש או מסיים את פעולתו.

## הפעלת מצב אינטראקטיבי

לאחר אתחול מוצלח, הסקריפט מציג הודעת קבלת פנים המציינת את המודל שנבחר ("מאתר מפרטי AI. מודל: 'gemini-2.5-flash'."), את הנתיב לקובץ הסשן, והוראות לפקודות. לאחר מכן הוא עובר למצב אינטראקטיבי - מציג הנחיה וממתין לקלט מהמשתמש. ההנחיה נראית כמו `🤖AI :) > ` ומשתנה ל-`🤖AI [בחירה פעילה] :) > ` כאשר למערכת יש נתונים לניתוח.

## עיבוד קלט משתמש

כל קלט משתמש נבדק תחילה עבור פקודות שירות באמצעות הפונקציה `Command-Handler`. פונקציה זו מזהה פקודות `?` (עזרה מקובץ ShowHelp.md), `history` (הצגת היסטוריית סשן), `clear` ו-`clear-history` (ניקוי קובץ היסטוריה), `gemini help` (עזרה CLI), `exit` ו-`quit` (יציאה). אם זו פקודת שירות, היא מבוצעת מיד ללא פנייה ל-AI, והלולאה ממשיכה.

אם זו שאילתה רגילה, המערכת מתחילה ליצור את ההקשר לשליחה ל-Gemini. היא קוראת את כל היסטוריית הסשן הנוכחי מקובץ JSONL (אם קיים), מוסיפה בלוק עם נתונים מהבחירה הקודמת (אם יש בחירה פעילה), ומשלבת את כל זה עם שאילתת המשתמש החדשה לפרומפט מובנה עם סעיפים "היסטוריית דיאלוג", "נתונים מהבחירה" ו"משימה חדשה". לאחר השימוש, נתוני הבחירה מאופסים.

## אינטראקציה עם בינה מלאכותית

הפרומפט שנוצר נשלח ל-Gemini דרך שורת הפקודה באמצעות הקריאה `& gemini -m $Model -p $Prompt 2>&1`. המערכת לוכדת את כל הפלט (כולל שגיאות דרך `2>&1`), בודקת את קוד ההחזרה, ומנקה את התוצאה מהודעות שירות של CLI ("איסוף נתונים מושבת" ו"טעינת אישורים שמורים"). אם מתרחשת שגיאה בשלב זה, המשתמש מקבל אזהרה, אך הסקריפט ממשיך לפעול.

## עיבוד תגובת AI

התגובה שהתקבלה מה-AI מנסה להתפרש כ-JSON על ידי המערכת. תחילה, היא מחפשת בלוק קוד בפורמט ```json...```, מחלצת את התוכן ומנסה לנתח אותו. אם אין בלוק כזה, היא מנתחת את כל התגובה. עם ניתוח מוצלח, הנתונים מוצגים בטבלת `Out-ConsoleGridView` אינטראקטיבית עם הכותרת "בחר שורות לשאילתה הבאה (אישור) או סגור (ביטול)" ובחירה מרובה. אם JSON אינו מזוהה (שגיאת ניתוח), התגובה מוצגת כטקסט רגיל בצבע כחול.

## עבודה עם בחירת נתונים

כאשר המשתמש בוחר שורות בטבלה ולוחץ אישור, המערכת מבצעת מספר פעולות. תחילה, נקראת הפונקציה `Show-SelectionTable`, המנתחת את מבנה הנתונים שנבחרו: אם אלו אובייקטים עם מאפיינים, היא קובעת את כל השדות הייחודיים ומציגה את הנתונים באמצעות `Format-Table` עם התאמה אוטומטית של גודל וגלישה. אם אלו ערכים פשוטים, היא מציגה אותם כרשימה ממוספרת. לאחר מכן היא מציגה את ספירת הפריטים שנבחרו ואת ההודעה "הבחירה נשמרה. הוסף את השאילתה הבאה שלך (לדוגמה, 'השווה אותם')".

הנתונים שנבחרו מומרים ל-JSON דחוס עם עומק קינון של 10 רמות ונשמרים במשתנה `$selectionContextJson` לשימוש בשאילתות AI הבאות.

## שמירת היסטוריה

כל זוג "שאילתת משתמש - תגובת AI" נשמר בקובץ היסטוריה בפורמט JSONL. זה מבטיח המשכיות דיאלוג - ה-AI "זוכר" את כל השיחה הקודמת ויכול להתייחס לנושאים שנדונו בעבר.

## המחזור נמשך

לאחר עיבוד השאילתה, המערכת חוזרת להמתין לקלט חדש. אם למשתמש יש בחירה פעילה, הדבר משתקף בהנחיית שורת הפקודה. המחזור נמשך עד שהמשתמש מזין פקודת יציאה.

## דוגמה מעשית לעבודה

תארו לעצמכם שהמשתמש מפעיל את הסקריפט ומזין "RTX 4070 Ti Super":

1.  **הכנת הקשר:** המערכת לוקחת את הפרומפט המערכתי מהקובץ, מוסיפה היסטוריה (כרגע ריקה), ושאילתה חדשה.
2.  **פנייה ל-AI:** הפרומפט המלא נשלח ל-Gemini עם בקשה למצוא מאפייני כרטיס מסך.
3.  **אחזור נתונים:** ה-AI מחזיר JSON עם מערך של אובייקטים המכילים מידע על דגמי RTX 4070 Ti Super שונים.
4.  **טבלה אינטראקטיבית:** המשתמש רואה טבלה עם יצרנים, מאפיינים ומחירים, ובוחר 2-3 דגמים מעניינים.
5.  **הצגת הבחירה:** טבלה עם הדגמים שנבחרו מופיעה בקונסולה, וההנחיה משתנה ל-`[בחירה פעילה]`.
6.  **שאילתה מבהירה:** המשתמש מקליד "השווה ביצועי משחקים".
7.  **ניתוח הקשרי:** ה-AI מקבל גם את השאילתה המקורית, גם את הדגמים שנבחרו, וגם את השאלה החדשה - מספק השוואה מפורטת של כרטיסים ספציפיים אלו.

## סיום עבודה

עם הזנת `exit` או `quit`, הסקריפט מסיים את פעולתו כהלכה, לאחר ששמר את כל היסטוריית הסשן לקובץ. המשתמש יכול לחזור לדיאלוג זה בכל עת על ידי הצגת תוכן הקובץ המתאים בתיקיית `.chat_history`.

כל הלוגיקה המורכבת הזו מוסתרת מהמשתמש מאחורי ממשק שורת פקודה פשוט. האדם פשוט שואל שאלות ומקבל תשובות מובנות, והמערכת לוקחת על עצמה את כל העבודה של שמירת הקשר, ניתוח נתונים וניהול מצב הדיאלוג.

---

## שלב 1: הגדרה

```powershell
# --- שלב 1: הגדרה ---
$env:GEMINI_API_KEY = "AIzaSyCbq8bkt5Xr2hlE-73MIXFpdFYH-rLBd0k"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
# --- שינוי: שם המשתנה שונה ---
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
# --- סוף שינוי ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName
```

**מטרת השורות:**

- `$env:GEMINI_API_KEY = "..."` - מגדיר את מפתח ה-API לגישה ל-Gemini AI.
- `if (-not $env:GEMINI_API_KEY)` - בודק את קיומו של המפתח, מסיים את הסקריפט אם הוא חסר.
- `$scriptRoot = Get-Location` - מקבל את ספריית העבודה הנוכחית.
- `$HistoryDir = Join-Path...` - יוצר את הנתיב לתיקיה לאחסון היסטוריית דיאלוגים (`.gemini/.chat_history`).
- `$timestamp = Get-Date...` - יוצר חותמת זמן בפורמט `2025-08-26_14-30-15`.
- `$historyFileName = "ai_session_$timestamp.jsonl"` - מייצר שם קובץ סשן ייחודי.
- `$historyFilePath = Join-Path...` - יוצר את הנתיב המלא לקובץ היסטוריית הסשן הנוכחי.

## בדיקת סביבה - מה צריך להיות מותקן

```powershell
# --- שלב 2: בדיקת סביבה ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } 
catch { Write-Error "הפקודה 'gemini' לא נמצאה..."; return }

if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { 
    Write-Warning "קובץ הפרומפט המערכתי .gemini/GEMINI.md לא נמצא..." 
}
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { 
    Write-Warning "קובץ העזרה .gemini/ShowHelp.md לא נמצא..." 
}
```

**מה נבדק:**

- נוכחות **Gemini CLI** במערכת - הסקריפט לא יעבוד בלעדיו.
- קובץ **GEMINI.md** - מכיל את הפרומפט המערכתי (הוראות ל-AI).
- קובץ **ShowHelp.md** - עזרה למשתמש (פקודת `?`).

## פונקציה ראשית לאינטראקציה עם AI

```powershell
function Invoke-GeminiPrompt {
    param([string]$Prompt, [string]$Model)
    try {
        $output = & gemini -m $Model -p $Prompt 2>&1
        if (-not $?) { $output | ForEach-Object { Write-Warning $_.ToString() }; return $null }
        
        $outputString = ($output -join [Environment]::NewLine).Trim()
        $cleanedOutput = $outputString -replace "(?m)^Data collection is disabled\.`r?`n" , ""
        $cleanedOutput = $cleanedOutput -replace "(?m)^Loaded cached credentials\.`r?`n", ""
        
        return $cleanedOutput.Trim()
    }
    catch { Write-Error "שגיאה קריטית בקריאה ל-Gemini CLI: $_"; return $null }
}
```

**משימות הפונקציה:**
- קוראת ל-Gemini CLI עם המודל והפרומפט שצוינו.
- לוכדת את כל הפלטים (כולל שגיאות).
- מנקה את התוצאה מהודעות שירות של CLI.
- מחזירה תגובת AI נקייה או `$null` במקרה של שגיאה.

## פונקציות לניהול היסטוריה

```powershell
function Add-History { 
    param([string]$UserPrompt, [string]$ModelResponse)
    if (-not (Test-Path $HistoryDir)) { New-Item -Path $HistoryDir -ItemType Directory | Out-Null }
    @{ user = $UserPrompt } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
    @{ model = $ModelResponse } | ConvertTo-Json -Compress | Add-Content -Path $historyFilePath
}

function Show-History {
    if (-not (Test-Path $historyFilePath)) { Write-Host "היסטוריית הסשן הנוכחי ריקה." -ForegroundColor Yellow; return }
    Write-Host "`n--- היסטוריית סשן נוכחי ---" -ForegroundColor Cyan
    Get-Content -Path $historyFilePath
    Write-Host "------------------------------------`n" -ForegroundColor Cyan
}

function Clear-History {
    if (Test-Path $historyFilePath) {
        Remove-Item -Path $historyFilePath -Force -ErrorAction Stop
        Write-Host "היסטוריית הסשן הנוכחי ($historyFileName) נמחקה." -ForegroundColor Yellow
    }
}
```

**מטרה:**
- `Add-History` - שומר זוגות "שאלה-תשובה" בפורמט JSONL.
- `Show-History` - מציג את תוכן קובץ ההיסטוריה.
- `Clear-History` - מוחק את קובץ היסטוריית הסשן הנוכחי.

## פונקציה להצגת נתונים נבחרים

```powershell
function Show-SelectionTable {
    param([array]$SelectedData)
    
    if ($null -eq $SelectedData -or $SelectedData.Count -eq 0) { return }
    
    Write-Host "`n--- נתונים נבחרים ---" -ForegroundColor Yellow
    
    # קבל את כל המאפיינים הייחודיים מהאובייקטים שנבחרו
    $allProperties = @()
    foreach ($item in $SelectedData) {
        if ($item -is [PSCustomObject]) {
            $properties = $item | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            $allProperties = $allProperties + $properties | Sort-Object -Unique
        }
    }
    
    # הצג טבלה או רשימה
    if ($allProperties.Count -gt 0) {
        $SelectedData | Format-Table -Property $allProperties -AutoSize -Wrap
    } else {
        for ($i = 0; $i -lt $SelectedData.Count; $i++) {
            Write-Host "[$($i + 1)] $($SelectedData[$i])" -ForegroundColor White
        }
    }
    
    Write-Host "-------------------------" -ForegroundColor Yellow
    Write-Host "פריטים נבחרו: $($SelectedData.Count)" -ForegroundColor Magenta
}
```

**משימת הפונקציה:** לאחר בחירת פריטים ב-`Out-ConsoleGridView`, היא מציגה אותם בקונסולה כטבלה מסודרת, כך שהמשתמש יוכל לראות בדיוק מה נבחר.

## לולאת עבודה ראשית

```powershell
while ($true) {
    # הצגת הנחיה עם אינדיקציה למצב
    if ($selectionContextJson) {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI [בחירה פעילה] :) > "
    } else {
        Write-Host -NoNewline -ForegroundColor Green "🤖AI :) > "
    }
    
    $UserPrompt = Read-Host
    
    # טיפול בפקודות שירות
    $commandResult = Command-Handler -Command $UserPrompt
    if ($commandResult -eq 'break') { break }
    if ($commandResult -eq 'continue') { continue }
    
    # יצירת הפרומפט המלא עם הקשר
    $fullPrompt = @"
### היסטוריית דיאלוג (הקשר)
$historyContent

### נתונים מהבחירה (לניתוח)
$selectionContextJson

### משימה חדשה
$UserPrompt
"@
    
    # קריאה ל-AI ועיבוד התגובה
    $ModelResponse = Invoke-GeminiPrompt -Prompt $fullPrompt -Model $Model
    
    # ניסיון לנתח JSON ולהציג טבלה אינטראקטיבית
    try {
        $jsonObject = $jsonToParse | ConvertFrom-Json
        $gridSelection = $jsonObject | Out-ConsoleGridView -Title "בחר שורות..." -OutputMode Multiple
        
        if ($null -ne $gridSelection) {
            Show-SelectionTable -SelectedData $gridSelection
            $selectionContextJson = $gridSelection | ConvertTo-Json -Compress -Depth 10
        }
    }
    catch {
        Write-Host $ModelResponse -ForegroundColor Cyan
    }
    
    Add-History -UserPrompt $UserPrompt -ModelResponse $ModelResponse
}
```

**תכונות עיקריות:**
- מחוון `[בחירה פעילה]` מראה שיש נתונים לניתוח.
- כל שאילתה כוללת את כל היסטוריית הדיאלוג לשמירת הקשר.
- ה-AI מקבל גם את ההיסטוריה וגם את הנתונים שנבחרו על ידי המשתמש.
- התוצאה מנסה להיות מוצגת כטבלה אינטראקטיבית.
- אם ניתוח JSON נכשל, מוצג טקסט רגיל.

## מבנה קבצי עבודה

הסקריפט יוצר את המבנה הבא:
```
├── Find-Spec.ps1
├── .gemini/
│   ├── GEMINI.md              # פרומפט מערכתי ל-AI
│   ├── ShowHelp.md            # עזרה למשתמש
│   └── .chat_history/         # תיקיה עם היסטוריית סשנים
│       ├── ai_session_2025-08-26_10-15-30.jsonl
│       └── ai_session_2025-08-26_14-22-45.jsonl
```

קובץ `GEMINI.md` בתיקיית `.gemini/` הוא המיקום הסטנדרטי לפרומפט המערכתי עבור Gemini CLI. בכל הפעלה, המודל טוען אוטומטית הוראות מקובץ זה, מה שמגדיר את התנהגותו ופורמט התגובות שלו.


בחלק הבא, נבחן את תוכן קבצי התצורה ודוגמאות שימוש מעשיות.