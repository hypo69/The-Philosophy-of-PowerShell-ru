### אבחון ושחזור דיסקים באמצעות PowerShell

PowerShell מאפשר לך לאטמט בדיקות, לבצע אבחון מרחוק וליצור סקריפטים גמישים לניטור. מדריך זה יוביל אותך מבדיקות בסיסיות ועד לאבחון ושחזור דיסקים מעמיקים.

**גרסה:** המדריך רלוונטי עבור **Windows 10/11** ו-**Windows Server 2016+**.

### Cmdlets מפתח לניהול דיסקים

| Cmdlet | מטרה |
| :--- | :--- |
| **`Get-PhysicalDisk`** | מידע על דיסקים פיזיים (דגם, מצב תקינות). |
| **`Get-Disk`** | מידע על דיסקים ברמת ההתקן (סטטוס מקוון/לא מקוון, סגנון מחיצות). |
| **`Get-Partition`** | מידע על מחיצות בדיסקים. |
| **`Get-Volume`** | מידע על כרכים לוגיים (אותיות כונן, מערכת קבצים, שטח פנוי). |
| **`Repair-Volume`** | בדיקה ותיקון כרכים לוגיים (אנלוגי ל-`chkdsk`). |
| **`Get-StoragePool`** | משמש לעבודה עם מרחבי אחסון (Storage Spaces). |

---

### שלב 1: בדיקת תקינות מערכת בסיסית

התחל בהערכה כללית של תקינות תת-מערכת הדיסקים.

#### הצגת כל הדיסקים המחוברים

הפקודה `Get-Disk` מספקת מידע מסכם על כל הדיסקים שהמערכת ההפעלה רואה.

```powershell
Get-Disk
```

תראה טבלה עם מספרי דיסקים, גודלם, סטטוס (`Online` או `Offline`) וסגנון מחיצות (`MBR` או `GPT`).

**דוגמה:** מצא את כל הדיסקים שנמצאים במצב לא מקוון.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### בדיקת תקינות דיסק פיזי

ה-cmdlet `Get-PhysicalDisk` ניגש למצב החומרה עצמה.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
שים לב במיוחד לשדה `HealthStatus`. הוא יכול לקבל את הערכים הבאים:
*   **Healthy:** הדיסק תקין.
*   **Warning:** יש בעיות, נדרשת תשומת לב (לדוגמה, חריגה מספי S.M.A.R.T.).
*   **Unhealthy:** הדיסק במצב קריטי ועלול לקרוס.

---

### שלב 2: ניתוח ושחזור כרכים לוגיים

לאחר בדיקת המצב הפיזי, אנו עוברים למבנה הלוגי — כרכים ומערכת הקבצים.

#### מידע על כרכים לוגיים

הפקודה `Get-Volume` מציגה את כל הכרכים המותקנים במערכת.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

שדות מפתח:
*   `DriveLetter` — אות הכרך (C, D וכו').
*   `FileSystem` — סוג מערכת הקבצים (NTFS, ReFS, FAT32).
*   `HealthStatus` — מצב הכרך.
*   `SizeRemaining` ו-`Size` — שטח פנוי ושטח כולל.

#### בדיקה ותיקון כרך (אנלוגי ל-`chkdsk`)

ה-cmdlet `Repair-Volume` הוא תחליף מודרני לכלי השירות `chkdsk`.

**1. בדיקת כרך ללא תיקונים (סריקה בלבד)**

מצב זה בטוח להפעלה במערכת פועלת; הוא רק מחפש שגיאות.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. סריקה מלאה ותיקון שגיאות**

מצב זה אנלוגי ל-`chkdsk C: /f`. הוא נועל את הכרך במהלך הפעולה, ולכן עבור כונן המערכת תידרש הפעלה מחדש.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **חשוב:** אם אתה מפעיל פקודה זו עבור כונן המערכת (C:), PowerShell יתזמן בדיקה בהפעלה הבאה של המערכת. כדי להפעיל אותה מיד, הפעל מחדש את המחשב.

**דוגמה:** בדוק ותקן אוטומטית את כל הכרכים שמצבם אינו `Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "מתקן כרך $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### שלב 3: אבחון מעמיק ו-S.M.A.R.T.

אם בדיקות בסיסיות לא גילו בעיות, אך נותרו חשדות, תוכל לחפור עמוק יותר.

#### ניתוח יומני מערכת

שגיאות בתת-מערכת הדיסקים נרשמות לעתים קרובות ביומן המערכת של Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
לחיפוש מדויק יותר ניתן לסנן לפי מקור האירוע:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### בדיקת סטטוס S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) — טכנולוגיית אבחון עצמי של דיסקים. PowerShell מאפשר לך לקבל נתונים אלה.

**שיטה 1: שימוש ב-WMI (לתאימות)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
אם `PredictFailure = True`, הדיסק מנבא כשל קרוב. זהו אות להחלפה מיידית.

**שיטה 2: גישה מודרנית באמצעות CIM ומודולי Storage**

דרך מודרנית ומפורטת יותר היא להשתמש ב-cmdlet `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
cmdlet זה מספק מידע יקר ערך כגון בלאי (רלוונטי עבור SSD), טמפרטורה ומספר שגיאות קריאה/כתיבה.

---

### תרחישים מעשיים למנהל מערכת

הנה כמה דוגמאות מוכנות למשימות יומיומיות.

**1. קבל דוח קצר על תקינות כל הדיסקים הפיזיים.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. צור דוח CSV על שטח פנוי בכל הכרכים.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. מצא את כל המחיצות בדיסק ספציפי (לדוגמה, דיסק 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. הפעל אבחון דיסק מערכת עם הפעלה מחדש לאחר מכן.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```
