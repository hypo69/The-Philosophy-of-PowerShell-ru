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

הסקריפט מקבל את הפרמטר <code>$Model</code> עם אימות - ניתן לבחור '<code>gemini-2.5-flash</code>' (ברירת מחדל, מודל מהיר) או '<code>gemini-2.5-pro</code>' (חזק יותר). עם ההפעלה, הסקריפט מגדיר תחילה את סביבת העבודה. הוא מגדיר את מפתח ה-API לגישה ל-Gemini AI, מגדיר את התיקיה הנוכחית כספריית הבסיס, ויוצר מבנה לאחסון קבצים. עבור כל סשן, נוצר קובץ עם חותמת זמן, לדוגמה, <code>ai_session_2025-08-26_14-30-15.jsonl</code>. זוהי היסטוריית הדיאלוג.

לאחר מכן המערכת בודקת שכל הכלים הדרושים מותקנים. היא מחפשת את Gemini CLI במערכת, בודקת קיומם של קבצי תצורה בתיקיית <code>.gemini/</code>. קובץ <code>GEMINI.md</code> חשוב במיוחד - הוא מכיל את הפרומפט המערכתי למודל ונטען אוטומטית על ידי Gemini CLI בעת ההפעלה. זהו המיקום הסטנדרטי להוראות מערכת. קובץ <code>ShowHelp.md</code> עם מידע עזר נבדק גם הוא. אם חסר משהו קריטי, הסקריפט מזהיר את המשתמש או מסיים את פעולתו.

## הפעלת מצב אינטראקטיבי

לאחר אתחול מוצלח, הסקריפט מציג הודעת קבלת פנים המציינת את המודל שנבחר ("מאתר מפרטי AI. מודל: '<code>gemini-2.5-flash</code>'."), את הנתיב לקובץ הסשן, והוראות לפקודות. לאחר מכן הוא עובר למצב אינטראקטיבי - מציג הנחיה וממתין לקלט מהמשתמש. ההנחיה נראית כמו <code>🤖AI :) > </code> ומשתנה ל-<code>🤖AI [בחירה פעילה] :) > </code> כאשר למערכת יש נתונים לניתוח.

## עיבוד קלט משתמש

כל קלט משתמש נבדק תחילה עבור פקודות שירות באמצעות הפונקציה <code>Command-Handler</code>. פונקציה זו מזהה פקודות <code>?</code> (עזרה מקובץ ShowHelp.md), <code>history</code> (הצגת היסטוריית סשן), <code>clear</code> ו-<code>clear-history</code> (ניקוי קובץ היסטוריה), <code>gemini help</code> (עזרה CLI), <code>exit</code> ו-<code>quit</code> (יציאה). אם זו פקודת שירות, היא מבוצעת מיד ללא פנייה ל-AI, והלולאה ממשיכה.

אם זו שאילתה רגילה, המערכת מתחילה ליצור את ההקשר לשליחה ל-Gemini. היא קוראת את כל היסטוריית הסשן הנוכחי מקובץ JSONL (אם קיים), מוסיפה בלוק עם נתונים מהבחירה הקודמת (אם יש בחירה פעילה), ומשלבת את כל זה עם שאילתת המשתמש החדשה לפרומפט מובנה עם סעיפים "היסטוריית דיאלוג", "נתונים מהבחירה" ו"משימה חדשה". לאחר השימוש, נתוני הבחירה מאופסים.

## אינטראקציה עם בינה מלאכותית

הפרומפט שנוצר נשלח ל-Gemini דרך שורת הפקודה באמצעות הקריאה <code>& gemini -m $Model -p $Prompt 2>&1</code>. המערכת לוכדת את כל הפלט (כולל שגיאות דרך <code>2>&1</code>), בודקת את קוד ההחזרה, ומנקה את התוצאה מהודעות שירות של CLI ("איסוף נתונים מושבת" ו"טעינת אישורים שמורים"). אם מתרחשת שגיאה בשלב זה, המשתמש מקבל אזהרה, אך הסקריפט ממשיך לפעול.

## עיבוד תגובת AI

התגובה שהתקבלה מה-AI מנסה להתפרש כ-JSON על ידי המערכת. תחילה, היא מחפשת בלוק קוד בפורמט <code>```json...```</code>, מחלצת את התוכן ומנסה לנתח אותו. אם אין בלוק כזה, היא מנתחת את כל התגובה. עם ניתוח מוצלח, הנתונים מוצגים בטבלת <code>Out-ConsoleGridView</code> אינטראקטיבית עם הכותרת "בחר שורות לשאילתה הבאה (אישור) או סגור (ביטול)" ובחירה מרובה. אם JSON אינו מזוהה (שגיאת ניתוח), התגובה מוצגת כטקסט רגיל בצבע כחול.

## עבודה עם בחירת נתונים

