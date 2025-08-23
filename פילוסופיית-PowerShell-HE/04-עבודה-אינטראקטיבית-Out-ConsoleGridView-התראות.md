# הפילוסופיה של PowerShell.

## חלק 4: עבודה אינטראקטיבית: `Out-ConsoleGridView`, התראות.

- ב[חלק הראשון](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/01.md) הגדרנו שני מושגי מפתח ב-PowerShell: צינור ואובייקט.

- ב[חלק השני](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/02.md) הסברתי מהם אובייקטים וצינורות.

- ב[חלק השלישי](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/03.md) הכרנו את מערכת הקבצים והספקים.

- היום נבחן עבודה אינטראקטיבית עם נתונים בקונסולה, וכן נכיר התראות והודעות.

### פרק ראשון: עבודה אינטראקטיבית עם נתונים בקונסולה.

#### `Out-ConsoleGridView`. ממשק משתמש גרפי בקונסולת PowerShell.


**❗ חשוב:** כל הכלים המתוארים להלן דורשים **PowerShell 7.2 ואילך**.

Out-ConsoleGridView היא טבלה אינטראקטיבית, ישירות בקונסולת PowerShell, המאפשרת:
- להציג נתונים בטבלה;
- לסנן ולמיין עמודות;
- לבחור שורות עם הסמן — כדי להעביר אותן הלאה בצינור.
- ועוד הרבה.

`Out-ConsoleGridView` הוא חלק מהמודול `Microsoft.PowerShell.ConsoleGuiTools`. 
כדי להשתמש בו, עליך להתקין תחילה מודול זה.

כדי להתקין את המודול, הפעל את הפקודה הבאה ב-PowerShell:
```powershell
Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser
```
![Install-Module Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser](assets/04/1.png)

*Install-Module* מוריד ומתקין את המודול שצוין מהמאגר למערכת. 
אנלוגיות: `pip install` ב-`Python` או `npm install` ב-`Node.js`.

📎 פרמטרים עיקריים של *Install-Module*

------------------------------------------------------------------------------------------------------------------------------------------------------
| פרמטר | תיאור |
|---|---|
| `-Name` | שם המודול להתקנה. |
| `-Scope` | היקף ההתקנה: `AllUsers` (ברירת מחדל, דורש הרשאות מנהל) או `CurrentUser` (אינו דורש הרשאות מנהל). |
| `-Repository` | מציין את המאגר, לדוגמה `PSGallery`. |
| `-Force` | התקנה כפויה ללא אישור. |
| `-AllowClobber` | מאפשר לדרוס פקודות קיימות. |
| `-AcceptLicense` | מקבל אוטומטית את רישיון המודול. |
| `-RequiredVersion` | מתקין גרסה ספציפית של המודול. |



לאחר ההתקנה, תוכל להעביר כל פלט ל-`Out-ConsoleGridView` לעבודה אינטראקטיבית.

```powershell   
# דוגמה קלאסית: הצגת רשימת תהליכים בטבלה אינטראקטיבית
Get-Process | Out-ConsoleGridView
```

