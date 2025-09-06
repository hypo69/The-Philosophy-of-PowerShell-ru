### אבחון ושחזור דיסקים באמצעות PowerShell

PowerShell מאפשר אוטומציה של בדיקות, ביצוע אבחון מרחוק ויצירת סקריפטים גמישים לניטור. מדריך זה יוביל אתכם מבדיקות בסיסיות ועד לאבחון ושחזור דיסקים מעמיקים.

**גרסה:** המדריך רלוונטי עבור **Windows 10/11** ו-**Windows Server 2016+**.

### פקודות מפתח לעבודה עם דיסקים

| פקודה | מטרה |
| :--- | :--- |
| **`Get-PhysicalDisk`** | מידע על דיסקים פיזיים (דגם, מצב תקינות). |
| **`Get-Disk`** | מידע על דיסקים ברמת ההתקן (סטטוס Online/Offline, סגנון מחיצות). |
| **`Get-Partition`** | מידע על מחיצות בדיסקים. |
| **`Get-Volume`** | מידע על כרכים לוגיים (אותיות כונן, מערכת קבצים, שטח פנוי). |
| **`Repair-Volume`** | בדיקה ושחזור כרכים לוגיים (אנלוגי ל-`chkdsk`). |
| **`Get-StoragePool`** | משמש לעבודה עם מרחבי אחסון (Storage Spaces). |

---

### שלב 1: בדיקה בסיסית של מצב המערכת

התחילו בהערכה כללית של מצב תת-מערכת הדיסקים.

#### הצגת כל הדיסקים המחוברים

הפקודה `Get-Disk` מספקת מידע מסכם על כל הדיסקים שהמערכת ההפעלה רואה.

```powershell
Get-Disk
```

תראו טבלה עם מספרי דיסקים, גודלם, סטטוס (`Online` או `Offline`) וסגנון מחיצות (`MBR` או `GPT`).

**דוגמה:** מצא את כל הדיסקים שנמצאים במצב לא מקוון.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### בדיקת ה"בריאות" הפיזית של הדיסקים

הפקודה `Get-PhysicalDisk` ניגשת למצב החומרה עצמה.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
שימו לב במיוחד לשדה `HealthStatus`. הוא יכול לקבל את הערכים:
*   **Healthy:** הדיסק תקין.
*   **Warning:** יש בעיות, נדרשת תשומת לב (לדוגמה, חריגה מספי S.M.A.R.T.).
*   **Unhealthy:** הדיסק במצב קריטי ועלול לקרוס.

---

### שלב 2: ניתוח ושחזור כרכים לוגיים

לאחר בדיקת המצב הפיזי, נעבור למבנה הלוגי – כרכים ומערכת קבצים.

#### מידע על כרכים לוגיים

הפקודה `Get-Volume` מציגה את כל הכרכים המותקנים במערכת.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

שדות מפתח:
*   `DriveLetter` – אות הכרך (C, D וכו').
*   `FileSystem` – סוג מערכת הקבצים (NTFS, ReFS, FAT32).
*   `HealthStatus` – מצב הכרך.
*   `SizeRemaining` ו-`Size` – שטח פנוי ושטח כולל.

#### בדיקה ושחזור כרך (אנלוגי ל-`chkdsk`)

הפקודה `Repair-Volume` היא תחליף מודרני לכלי השירות `chkdsk`.

**1. בדיקת כרך ללא תיקונים (סריקה בלבד)**

מצב זה בטוח לביצוע במערכת פועלת, הוא רק מחפש שגיאות.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. סריקה מלאה ותיקון שגיאות**

מצב זה אנלוגי ל-`chkdsk C: /f`. הוא חוסם את הכרך בזמן הפעולה, ולכן עבור דיסק מערכת תידרש הפעלה מחדש.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **חשוב:** אם אתם מפעילים פקודה זו עבור דיסק המערכת (C:), PowerShell יתזמן בדיקה בהפעלה הבאה של המערכת. כדי להפעיל אותה מיד, הפעילו מחדש את המחשב.

**דוגמה:** בדוק ותקן אוטומטית את כל הכרכים שמצבם שונה מ-`Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "Repairing volume $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### שלב 3: אבחון מעמיק ו-S.M.A.R.T.

אם בדיקות בסיסיות לא גילו בעיות, אך נותרו חשדות, ניתן לחפור עמוק יותר.

#### ניתוח יומני מערכת

שגיאות בתת-מערכת הדיסקים מתועדות לעיתים קרובות ביומן המערכת של Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
לחיפוש מדויק יותר ניתן לסנן לפי מקור האירוע:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### בדיקת סטטוס S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) – טכנולוגיית אבחון עצמי של דיסקים. PowerShell מאפשר לקבל נתונים אלה.

**שיטה 1: שימוש ב-WMI (לתאימות)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
אם `PredictFailure = True`, הדיסק צופה כשל קרוב. זהו אות להחלפה מיידית.

**שיטה 2: גישה מודרנית באמצעות CIM ומודולי אחסון**

דרך מודרנית ומפורטת יותר היא להשתמש בפקודה `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
פקודה זו מספקת מידע יקר ערך, כגון בלאי (רלוונטי ל-SSD), טמפרטורה ומספר שגיאות קריאה/כתיבה.

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

**4. הפעל אבחון של דיסק המערכת עם הפעלה מחדש לאחר מכן.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```