כאשר המשתמש בוחר שורות בטבלה ולוחץ אישור, המערכת מבצעת מספר פעולות. תחילה, נקראת הפונקציה <code>Show-SelectionTable</code>, המנתחת את מבנה הנתונים שנבחרו: אם אלו אובייקטים עם מאפיינים, היא קובעת את כל השדות הייחודיים ומציגה את הנתונים באמצעות <code>Format-Table</code> עם התאמה אוטומטית של גודל וגלישה. אם אלו ערכים פשוטים, היא מציגה אותם כרשימה ממוספרת. לאחר מכן היא מציגה את ספירת הפריטים שנבחרו ואת ההודעה "הבחירה נשמרה. הוסף את השאילתה הבאה שלך (לדוגמה, 'השווה אותם')".

הנתונים שנבחרו מומרים ל-JSON דחוס עם עומק קינון של 10 רמות ונשמרים במשתנה <code>$selectionContextJson</code> לשימוש בשאילתות AI הבאות.

## שמירת היסטוריה

כל זוג "שאילתת משתמש - תגובת AI" נשמר בקובץ היסטוריה בפורמט JSONL. זה מבטיח המשכיות דיאלוג - ה-AI "זוכר" את כל השיחה הקודמת ויכול להתייחס לנושאים שנדונו בעבר.

## המחזור נמשך

לאחר עיבוד השאילתה, המערכת חוזרת להמתין לקלט חדש. אם למשתמש יש בחירה פעילה, הדבר משתקף בהנחיית שורת הפקודה. המחזור נמשך עד שהמשתמש מזין פקודת יציאה.

## דוגמה מעשית לעבודה

תארו לעצמכם שהמשתמש מפעיל את הסקריפט ומזין "RTX 4070 Ti Super":

1.  <strong>הכנת הקשר:</strong> המערכת לוקחת את הפרומפט המערכתי מהקובץ, מוסיפה היסטוריה (כרגע ריקה), ושאילתה חדשה.
2.  <strong>פנייה ל-AI:</strong> הפרומפט המלא נשלח ל-Gemini עם בקשה למצוא מאפייני כרטיס מסך.
3.  <strong>אחזור נתונים:</strong> ה-AI מחזיר JSON עם מערך של אובייקטים המכילים מידע על דגמי RTX 4070 Ti Super שונים.
4.  <strong>טבלה אינטראקטיבית:</strong> המשתמש רואה טבלה עם יצרנים, מאפיינים ומחירים, ובוחר 2-3 דגמים מעניינים.
5.  <strong>הצגת הבחירה:</strong> טבלה עם הדגמים שנבחרו מופיעה בקונסולה, וההנחיה משתנה ל-<code>[בחירה פעילה]</code>.
6.  <strong>שאילתה מבהירה:</strong> המשתמש מקליד "השווה ביצועי משחקים".
7.  <strong>ניתוח הקשרי:</strong> ה-AI מקבל גם את השאילתה המקורית, גם את הדגמים שנבחרו, וגם את השאלה החדשה - מספק השוואה מפורטת של כרטיסים ספציפיים אלו.

## סיום עבודה

עם הזנת <code>exit</code> או <code>quit</code>, הסקריפט מסיים את פעולתו כהלכה, לאחר ששמר את כל היסטוריית הסשן לקובץ. המשתמש יכול לחזור לדיאלוג זה בכל עת על ידי הצגת תוכן הקובץ המתאים בתיקיית <code>.chat_history</code>.

כל הלוגיקה המורכבת הזו מוסתרת מהמשתמש מאחורי ממשק שורת פקודה פשוט. האדם פשוט שואל שאלות ומקבל תשובות מובנות, והמערכת לוקחת על עצמה את כל העבודה של שמירת הקשר, ניתוח נתונים וניהול מצב הדיאלוג.

---

## שלב 1: הגדרה

<pre class="line-numbers"><code class="language-powershell"># --- שלב 1: הגדרה ---
$env:GEMINI_API_KEY = "AIzaSyCbq8bkt5Xr2hlE-73MIXFpdFYH-rLBd0k"
if (-not $env:GEMINI_API_KEY) { Write-Error "..."; return }

$scriptRoot = Get-Location
# --- שינוי: שם המשתנה שונה ---
$HistoryDir = Join-Path $scriptRoot ".gemini/.chat_history"
# --- סוף שינוי ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$historyFileName = "ai_session_$timestamp.jsonl"
$historyFilePath = Join-Path $HistoryDir $historyFileName
</code></pre>

<strong>מטרת השורות:</strong>

<ul>
<li><code>$env:GEMINI_API_KEY = "..."</code> - מגדיר את מפתח ה-API לגישה ל-Gemini AI.</li>
<li><code>if (-not $env:GEMINI_API_KEY)</code> - בודק את קיומו של המפתח, מסיים את הסקריפט אם הוא חסר.</li>
<li><code>$scriptRoot = Get-Location</code> - מקבל את ספריית העבודה הנוכחית.</li>
<li><code>$HistoryDir = Join-Path...</code> - יוצר את הנתיב לתיקיה לאחסון היסטוריית דיאלוגים (<code>.gemini/.chat_history</code>).</li>
<li><code>$timestamp = Get-Date...</code> - יוצר חותמת זמן בפורמט <code>2025-08-26_14-30-15</code>.</li>
<li><code>$historyFileName = "ai_session_$timestamp.jsonl"</code> - מייצר שם קובץ סשן ייחודי.</li>
<li><code>$historyFilePath = Join-Path...</code> - יוצר את הנתיב המלא לקובץ היסטוריית הסשן הנוכחי.</li>
</ul>

<h2>בדיקת סביבה - מה צריך להיות מותקן</h2>

<pre class="line-numbers"><code class="language-powershell"># --- שלב 2: בדיקת סביבה ---
try { Get-Command gemini -ErrorAction Stop | Out-Null } 
catch { Write-Error "הפקודה 'gemini' לא נמצאה..."; return }

if (-not (Test-Path (Join-Path $scriptRoot ".gemini/GEMINI.md"))) { 
    Write-Warning "קובץ הפרומפט המערכתי .gemini/GEMINI.md לא נמצא..." 
}
if (-not (Test-Path (Join-Path $scriptRoot ".gemini/ShowHelp.md"))) { 
    Write-Warning "קובץ העזרה .gemini/ShowHelp.md לא נמצא..." 
}
</code></pre>

<strong>מה נבדק:</strong>

<ul>
<li>נוכחות <strong>Gemini CLI</strong> במערכת - הסקריפט לא יעבוד בלעדיו.</li>
<li>קובץ <strong>GEMINI.md</strong> - מכיל את הפרומפט המערכתי (הוראות ל-AI).</li>
<li>קובץ <strong>ShowHelp.md</strong> - עזרה למשתמש (פקודת <code>?</code>).</li>
</ul>

<h2>פונקציה ראשית לאינטראקציה עם AI</h2>

<pre class="line-numbers"><code class="language-powershell">function Invoke-GeminiPrompt {
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
</code></pre>

<strong>משימות הפונקציה:</strong>
<ul>
<li>קוראת ל-Gemini CLI עם המודל והפרומפט שצוינו.</li>
<li>לוכדת את כל הפלטים (כולל שגיאות).</li>
<li>מנקה את התוצאה מהודעות שירות של CLI.</li>
<li>מחזירה תגובת AI נקייה או <code>$null</code> במקרה של שגיאה.</li>
</ul>

<h2>פונקציות לניהול היסטוריה</h2>

<pre class="line-numbers"><code class="language-powershell">function Add-History { 
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
</code></pre>

<strong>מטרה:</strong>
<ul>
<li><code>Add-History</code> - שומר זוגות "שאלה-תשובה" בפורמט JSONL.</li>
<li><code>Show-History</code> - מציג את תוכן קובץ ההיסטוריה.</li>
<li><code>Clear-History</code> - מוחק את קובץ היסטוריית הסשן הנוכחי.</li>
</ul>

<h2>פונקציה להצגת נתונים נבחרים</h2>

<pre class="line-numbers"><code class="language-powershell">function Show-SelectionTable {
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
</code></pre>

<strong>משימת הפונקציה:</strong> לאחר בחירת פריטים ב-<code>Out-ConsoleGridView</code>, היא מציגה אותם בקונסולה כטבלה מסודרת, כך שהמשתמש יוכל לראות בדיוק מה נבחר.

<h2>לולאת עבודה ראשית</h2>

<pre class="line-numbers"><code class="language-powershell">while ($true) {
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
</code></pre>

<strong>תכונות עיקריות:</strong>
<ul>
<li>מחוון <code>[בחירה פעילה]</code> מראה שיש נתונים לניתוח.</li>
<li>כל שאילתה כוללת את כל היסטוריית הדיאלוג לשמירת הקשר.</li>
<li>ה-AI מקבל גם את ההיסטוריה וגם את הנתונים שנבחרו על ידי המשתמש.</li>
<li>התוצאה מנסה להיות מוצגת כטבלה אינטראקטיבית.</li>
<li>אם ניתוח JSON נכשל, מוצג טקסט רגיל.</li>
</ul>

<h2>מבנה קבצי עבודה</h2>

<pre><code>├── Find-Spec.ps1
├── .gemini/
│   ├── GEMINI.md              # פרומפט מערכתי ל-AI
│   ├── ShowHelp.md            # עזרה למשתמש
│   └── .chat_history/         # תיקיה עם היסטוריית סשנים
│       ├── ai_session_2025-08-26_10-15-30.jsonl
│       └── ai_session_2025-08-26_14-22-45.jsonl
</code></pre>

<p>קובץ <code>GEMINI.md</code> בתיקיית <code>.gemini/</code> הוא המיקום הסטנדרטי לפרומפט המערכתי עבור Gemini CLI. בכל הפעלה, המודל טוען אוטומטית הוראות מקובץ זה, מה שמגדיר את התנהגותו ופורמט התגובות שלו.</p>

<p>בחלק הבא, נבחן את תוכן קבצי התצורה ודוגמאות שימוש מעשיות.</p>