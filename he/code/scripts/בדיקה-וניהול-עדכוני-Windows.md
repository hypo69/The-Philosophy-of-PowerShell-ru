בדיקה וניהול עדכוני Windows היא משימה חשובה לשמירה על אבטחת המערכת ויציבותה.
לרוע המזל, ל-PowerShell הסטנדרטי אין פקודות מובנות לכך. אבל יש מודול צד שלישי מצוין בשם **`PSWindowsUpdate`**, שהפך לסוג של סטנדרט.

בעזרת Gemini CLI, אנו יכולים ליצור סקריפט המשתמש במודול זה לביצוע כל הפעולות הנדרשות.

### **שלב 1: התקן את המודול `PSWindowsUpdate`**

לפני הפעלת הסקריפט, עליך להתקין מודול זה. זה נעשה פעם אחת.

פתח את PowerShell כמנהל מערכת והפעל את הפקודה הבאה:

```powershell
Install-Module -Name PSWindowsUpdate
```

אם אתה רואה שגיאה ש"PowerShellGet" מיושן, או אזהרה לגבי "מאגר מהימן", פשוט עקוב אחר ההוראות בקונסולה. סביר להניח שתצטרך לאשר את ההתקנה.

### **שלב 2: סקריפט לבדיקה והתקנת עדכונים**

לאחר התקנת המודול, תוכל להשתמש בסקריפט זה כדי לבדוק אם קיימים עדכונים, ובמידת הצורך, להתקין אותם.

**תרחיש:** ברצונך לבדוק במהירות אם קיימים עדכוני Windows חדשים ולקבל דוח.

**פקודה שתוכל להשתמש בה ב-Gemini CLI:**

```powershell
gemini-cli "כתוב סקריפט PowerShell המשתמש במודול PSWindowsUpdate. הסקריפט צריך לבדוק אם קיימים עדכוני Windows זמינים, להציג רשימה שלהם, ולאחר מכן, אם נמצאו עדכונים, לבקש מהמשתמש להתקין אותם."
```

**דוגמה לסקריפט שנוצר:**

```powershell
# Requires -Module PSWindowsUpdate

Write-Host "--- בדיקה והתקנת עדכוני Windows ---" -ForegroundColor Green

# 1. בדיקת זמינות עדכונים
Write-Host "`nבדיקת עדכונים זמינים..." -ForegroundColor Yellow
$availableUpdates = Get-WUList

if ($availableUpdates.Count -eq 0) {
    Write-Host "`nלא נמצאו עדכונים. המערכת שלך מעודכנת." -ForegroundColor Green
} else {
    Write-Host "`nנמצאו העדכונים הבאים:" -ForegroundColor Yellow
    $availableUpdates | Format-Table -AutoSize

    # 2. הצעה להתקנת עדכונים
    $installChoice = Read-Host "`nהתקן עדכונים שנמצאו? (Y/N)"

    if ($installChoice -eq 'Y' -or $installChoice -eq 'y') {
        Write-Host "`nהפעלת התקנת עדכונים..." -ForegroundColor Yellow
        
        # הורדה והתקנת עדכונים
        Install-WindowsUpdate -AcceptAll -AutoReboot
        
        Write-Host "`nתהליך ההתקנה הושלם. ייתכן שתידרש הפעלה מחדש." -ForegroundColor Green
    } else {
        Write-Host "`nההתקנה בוטלה. עדכונים לא יותקנו." -ForegroundColor Red
    }
}

Write-Host "`n--- הושלם ---" -ForegroundColor Green
```

### איך זה עובד?

  * **`Get-WUList`**: זוהי פקודה מרכזית מהמודול `PSWindowsUpdate`. היא מחפשת עדכונים זמינים בדיוק כמו מרכז העדכונים הסטנדרטי של Windows.
  * **`Read-Host`**: פקודה זו מאפשרת לסקריפט ליצור אינטראקציה איתך, ולבקש אישור לפני התקנת עדכונים.
  * **`Install-WindowsUpdate -AcceptAll -AutoReboot`**: אם תסכים, פקודה זו תתחיל את תהליך ההתקנה.
      * `-AcceptAll`: מסכים אוטומטית להסכמי רישיון.
      * `-AutoReboot`: מפעיל מחדש את המחשב באופן אוטומטי אם יש צורך בכך להשלמת ההתקנה. תוכל להסיר דגל זה אם ברצונך להפעיל מחדש ידנית.

סקריפט זה מעניק לך שליטה מלאה על תהליך עדכון Windows, מה שהופך אותו לכלי מצוין לניהול מערכת.
