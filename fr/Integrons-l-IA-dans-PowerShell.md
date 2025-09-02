# Intégrons l'IA dans PowerShell

#### **Qu'est-ce que Gemini CLI ?**

J'ai déjà parlé en détail de **Gemini CLI** dans [Gemini CLI : Introduction et premiers pas](https://pikabu.ru/series/geminicli_48168). Mais si vous l'avez manqué, voici une brève introduction.

En bref, **Gemini CLI** est une interface de ligne de commande pour interagir avec les modèles d'IA de Google. Vous le lancez dans votre terminal, et il se transforme en un chat qui, contrairement aux versions web, a accès à votre système de fichiers.

**Fonctionnalités clés :**
*   **Comprend le code :** Il peut analyser vos scripts, y trouver des erreurs et suggérer des corrections.
*   **Génère du code :** Vous pouvez lui demander d'écrire un script PowerShell pour résoudre votre problème, et il le fera.
*   **Fonctionne avec les fichiers :** Peut lire des fichiers, en créer de nouveaux et apporter des modifications aux fichiers existants.
*   **Exécute des commandes :** Peut exécuter des commandes shell, telles que `git` ou `npm`.

Pour nos besoins, le plus important est que Gemini CLI peut fonctionner en **mode non interactif**. C'est-à-dire que nous pouvons lui transmettre une invite en tant qu'argument de ligne de commande, et il nous renverra simplement une réponse, sans lancer son chat interactif. C'est précisément cette capacité que nous utiliserons.

#### **Installation et configuration**

Pour commencer, nous devons préparer notre environnement. Cela ne se fait qu'une seule fois.

**Étape 1 : Installation de Node.js**
Gemini CLI est une application écrite en Node.js (un environnement populaire pour JavaScript). Nous devons donc d'abord installer Node.js lui-même.
1.  Rendez-vous sur le site officiel : [https://nodejs.org/](https://nodejs.org/)
2.  Téléchargez et installez la version **LTS**. C'est l'option la plus stable et la plus recommandée. Suivez simplement les instructions de l'installateur.
3.  Après l'installation, ouvrez une nouvelle fenêtre PowerShell et vérifiez que tout fonctionne :
    ```powershell
    node -v
    npm -v
    ```
    Vous devriez voir des versions, par exemple, `v20.12.2` et `10.5.0`.

**Étape 2 : Installation de Gemini CLI lui-même**
Maintenant que nous avons `npm` (le gestionnaire de paquets pour Node.js), l'installation de Gemini CLI se résume à une seule commande. Exécutez-la dans PowerShell :
```powershell
npm install -g @google/gemini-cli
```
Le drapeau `-g` signifie "installation globale", ce qui rendra la commande `gemini` accessible depuis n'importe quel endroit de votre système.

**Étape 3 : Authentification**
La première fois que vous lancerez Gemini CLI, il vous demandera de vous connecter à votre compte Google. C'est nécessaire pour qu'il puisse utiliser votre quota gratuit.
1.  Saisissez simplement la commande dans PowerShell :
    ```powershell
    gemini
    ```
2.  Il vous posera une question sur la connexion. Sélectionnez "Se connecter avec Google".
3.  Votre navigateur ouvrira une fenêtre de connexion Google standard. Connectez-vous à votre compte et accordez les autorisations nécessaires.
4.  Après cela, vous verrez un message de bienvenue de Gemini dans la console. Félicitations, vous êtes prêt à travailler ! Vous pouvez taper `/quit` pour quitter son chat.

#### **Philosophie PowerShell : Le terrible `Invoke-Expression`**

Avant de tout assembler, familiarisons-nous avec l'un des cmdlets les plus dangereux de PowerShell — `Invoke-Expression`, ou son alias court `iex`.

`Invoke-Expression` prend une chaîne de texte et l'exécute comme si c'était une commande tapée dans la console.

**Exemple :**
```powershell
$commandString = "Get-Process -Name 'chrome'"
Invoke-Expression -InputObject $commandString
```
Cette commande fera la même chose qu'un simple appel à `Get-Process -Name 'chrome'`.

**Pourquoi est-il dangereux ?** Parce que l'exécution d'une chaîne que vous ne contrôlez pas (par exemple, obtenue sur Internet ou à partir d'une IA) est une énorme faille de sécurité. Si l'IA renvoie par erreur ou par malveillance la commande `Remove-Item -Path C:\ -Recurse -Force`, `iex` l'exécutera sans hésitation.

Pour notre tâche — créer un pont géré et contrôlé entre une requête en langage naturel et son exécution — il est parfaitement adapté. Nous l'utiliserons avec prudence, en étant pleinement conscients des risques.

#### **Assemblons le tout : Le cmdlet `Invoke-Gemini`**
Écrivons une simple fonction PowerShell qui nous permettra d'envoyer des invites avec une seule commande.

Copiez ce code et collez-le dans votre fenêtre PowerShell afin qu'il devienne disponible dans la session actuelle.

```powershell
function Invoke-Gemini {
    <#
    .SYNOPSIS
        Envoie une invite de texte à Gemini CLI et renvoie sa réponse.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Prompt
    )

    process {
        try {
            # Vérifier si la commande gemini est disponible
            $geminiCommand = Get-Command gemini -ErrorAction Stop
        }
        catch {
            Write-Error "La commande 'gemini' n'a pas été trouvée. Assurez-vous que Gemini CLI est installé."
            return
        }

        Write-Verbose "Envoi de l'invite à Gemini CLI..."
        
        # Exécuter gemini en mode non interactif avec notre invite
        $output = & $geminiCommand.Source -p $Prompt 2>&1

        if (-not $?) {
            Write-Warning "La commande gemini s'est terminée avec une erreur."
            $output | ForEach-Object { Write-Warning $_.ToString() }
            return
        }

        # Renvoyer une sortie propre
        return $output
    }
}
```

#### **Essayons la magie !**


Posons-lui une question générale directement depuis notre console PowerShell.

```powershell
Invoke-Gemini -Prompt "Parlez-moi des cinq dernières tendances en matière d'apprentissage automatique"
```


**Félicitations !** Vous venez d'intégrer avec succès l'IA dans PowerShell.

Dans le prochain article, je vous expliquerai comment utiliser Gemini CLI pour exécuter des scripts et automatiser des tâches.
