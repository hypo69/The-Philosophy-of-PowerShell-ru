# Gestione dell'alimentazione dell'adattatore di rete Wake-on-LAN con PowerShell.

Una guida dettagliata alla configurazione di Wake-on-LAN (WOL) con PowerShell, che esamina i comandi principali e i modi per risolvere i problemi tipici che sorgono a causa delle differenze nei driver degli adattatori di rete.

#### Passaggio 1: Identificazione del dispositivo.

Prima di configurare Wake-on-LAN (WOL) per un adattatore di rete, è necessario determinare esattamente con quale dispositivo stiamo lavorando. A tale scopo, utilizzeremo un comando PowerShell che cerca i dispositivi in base a una parte del nome (ad esempio, "Realtek" o "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

Questo comando dice al sistema:
> "Mostrami tutti i dispositivi il cui nome contiene la parola «Realtek», e visualizza una tabella con quattro colonne: nome completo, stato, classe e ID di sistema."

1.  **`Get-PnpDevice`**: Ottiene un elenco completo di tutti i dispositivi Plug-and-Play.
2.  **`|` (Pipeline)**: Passa l'elenco in avanti.
3.  **`Where-Object { ... }`**: Filtra l'elenco, lasciando solo i dispositivi il cui nome (`FriendlyName`) contiene "Realtek".
4.  **`|` (Pipeline)**: Passa l'elenco filtrato.
5.  **`Select-Object ...`**: Formatta l'output, mostrando solo le proprietà necessarie.

*Troviamo il dispositivo desiderato e prendiamo il primo dall'elenco*

```powershell
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*Registriamo le sue proprietà nelle variabili*

$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### Passaggio 2: Autorizzazione globale al risveglio

Il comando `powercfg` concede al dispositivo l'autorizzazione "ufficiale" da Windows per risvegliare il sistema.
```powershell
powercfg -deviceenablewake $DeviceName
```
Questo comando è equivalente a spuntare la casella "Consenti a questo dispositivo di riattivare il computer dalla modalità di sospensione".

La sua azione inversa è la disabilitazione:
```powershell
powercfg -devicedisablewake $DeviceName
```
#### Passaggio 3: Configurazione del driver.
Le impostazioni WOL si trovano nei parametri del driver stesso, che sono memorizzati nel registro.
Per impostare la casella di controllo **"Consenti solo al pacchetto magico di riattivare il computer dalla modalità di sospensione"**,
utilizziamo il comando `Set-ItemProperty`.

```powershell
# Impostiamo la proprietà
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
L'azione inversa è la disabilitazione di WOL (`Value 0`):
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **Problema** Il nome di questo parametro può variare a seconda del produttore. Ad esempio, per **Intel** è `*WakeOnMagicPacket`, mentre per **Realtek** è `WakeOnMagicPacket` (senza `*`). Se l'impostazione non viene applicata, verificare il nome corretto con il comando `Get-ItemProperty -Path $pmKey` e utilizzarlo.

### Passaggio 4: Configurazione finale tramite CIM
Per la piena certezza che le impostazioni di gestione dell'alimentazione siano state applicate correttamente, utilizziamo lo standard moderno **CIM** (Common Information Model).

```powershell
# Troviamo l'oggetto CIM associato al nostro dispositivo
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# Applichiamo le modifiche ad esso
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

!(../assets/manage-wol/1.png)
```