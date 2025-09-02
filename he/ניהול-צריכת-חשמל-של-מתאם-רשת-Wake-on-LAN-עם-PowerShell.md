# ניהול צריכת חשמל של מתאם רשת Wake-on-LAN עם PowerShell.

מדריך מפורט להגדרת Wake-on-LAN באמצעות PowerShell, הכולל פקודות בסיסיות ודרכים לפתרון בעיות אופייניות הנובעות מהבדלים במנהלי התקנים של מתאמי רשת.

#### שלב 1: זיהוי התקן.

לפני הגדרת Wake-on-LAN (WOL) עבור מתאם רשת, עליך לזהות במדויק את ההתקן שאיתו אתה עובד. לשם כך, השתמש בפקודת PowerShell המחפשת התקנים לפי חלק משמם (לדוגמה, "Realtek" או "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

פקודה זו אומרת למערכת:
> "הצג לי את כל ההתקנים ששמם מכיל את המילה «Realtek», והצג עבורם טבלה עם ארבע עמודות: שם מלא, סטטוס, מחלקה ומזהה מערכת."

1.  **`Get-PnpDevice`**: מאחזר רשימה מלאה של כל התקני Plug-and-Play.
2.  **`|` (צינור)**: מעביר את הרשימה הלאה.
3.  **`Where-Object { ... }`**: מסנן את הרשימה, ומשאיר רק התקנים ששמם (`FriendlyName`) מכיל "Realtek".
4.  **`|` (צינור)**: מעביר את הרשימה המסוננת.
5.  **`Select-Object ...`**: מעצב את הפלט, ומציג רק את המאפיינים הדרושים.

*מצא את ההתקן הרצוי וקח את הראשון מהרשימה*

```powershell
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*כתוב את מאפייניו למשתנים*

$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### שלב 2: הרשאה גלובלית להפעלה

הפקודה `powercfg` מעניקה להתקן הרשאה "רשמית" מ-Windows להעיר את המערכת.
```powershell
powercfg -deviceenablewake $DeviceName
```
פקודה זו שקולה לסימון התיבה "אפשר להתקן זה להעיר את המחשב ממצב שינה".

פעולתה ההפוכה — ביטול:
```powershell
powercfg -devicedisablewake $DeviceName
```
#### שלב 3: הגדרת מנהל התקן.
הגדרות WOL נמצאות בפרמטרים של מנהל ההתקן עצמו, המאוחסנים ברישום. 
כדי לסמן את תיבת הסימון **"אפשר רק לחבילת קסם להעיר את המחשב ממצב שינה"**, 
השתמש בפקודה `Set-ItemProperty`.

```powershell
# הגדר את המאפיין
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
פעולה הפוכה — ביטול WOL (`Value 0`):
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **בעיה** שם פרמטר זה עשוי להשתנות בין יצרנים. לדוגמה, עבור **Intel** הוא `*WakeOnMagicPacket`, ועבור **Realtek** — `WakeOnMagicPacket` (ללא `*`). אם ההגדרה אינה מיושמת, בדוק את השם הנכון באמצעות הפקודה `Get-ItemProperty -Path $pmKey` והשתמש בו.

### שלב 4: תצורה סופית באמצעות CIM
כדי להיות בטוח לחלוטין שהגדרות ניהול צריכת החשמל מיושמות כהלכה, אנו משתמשים בתקן המודרני **CIM** (Common Information Model).

```powershell
# מצא את אובייקט ה-CIM המשויך להתקן שלנו
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# החל עליו שינויים
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

![1](../assets/manage-wol/1.png)

```