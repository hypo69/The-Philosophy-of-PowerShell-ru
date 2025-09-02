# Let's Embed AI in PowerShell

#### **What is Gemini CLI?**

I have already talked in detail about **Gemini CLI** in [Gemini CLI: Introduction and First Steps](https://pikabu.ru/series/geminicli_48168). But if you missed it, here's a brief introduction.

In short, **Gemini CLI** is a command-line interface for interacting with Google's AI models. You launch it in your terminal, and it turns into a chat that, unlike web versions, has access to your file system.

**Key features:**
*   **Understands code:** It can analyze your scripts, find errors in them, and suggest fixes.
*   **Generates code:** You can ask it to write a PowerShell script to solve your problem, and it will.
*   **Works with files:** Can read files, create new ones, and make changes to existing ones.
*   **Runs commands:** Can execute shell commands, such as `git` or `npm`.

For our purposes, the most important thing is that Gemini CLI can work in **non-interactive mode**. That is, we can pass it a prompt as a command-line argument, and it will simply return a response, without launching its interactive chat. This is precisely the capability we will use.

#### **Installation and Setup**

To get started, we need to prepare our environment. This is done once.

**Step 1: Install Node.js**
Gemini CLI is an application written in Node.js (a popular environment for JavaScript). So first, we need to install Node.js itself.
1.  Go to the official website: [https://nodejs.org/](https://nodejs.org/)
2.  Download and install the **LTS** version. This is the most stable and recommended option. Just follow the installer instructions.
3.  After installation, open a new PowerShell window and check that everything is working:
    ```powershell
    node -v
    npm -v
    ```
    You should see versions, for example, `v20.12.2` and `10.5.0`.

**Step 2: Install Gemini CLI itself**
Now that we have `npm` (the package manager for Node.js), installing Gemini CLI comes down to one command. Run it in PowerShell:
```powershell
npm install -g @google/gemini-cli
```
The `-g` flag means "global installation," which will make the `gemini` command available from anywhere on your system.

**Step 3: Authentication**
The first time you launch Gemini CLI, it will ask you to sign in to your Google account. This is necessary so that it can use your free quota.
1.  Simply enter the command in PowerShell:
    ```powershell
    gemini
    ```
2.  It will ask you about signing in. Select "Sign in with Google."
3.  Your browser will open a standard Google sign-in window. Sign in to your account and grant the necessary permissions.
4.  After that, you will see a welcome message from Gemini in the console. Congratulations, you are ready to work! You can type `/quit` to exit its chat.

#### **PowerShell Philosophy: The Terrible `Invoke-Expression`**

Before we put everything together, let's get acquainted with one of the most dangerous cmdlets in PowerShell — `Invoke-Expression`, or its short alias `iex`.

`Invoke-Expression` takes a text string and executes it as if it were a command typed in the console.

**Example:**
```powershell
$commandString = "Get-Process -Name 'chrome'"
Invoke-Expression -InputObject $commandString
```
This command will do the same as a simple call to `Get-Process -Name 'chrome'`.

**Why is it dangerous?** Because executing a string that you do not control (for example, obtained from the Internet or from AI) is a huge security hole. If the AI mistakenly or maliciously returns the command `Remove-Item -Path C:\ -Recurse -Force`, `iex` will execute it without hesitation.

For our task—creating a managed and controlled bridge between a natural language query and its execution—it is perfectly suited. We will use it with caution, fully aware of the risks.

#### **Putting it all together: The `Invoke-Gemini` Cmdlet**
Let's write a simple PowerShell function that will allow us to send prompts with a single command.

Copy this code and paste it into your PowerShell window so that it becomes available in the current session.

```powershell
function Invoke-Gemini {
    <#
    .SYNOPSIS
        Sends a text prompt to Gemini CLI and returns its response.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Prompt
    )

    process {
        try {
            # Check if the gemini command is available
            $geminiCommand = Get-Command gemini -ErrorAction Stop
        }
        catch {
            Write-Error "The 'gemini' command was not found. Make sure Gemini CLI is installed."
            return
        }

        Write-Verbose "Sending prompt to Gemini CLI..."
        
        # Run gemini in non-interactive mode with our prompt
        $output = & $geminiCommand.Source -p $Prompt 2>&1

        if (-not $?) {
            Write-Warning "The gemini command finished with an error."
            $output | ForEach-Object { Write-Warning $_.ToString() }
            return
        }

        # Return clean output
        return $output
    }
}
```

#### **Let's try the magic!**


Let's ask it a general question directly from our PowerShell console.

```powershell
Invoke-Gemini -Prompt "Tell me about the five latest trends in machine learning"
```


**Congratulations!** You have just successfully embedded AI in PowerShell.

In the next article, I will tell you how to use Gemini CLI to run scripts and automate tasks.
