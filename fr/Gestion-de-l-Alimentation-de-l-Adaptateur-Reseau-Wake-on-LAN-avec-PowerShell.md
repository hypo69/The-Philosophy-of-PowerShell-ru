# Gestion de l'alimentation de l'adaptateur réseau Wake-on-LAN avec PowerShell.

Un guide détaillé pour configurer Wake-on-LAN avec PowerShell, couvrant les commandes de base et la résolution des problèmes courants résultant des différences de pilotes d'adaptateur réseau.

#### Étape 1 : Identification du périphérique.

Avant de configurer Wake-on-LAN (WOL) pour un adaptateur réseau, vous devez identifier précisément le périphérique avec lequel vous travaillez. Pour ce faire, utilisez une commande PowerShell qui recherche les périphériques par une partie de leur nom (par exemple, "Realtek" ou "Intel").

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object FriendlyName, Status, Class, InstanceId
```
!(../assets/manage-wol/1.png)

Cette commande indique au système :
> "Montrez-moi tous les périphériques dont le nom contient le mot «Realtek», et affichez un tableau pour eux avec quatre colonnes : nom complet, statut, classe et ID système."

1.  **`Get-PnpDevice`** : Récupère une liste complète de tous les périphériques Plug-and-Play.
2.  **`|` (Pipeline)** : Transmet la liste plus loin.
3.  **`Where-Object { ... }`** : Filtre la liste, en ne conservant que les périphériques dont le nom (`FriendlyName`) contient "Realtek".
4.  **`|` (Pipeline)** : Transmet la liste filtrée.
5.  **`Select-Object ...`** : Formate la sortie, en n'affichant que les propriétés nécessaires.

*Trouver le périphérique souhaité et prendre le premier de la liste*

```powershell
$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Realtek*" } | Select-Object -First 1

*Écrire ses propriétés dans des variables*

$DeviceName = $device.FriendlyName
$InstanceId = $device.InstanceId
$pmKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters"
```

#### Étape 2 : Autorisation globale de réveil

La commande `powercfg` donne au périphérique l'autorisation "officielle" de Windows de réveiller le système.
```powershell
powercfg -deviceenablewake $DeviceName
```
Cette commande équivaut à cocher la case "Autoriser ce périphérique à sortir l'ordinateur du mode veille".

Son action inverse — la désactivation :
```powershell
powercfg -devicedisablewake $DeviceName
```
#### Étape 3 : Configuration du pilote.
Les paramètres WOL se trouvent dans les paramètres propres au pilote, qui sont stockés dans le registre. 
Pour cocher la case **"Autoriser uniquement le paquet magique à réveiller l'ordinateur"**, 
utilisez la commande `Set-ItemProperty`.

```powershell
# Définir la propriété
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 1
```
Action inverse — désactivation de WOL (`Value 0`) :
```powershell
Set-ItemProperty -Path $pmKey -Name "*WakeOnMagicPacket" -Value 0
```
> **Problème** Le nom de ce paramètre peut différer selon les fabricants. Par exemple, pour **Intel**, c'est `*WakeOnMagicPacket`, et pour **Realtek** — `WakeOnMagicPacket` (sans `*`). Si le paramètre n'est pas appliqué, vérifiez le nom correct avec la commande `Get-ItemProperty -Path $pmKey` et utilisez-le.

### Étape 4 : Configuration finale via CIM
Pour être entièrement sûr que les paramètres de gestion de l'alimentation sont appliqués correctement, nous utilisons la norme moderne **CIM** (Common Information Model).

```powershell
# Trouver l'objet CIM associé à notre périphérique
$adapterCim = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable | Where-Object { $_.InstanceName -like "*$($instanceId.Split('\')[-1])*" }

# Appliquer les modifications
if ($adapterCim) {
    Set-CimInstance -CimInstance $adapterCim -Property @{ Enable = $true }
}
```

![1](../assets/manage-wol/1.png)

