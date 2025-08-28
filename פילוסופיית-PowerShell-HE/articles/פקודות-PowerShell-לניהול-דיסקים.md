### אבחון ושחזור דיסקים באמצעות PowerShell

PowerShell מאפשר אוטומציה של בדיקות, ביצוע אבחון מרחוק ויצירת סקריפטים גמישים לניטור. מדריך זה יוביל אתכם מבדיקות בסיסיות ועד לאבחון ושחזור דיסקים מעמיקים.

**גרסה:** המדריך רלוונטי עבור **Windows 10/11** ו-**Windows Server 2016+**.

### פקודות PowerShell מרכזיות לעבודה עם דיסקים

| פקודה | ייעוד |
| :--- | :--- |
| **`Get-PhysicalDisk`** | מידע על דיסקים פיזיים (דגם, מצב בריאות). |
| **`Get-Disk`** | מידע על דיסקים ברמת ההתקן (סטטוס Online/Offline, סגנון מחיצות). |
| **`Get-Partition`** | מידע על מחיצות בדיסקים. |
| **`Get-Volume`** | מידע על כוננים לוגיים (אותיות כונן, מערכת קבצים, שטח פנוי). |
| **`Repair-Volume`** | בדיקה ושחזור כוננים לוגיים (אנלוגי ל-`chkdsk`). |
| **`Get-StoragePool`** | משמש לעבודה עם מרחבי אחסון (Storage Spaces). |

---

### שלב 1: בדיקת תקינות מערכת בסיסית

התחילו בהערכה כללית של מצב תת-מערכת הדיסקים.

#### צפייה בכל הדיסקים המחוברים

הפקודה `Get-Disk` מספקת מידע מסכם על כל הדיסקים שהמערכת ההפעלה רואה.

```powershell
Get-Disk
```

תראו טבלה עם מספרי הדיסקים, גודלם, סטטוס (`Online` או `Offline`) וסגנון מחיצות (`MBR` או `GPT`).

**דוגמה:** מצאו את כל הדיסקים שנמצאים במצב לא מקוון.
```powershell
Get-Disk | Where-Object IsOffline -eq $true
```

#### בדיקת "בריאות" פיזית של דיסקים

הפקודה `Get-PhysicalDisk` ניגשת למצב החומרה עצמה.

```powershell
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
```
שימו לב במיוחד לשדה `HealthStatus`. הוא יכול לקבל את הערכים הבאים:
*   **Healthy:** הדיסק תקין.
*   **Warning:** יש בעיות, נדרשת תשומת לב (לדוגמה, חריגה מספי S.M.A.R.T.).
*   **Unhealthy:** הדיסק במצב קריטי ועלול לקרוס.

---

### שלב 2: ניתוח ושחזור כוננים לוגיים

לאחר בדיקת המצב הפיזי, נעבור למבנה הלוגי – כוננים ומערכת קבצים.

#### מידע על כוננים לוגיים

הפקודה `Get-Volume` מציגה את כל הכוננים המותקנים במערכת.

```powershell
Get-Volume | Format-Table DriveLetter, FileSystem, HealthStatus, SizeRemaining, Size
```

שדות מפתח:
*   `DriveLetter` — אות הכונן (C, D וכו').
*   `FileSystem` — סוג מערכת הקבצים (NTFS, ReFS, FAT32).
*   `HealthStatus` — מצב הכונן.
*   `SizeRemaining` ו-`Size` — שטח פנוי ושטח כולל.

#### בדיקה ושחזור כונן (אנלוגי ל-`chkdsk`)

הפקודה `Repair-Volume` – זוהי תחליף מודרני לכלי השירות `chkdsk`.

**1. בדיקת כונן ללא תיקונים (סריקה בלבד)**

מצב זה בטוח לביצוע במערכת פועלת, הוא רק מחפש שגיאות.

```powershell
Repair-Volume -DriveLetter C -Scan
```

**2. סריקה מלאה ותיקון שגיאות**

מצב זה אנלוגי ל-`chkdsk C: /f`. הוא נועל את הכונן בזמן הפעולה, ולכן עבור כונן מערכת תידרש הפעלה מחדש.

```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
```

> ❗️ **חשוב:** אם אתם מפעילים פקודה זו עבור כונן המערכת (C:), PowerShell יתזמן בדיקה בהפעלה הבאה של המערכת. כדי להפעיל אותה מיד, הפעילו מחדש את המחשב.

**דוגמה:** בדקו ותקנו אוטומטית את כל הכוננים שמצבם שונה מ-`Healthy`.

```powershell
Get-Volume | Where-Object {$_.HealthStatus -ne 'Healthy'} | ForEach-Object {
    Write-Host "מתקן כונן $($_.DriveLetter)..."
    Repair-Volume -DriveLetter $_.DriveLetter -OfflineScanAndFix
}
```

---

### שלב 3: אבחון מעמיק ו-S.M.A.R.T.

אם בדיקות בסיסיות לא גילו בעיות, אך נותרו חשדות, ניתן לחפור עמוק יותר.

#### ניתוח יומני מערכת

שגיאות בתת-מערכת הדיסקים נרשמות לעיתים קרובות ביומן המערכת של Windows.

```powershell
Get-WinEvent -LogName System | Where-Object {$_.Message -like "*disk*"} | Select-Object -First 20
```
לחיפוש מדויק יותר ניתן לסנן לפי מקור האירוע:
```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-DiskDiagnostic' -MaxEvents 10
```

#### בדיקת סטטוס S.M.A.R.T.

S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) – טכנולוגיה לאבחון עצמי של דיסקים. PowerShell מאפשר לקבל נתונים אלו.

**שיטה 1: שימוש ב-WMI (לתאימות)**
```powershell
Get-WmiObject -Namespace "root\wmi" -Class MSStorageDriver_FailurePredictStatus
```
אם `PredictFailure = True`, הדיסק מנבא כשל קרוב. זהו אות להחלפה מיידית.

**שיטה 2: גישה מודרנית באמצעות מודולי CIM ו-Storage**

דרך מודרנית ומפורטת יותר – להשתמש בפקודה `Get-StorageReliabilityCounter`.

```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object PhysicalDisk, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal
```
פקודה זו מספקת מידע יקר ערך, כגון בלאי (רלוונטי ל-SSD), טמפרטורה ומספר שגיאות קריאה/כתיבה.

---

### תרחישים מעשיים למנהל מערכת

הנה כמה דוגמאות מוכנות למשימות יומיומיות.

**1. קבלת דוח קצר על תקינות כל הדיסקים הפיזיים.**
```powershell
Get-PhysicalDisk | Format-Table DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus
```

**2. יצירת דוח CSV על שטח פנוי בכל הכוננים.**
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{N='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{N='FreeSpace(GB)';E={[math]::Round($_.SizeRemaining / 1GB, 2)}} | Export-Csv -Path C:\Reports\DiskSpace.csv -NoTypeInformation -Encoding UTF8
```

**3. מצאו את כל המחיצות בדיסק ספציפי (לדוגמה, דיסק 0).**
```powershell
Get-Partition -DiskNumber 0
```

**4. הפעלת אבחון דיסק מערכת עם הפעלה מחדש לאחר מכן.**
```powershell
Repair-Volume -DriveLetter C -OfflineScanAndFix
Restart-Computer -Force
```