# כלי כימיה עבור PowerShell (עם Gemini AI)

**כלי כימיה** הוא מודול PowerShell המספק את הפקודה `Start-ChemistryExplorer` לחקירה אינטראקטיבית של יסודות כימיים באמצעות Google Gemini AI.

כלי זה הופך את הקונסולה שלך למדריך חכם, המאפשר לך לשלוף רשימות של יסודות לפי קטגוריות, להציג אותם בטבלה נוחה לסינון (`Out-ConsoleGridView`) ולקבל מידע נוסף על כל אחד מהם.

 *(מומלץ להחליף באנימציית GIF אמיתית של פעולת הסקריפט)*

## 🚀 התקנה והגדרה

### דרישות קדם

1.  **PowerShell 7.2+**.
2.  **Node.js (LTS):** [התקן מכאן](https://nodejs.org/).
3.  **Google Gemini CLI:** ודא שה-CLI מותקן ומאומת.
    ```powershell
    # 1. התקן Gemini CLI
    npm install -g @google/gemini-cli

    # 2. הפעלה ראשונה כדי להיכנס לחשבון Google
    gemini
    ```

### מדריך התקנה שלב אחר שלב

#### שלב 1: צור את מבנה התיקיות הנכון (חובה!)

זהו השלב החשוב ביותר. כדי ש-PowerShell יוכל למצוא את המודול שלך, הוא חייב להיות בתיקייה עם **אותו שם בדיוק** כמו המודול עצמו.

1.  מצא את תיקיית המודולים האישיים שלך ב-PowerShell.
    ```powershell
    # פקודה זו תציג את הנתיב, בדרך כלל C:\Users\שםמשתמש\Documents\PowerShell\Modules
    $moduleBasePath = Split-Path $PROFILE.CurrentUserAllHosts
    $moduleBasePath
    ```2.  צור בתוכה תיקייה עבור המודול שלנו בשם `Chemistry`.
    ```powershell
    $modulePath = Join-Path $moduleBasePath "Chemistry"
    if (-not (Test-Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
    }
    ```
3.  הורד והצב את הקבצים הבאים מהמאגר לתיקייה זו (`Chemistry`):
    *   `Chemistry.psm1` (קוד המודול הראשי)
    *   `Chemistry.GEMINI.md` (קובץ הוראות AI)
    *   `Chemistry.psd1` (קובץ מניפסט, אופציונלי אך מומלץ)

מבנה הקבצים הסופי שלך צריך להיראות כך:
```
...\Documents\PowerShell\Modules\
└── Chemistry\                <-- תיקיית מודול
    ├── Chemistry.psd1        <-- מניפסט (אופציונלי)
    ├── Chemistry.psm1        <-- קוד ראשי
    └── Chemistry.GEMINI.md   <-- הוראות AI
```

#### שלב 2: בטל חסימת קבצים

אם הורדת קבצים מהאינטרנט, Windows עשויה לחסום אותם. הפעל פקודה זו כדי לפתור את הבעיה:
```powershell
Get-ChildItem -Path $modulePath | Unblock-File
```

#### שלב 3: ייבא ובדוק את המודול

הפעל מחדש את PowerShell. המודול אמור להיטען אוטומטית. כדי לוודא שהפקודה זמינה, הפעל:
```powershell
Get-Command -Module Chemistry
```
הפלט אמור להיות:
```
CommandType     Name                    Version    Source
-----------     ----                    -------    ------
Function        Start-ChemistryExplorer 1.0.0      Chemistry
```

## 💡 שימוש

לאחר ההתקנה, פשוט הפעל את הפקודה בקונסולה שלך:
```powershell
Start-ChemistryExplorer
```
הסקריפט יברך אותך ויבקש ממך להזין קטגוריה של יסודות כימיים.
> `מפעיל את מדריך הכימאי האינטראקטיבי...`
> `הזן קטגוריית יסודות (לדוגמה, 'גזים אצילים') או 'יציאה'`
> `> גזים אצילים`

לאחר מכן, יופיע חלון אינטראקטיבי `Out-ConsoleGridView` עם רשימת יסודות. בחר אחד מהם, ו-Gemini יספר לך עליו עובדות מעניינות.

## 🛠️ פתרון בעיות

*   **שגיאה "מודול לא נמצא"**:
    1.  **הפעל מחדש את PowerShell.** זה פותר את הבעיה ב-90% מהמקרים.
    2.  בדוק שוב את **שלב 1**. שם התיקייה (`Chemistry`) ושם הקובץ (`Chemistry.psm1` או `Chemistry.psd1`) חייבים להיות נכונים.

*   **הפקודה `Start-ChemistryExplorer` לא נמצאה לאחר הייבוא**:
    1.  ודא שקובץ `Chemistry.psm1` שלך מכיל את השורה `Export-ModuleMember -Function Start-ChemistryExplorer` בסופו.
    2.  אם אתה משתמש במניפסט (`.psd1`), ודא שהשדה `FunctionsToExport = 'Start-ChemistryExplorer'` מאוכלס בו.