[1](https://github.com/user-attachments/assets/5828dd51-cfb8-4904-87be-796ccc8395be)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/5828dd51-cfb8-4904-87be-796ccc8395be" type="video/mp4">
  Your browser does not support the video tag.
</video>



**ממשק:**
*   **סינון:** פשוט התחל להקליד, והרשימה תסונן תוך כדי הקלדה.
*   **ניווט:** השתמש במקשי החצים כדי לנווט ברשימה.
*   **בחירה:** לחץ `Space` כדי לבחור/לבטל בחירה של פריט אחד.
*   **בחירה מרובה:** `Ctrl+A` לבחירת כל הפריטים, `Ctrl+D` לביטול בחירת הכל.
*   **אישור:** לחץ `Enter` כדי להחזיר את האובייקטים שנבחרו.
*   **ביטול:** לחץ `ESC` כדי לסגור את החלון מבלי להחזיר נתונים.




## מה `Out-ConsoleGridView` יכול לעשות:

* להציג נתונים טבלאיים ישירות בקונסולת PowerShell כטבלה אינטראקטיבית עם ניווט שורות ועמודות.
* למיין עמודות בלחיצת מקשים.
* לסנן נתונים באמצעות חיפוש.
* לבחור שורה אחת או יותר עם החזרת תוצאה.
* לעבוד בקונסולה נקייה ללא חלונות GUI.
* לתמוך במספר רב של שורות עם גלילה.
* לתמוך בסוגי נתונים שונים (מחרוזות, מספרים, תאריכים וכו').

---

## דוגמאות לשימוש ב-`Out-ConsoleGridView`

### שימוש בסיסי — הצגת טבלה עם יכולת בחירה אינטראקטיבית. (תיבת סימון)

```powershell
Import-Module Microsoft.PowerShell.ConsoleGuiTools

$data = Get-Process | Select-Object -First 30 -Property Id, ProcessName, CPU, WorkingSet

# הצג טבלה עם יכולות סינון, מיון ובחירת שורות
$selected = $data | Out-ConsoleGridView -Title "בחר תהליך(ים)" -OutputMode Multiple

$selected | Format-Table -AutoSize
```

[2](https://github.com/user-attachments/assets/3f1a2a62-066f-4dbb-947a-9b26095da356)

<video>
  <source src="https://github.com/user-attachments/assets/3f1a2a62-066f-4dbb-947a-9b26095da356" type="video/mp4">
  Your browser does not support the video tag.
</video>



רשימת התהליכים מוצגת בטבלת קונסולה אינטראקטיבית. 
ניתן לסנן לפי שם, למיין עמודות ולבחור תהליכים. 
התהליכים שנבחרו מוחזרים למשתנה `$selected`.

---

### בחירת שורה בודדת עם החזרת תוצאה חובה. (רדיו)



```powershell
$choice = Get-Service | Select-Object -First 20 | Out-ConsoleGridView -Title "בחר שירות" -OutputMode Single

Write-Host "בחרת שירות: $($choice.Name)"
```

[](https://github.com/user-attachments/assets/5ee8fb92-8e18-496a-9db7-2d86b243742e)

<video>
  <source src="https://github.com/user-attachments/assets/5ee8fb92-8e18-496a-9db7-2d86b243742e" type="video/mp4">
  Your browser does not support the video tag.
</video>


המשתמש בוחר שורה בודדת (שירות). `-OutputMode Single` מונע בחירות מרובות.

---

### סינון ומיון מערכים גדולים

```powershell
$data = 1..1000 | ForEach-Object { 
    [PSCustomObject]@{ 
        Number = $_ 
        Square = $_ * $_ 
        Cube   = $_ * $_ * $_ 
    } 
}

$data | Out-ConsoleGridView -Title "מספרים וחזקות"  -OutputMode Multiple
```

מציג טבלה של 1000 שורות עם מספרים וחזקותיהם.



### **ניהול תהליכים אינטראקטיבי:**

באפשרותך לבחור מספר תהליכים לעצירה. הפרמטר `-OutputMode Multiple` מציין שאנו רוצים להחזיר את כל הפריטים שנבחרו.



```powershell
# העבר את התוצאות בצינור.
# עצור תהליכים נבחרים עם הפרמטר -WhatIf לתצוגה מקדימה.
# לשם כך, הגדר את המשתנה $procsToStop
$procsToStop = Get-Process | Out-ConsoleGridView -OutputMode Multiple
    
# אם משהו נבחר, העבר את האובייקטים הלאה בצינור
if ($procsToStop) {
    $procsToStop | Stop-Process -WhatIf
}
```

### **בחירת קבצים לארכיון:**
    מצא את כל קבצי ה-.log בתיקייה, בחר את אלה הדרושים וצור מהם ארכיון.

```powershell
$filesToArchive = Get-ChildItem -Path C:\Logs -Filter "*.log" -Recurse | Out-ConsoleGridView -OutputMode Multiple
```

    ❗היזהר עם רקורסיה

```powershell
if ($filesToArchive) {
    Compress-Archive -Path $filesToArchive.FullName -DestinationPath C:\Temp\LogArchive.zip
    
    # הוסף הודעת הצלחה
    Write-Host "✅ ארכיון הושלם בהצלחה!" -ForegroundColor Green
}
```


### **בחירת פריט בודד לניתוח מפורט:**


#### תבנית "Drill-Down" — מרשימה כללית לפרטים עם `Out-ConsoleGridView`

לעתים קרובות בעבודה עם אובייקטים מערכתיים, אנו נתקלים בדילמה:
1.  אם תבקש **את כל המאפיינים** עבור **כל האובייקטים** (`Get-NetAdapter | Format-List *`), הפלט יהיה עצום ולא קריא.
2.  אם תציג **טבלה קצרה**, נאבד פרטים חשובים.
3.  לפעמים ניסיון לקבל את כל הנתונים בבת אחת עלול להוביל לשגיאה אם אחד האובייקטים מכיל ערכים לא חוקיים.

פתרון בעיה זו הוא תבנית **"Drill-Down"** (פירוט או "צלילה לעומק"). מהותה פשוטה:

*   **שלב 1 (סקירה):** הצג למשתמש רשימה נקייה, תמציתית ובטוחה של פריטים ל**בחירה**.
*   **שלב 2 (פירוט):** לאחר שהמשתמש בחר פריט ספציפי אחד, הצג לו **את כל המידע הזמין** עבור פריט מסוים זה.


#### דוגמה מעשית: יצירת סייר מתאמי רשת

בואו ניישם תבנית זו באמצעות הפקודה `Get-NetAdapter` כדוגמה.

**משימה:** תחילה, הצג רשימה קצרה של מתאמי רשת. לאחר בחירת אחד מהם, פתח חלון שני עם כל המאפיינים שלו.

**קוד מוכן:**
```powershell
# --- שלב 1: בחירת מתאם מרשימה קצרה ---
$adapterList = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed
$selectedAdapter = $adapterList | Out-ConsoleGridView -Title "שלב 1: בחר מתאם רשת"

# --- שלב 2: הצגת מידע מפורט או הודעת ביטול ---
if ($null -ne $selectedAdapter) {
    # קבל את כל המאפיינים עבור המתאם הנבחר
    $detailedInfoObject = Get-NetAdapter -Name $selectedAdapter.Name | Select-Object *

    # השתמש בטריק שלנו עם .psobject.Properties כדי להפוך את האובייקט לטבלת "שם-ערך" נוחה
    $detailedInfoForGrid = $detailedInfoObject.psobject.Properties | Select-Object Name, Value
    
    # פתח חלון GridView שני עם מידע מלא
    $detailedInfoForGrid | Out-ConsoleGridView -Title "שלב 2: מידע מלא עבור '$($selectedAdapter.Name)'"
} else {
    Write-Host "הפעולה בוטלה. מתאם לא נבחר." -ForegroundColor Yellow
}
```

#### פירוק שלב אחר שלב

1.  **יצירת רשימה "בטוחה":**
    `$adapterList = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed`
    איננו מעבירים את הפלט של `Get-NetAdapter` ישירות. במקום זאת, אנו יוצרים אובייקטים חדשים, "נקיים" באמצעות `Select-Object`, הכוללים רק את המאפיינים שאנו צריכים לסקירה. זה מבטיח שנתונים בעייתיים שגרמו לשגיאה יושלכו.

2.  **חלון אינטראקטיבי ראשון:**
    `$selectedAdapter = $adapterList | Out-ConsoleGridView ...`
    הסקריפט מציג את החלון הראשון ו**משהה את ביצועו**, ממתין לבחירתך. ברגע שתבחר שורה ותלחץ `Enter`, האובייקט המתאים לשורה זו ייכתב למשתנה `$selectedAdapter`.

3.  **בדיקת הבחירה:**
    `if ($null -ne $selectedAdapter)`
    זוהי בדיקה קריטית חשובה. אם המשתמש ילחץ `Esc` או יסגור את החלון, המשתנה `$selectedAdapter` יהיה ריק (`$null`). בדיקה זו מונעת את ביצוע שאר הקוד והתרחשות שגיאות.

4.  **קבלת מידע מלא:**
    `$detailedInfoObject = Get-NetAdapter -Name $selectedAdapter.Name`
    הנה נקודת המפתח של התבנית. אנו קוראים שוב ל-`Get-NetAdapter`, אך הפעם אנו מבקשים **רק אובייקט אחד** לפי שמו, שלקחנו מהפריט שנבחר בשלב הראשון. כעת אנו מקבלים את האובייקט המלא עם כל מאפייניו.

5.  **טרנספורמציה עבור החלון השני:**
    `$detailedInfoForGrid = $detailedInfoObject.psobject.Properties | ...`
    אנו משתמשים בטריק העוצמתי שאתה כבר מכיר כדי "לפרוס" את האובייקט המורכב הבודד הזה לרשימה ארוכה של זוגות "שם מאפיין" | "ערך", שמתאימה באופן אידיאלי לתצוגה בטבלה.

6.  **חלון אינטראקטיבי שני:**
    `$detailedInfoForGrid | Out-ConsoleGridView ...`
    חלון שני מופיע על המסך, הפעם עם מידע מקיף על המתאם שבחרת.


---



### דוגמה עם כותרת מותאמת אישית ורמזים

הצגת יומן אירועי Windows בטבלה אינטראקטיבית עם הכותרת "אירועי מערכת".

```powershell
Get-EventLog -LogName System -Newest 50 |
    Select-Object TimeGenerated, EntryType, Source, Message |
    Out-ConsoleGridView -Title "System Events"  -OutputMode Multiple
```
קוד זה מאחזר את 50 האירועים האחרונים מיומן המערכת של Windows, בוחר מכל אירוע רק ארבעה מאפייני מפתח (זמן, סוג, מקור והודעה) ומציג אותם בחלון Out-ConsoleGridView.

----

### מידע על המערכת.


[1](https://github.com/user-attachments/assets/1e53a339-56f9-4add-8053-86d94dbc8e06)

<video width="600" controls>
  <source src="https://github.com/user-attachments/assets/1e53a339-56f9-4add-8053-86d94dbc8e06" type="video/mp4">
  Your browser does not support the video tag.
</video>


קוד הסקריפט למידע על המערכת:
[Get-SystemMonitor.ps1](https://github.com/hypo69/The-Philosophy-of-PowerShell-ru/blob/master/code/04/Get-SystemMonitor.ps1)


### יצירת ה-cmdlet 'Get-SystemMonitor'


#### שלב 1: הגדרת משתנה `PATH`

1.  **צור תיקייה קבועה עבור הכלים שלך,** אם עדיין לא עשית זאת. לדוגמה:
    `C:\PowerShell\Scripts`

2.  **הצב את קובץ ה-`Get-SystemMonitor.ps1` שלך** בתיקייה זו.

3.  **הוסף תיקייה זו למשתנה המערכת `PATH`**,

#### שלב 2: הגדרת כינוי בפרופיל PowerShell

כעת, כשהמערכת יודעת היכן למצוא את הסקריפט שלך לפי שמו המלא, אנו יכולים ליצור עבורו כינוי קצר.

1.  **פתח את קובץ פרופיל ה-PowerShell שלך**:
    ```powershell
    notepad $PROFILE
    ```

2.  **הוסף לו את השורה הבאה:**
    ```powershell
    # כינוי עבור צג המערכת
    Set-Alias -Name sysmon -Value "Get-SystemMonitor.ps1"
    ```

    **שים לב לנקודה המרכזית:** מכיוון שהתיקייה עם הסקריפט כבר נמצאת ב-`PATH`, איננו צריכים עוד לציין את הנתיב המלא לקובץ! אנו פשוט מתייחסים לשמו. זה הופך את הפרופיל שלך לנקי ואמין יותר. אם אי פעם תעביר את תיקיית `C:\PowerShell\Scripts`, תצטרך לעדכן רק את משתנה `PATH`, וקובץ הפרופיל שלך יישאר ללא שינוי.

#### הפעל מחדש את PowerShell

סגור **את כל** חלונות ה-PowerShell הפתוחים ופתח חדש. זה הכרחי כדי שהמערכת תחיל את השינויים הן במשתנה `PATH` והן בפרופיל שלך.

---

### תוצאה: מה אתה מקבל

לאחר ביצוע שלבים אלה, תוכל לקרוא לסקריפט שלך **בשתי דרכים מכל מקום במערכת**:

1.  **לפי שם מלא (אמין, לשימוש בסקריפטים אחרים):**
    ```powershell
    Get-SystemMonitor.ps1
    Get-SystemMonitor.ps1 -Resource storage
    ```

2.  **לפי כינוי קצר (נוח, לעבודה אינטראקטיבית):**
    ```powershell
    sysmon
    sysmon -Resource memory
    ```

רשמת בהצלחה את הסקריפט שלך במערכת בצורה המקצועית והגמישה ביותר.


מועיל? הירשם.
אהבת — שים «+»
בהצלחה! 🚀

מאמרים נוספים על PowerShell:
