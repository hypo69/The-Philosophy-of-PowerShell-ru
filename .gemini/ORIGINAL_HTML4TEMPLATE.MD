<h2>Gemini CLI: Advanced Techniques and Scenario Automation.</h2>
<p>In the first part, we covered the basics: installation, authentication, and executing single commands. Now let's move to the next level. In this part, we will teach Gemini CLI to perform complex, multi-step scenarios that can be saved, reused, and shared with the team. This will turn the tool from a simple assistant into a powerful automation engine.</p>
<h3>Scenario Execution Mechanism</h3>
<p>The key idea is to use <code>.md</code> files as "recipes" or "scenarios" for Gemini. Inside such a file, we describe in natural language the sequence of actions that the AI should perform.</p>
<p>To run a scenario, we will use the built-in <code>ReadFile</code> tool. We will simply ask Gemini to read the file with instructions and execute them.</p>
<p><strong>Main command to run any scenario:</strong></p>
<pre class="line-numbers"><code class="language-text">&gt; Read and execute instructions from the file 'scenario_name.md'</code></pre>
<p>Now let's look at a few useful scenarios.</p>
<p>Create a <code>scenarios</code> directory.</p>
<pre class="line-numbers"><code class="language-bash">/path/to/gemini-cli &gt; mkdir scenarios</code></pre>
<p>in it we will store our scenarios.</p>
<h3>Scenario: "Git Repository Audit"</h3>
<p>This task is familiar to every developer: before starting work, you need to check the current state of the project. Let's create a scenario that will do this for us.</p>
<ol>
<li><strong>In the <code>scenarios</code> directory, create the file <code>git-health-check.md</code></strong> with the following content:</li>
</ol>
<pre class="line-numbers"><code class="language-markdown">You are an experienced Git engineer. Your task is to conduct a full audit of the current repository.

Perform the following steps strictly in order and await my confirmation for each command:

1.  <strong>Check status:</strong> Show me the current repository status to see untracked or modified files. Suggest the command `!git status`.
2.  <strong>Fetch updates:</strong> Get the latest changes from the remote server, but do not apply them. Suggest the command `!git fetch origin`.
3.  <strong>Compare branches:</strong> Show me the difference between my local `main` branch and the remote `origin/main`. Suggest the command `!git log main..origin/main --oneline`.
4.  <strong>Find large files:</strong> Find the 5 largest files in the project that are not in `.git`. Suggest the command `!find . -type f -not -path "./.git/*" -printf "%s %p\n" | sort -rn | head -n 5`.
5.  <strong>Summarize:</strong> Finally, briefly describe the repository's state based on the data obtained.</code></pre>
<ol start="2">
<li><strong>Run the scenario in Gemini CLI:</strong></li>
</ol>
<pre class="line-numbers"><code class="language-text">&gt; Read and execute the 'git-health-check.md' scenario</code></pre>
<p><img src="assets/1.png" alt="1"></p>
<p>In fact, there is no repository in this directory, Gemini will offer to create a new repository.
Gemini CLI will independently correct errors during repository creation, for example, if you forgot to initialize it, it will offer to do so,
as well as current errors during scenario execution</p>
<h2>Step 1: Status Check</h2>
<p><img src="assets/2.png" alt="2"></p>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">&gt;✦ I am an experienced Git engineer. Starting your repository audit.
&gt; Step 1: Status Check
&gt;To check the current repository status and see untracked or modified files, I will execute the command `git status`.</code></pre>
<p>Executing <code>git status</code> command...</p>
<p><img src="assets/3.png" alt="3"></p>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">✦ Error: C:\Users\user\Documents\repos is not a Git repository.

  Please specify which subdirectory I should run the audit in. For example, public_repositories.</code></pre>
<p>We ask to create a new repository.</p>
<p><img src="assets/4.png" alt="4"></p>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">✦ Great, Git repository created. Now I can continue the audit.


  Executing git status to check for untracked files.</code></pre>
<p><img src="assets/5.png" alt="5"></p>
<p>...</p>
<p><img src="assets/6.png" alt="6"></p>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">✦ There are many untracked files and folders in the repository. To continue, I need to add them to the index. I will add all files.</code></pre>
<p><img src="assets/7.png" alt="7"></p>
<p>...</p>
<p><img src="assets/8.png" alt="8"></p>
<p>An error occurred during command execution</p>
<pre class="line-numbers"><code class="language-text">error: pathspec 'commit"' did not match any file(s) known to git</code></pre>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">✦ It seems there was a quote error in the command. I will try again using single quotes for the commit message.</code></pre>
<p><img src="assets/9.png" alt="9"></p>
<p><img src="assets/10.png" alt="10"></p>
<p>This time it worked!</p>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">✦ Great, the first commit was successfully created. Now I will delete the temporary file with the commit message.</code></pre>
<p>Now gemini will delete the temporary file with the commit message.</p>
<p>gemini cli sequentially applies the relevant command ('rm','del')</p>
<p><img src="assets/11.png" alt="11"></p>
<h3>Step 2: Fetching updates</h3>
<p>Since the remote repository does not exist, gemini cli will get an error.
Note that it itself expects an error</p>
<p><img src="assets/12.png" alt="12"></p>
<h3>Step 3: Comparing branches</h3>
<p>Here, too, there will be an error, since the <code>main</code> branch does not exist.</p>
<p><img src="assets/13.png" alt="13"></p>
<h3>Step 4: Finding large files</h3>
<p><img src="assets/14.png" alt="14"></p>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">The `find` command did not work because in Windows you need to use `dir`. Gemini will correct the error itself and suggest the correct command.

Далее gemini cli рассуждает о следующих действиях:
✦ THINK: The user wants me to find the 5 largest files in the project.
  The previous command find . -type f -not -path "./.git/*" -printf "%s %p\n" | sort -rn | head -n 5 failed because find, sort, and head
  are not native Windows commands. I need to use a PowerShell equivalent.

   1. Get all files: Get-ChildItem -Recurse -File
   2. Exclude .git directory: Where-Object { $_.FullName -notlike "*\.git\*" }
   3. Sort by size (descending): Sort-Object -Property Length -Descending
   4. Select the top 5: Select-Object -First 5
   5. Format the output: ForEach-Object { "{0} {1}" -f $_.Length, $_.FullName }

  Let's combine these into a single PowerShell command.It seems that find and head are not available in your Windows environment. I will use PowerShell,
  to perform the same task.</code></pre>
<p><img src="assets/15.png" alt="15"></p>
<p>Failure again</p>
<p>gemini cli continues to reason about what to do next:</p>
<p>Gemini's response:</p>
<pre class="line-numbers"><code class="language-text">
✦ THINK: The user wants to find the 5 largest files.
  The PowerShell command is still not executing correctly. It seems that the pipe | and special characters are being misinterpreted by the
  shell when passed as a single command string.

  I will try to execute the command by first saving the script to a file and then executing the file with PowerShell.

   1. Create a PowerShell script file (find_large_files.ps1).
   2. The content of the script will be: Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notlike "*\.git\*" } | Sort-Object
      -Property Length -Descending | Select-Object -First 5 | Format-Table Length, FullName -AutoSize
   3. Execute the script using powershell -File find_large_files.ps1.
   4. Delete the script file.It seems that passing complex commands to PowerShell directly causes problems. I will create a temporary script file
      PowerShell, execute it, and then delete it.

</code></pre>
<p><img src="assets/16.png" alt="16"></p>
<p>This time it worked!</p>
<h3>Step 5: Summary</h3>
<p>gemini cli summarizes:</p>
<pre class="line-numbers"><code class="language-text"> Repository status:

   * Local repository: Initialized, and all files in the root folder C:\Users\user\Documents\repos were added to the first commit.
   * Remote repository: Not configured. No remote origin, so it is impossible to get updates or compare branches.
   * Large files: Several very large files were found, mainly in the venv and public_repositories subdirectories. The largest of them are
     .lib libraries and .zip archives. It is recommended to add paths containing large binary files (e.g., venv, *.zip) to the .gitignore file,
     to prevent them from being included in the repository.

  Audit completed.</code></pre>
<p><img src="assets/17.png" alt="17"></p>
<hr>
<h3>Scenario: "Docker Environment Cleanup"</h3>
<p>Docker accumulates many unnecessary images, containers, and networks over time. This scenario will help safely clean everything up.</p>
<ol>
<li><strong>Create the file <code>docker-cleanup.md</code></strong>:</li>
</ol>
<pre class="line-numbers"><code class="language-markdown">You are a DevOps engineer responsible for system cleanliness. Your task is to safely clean up the Docker environment.

Proceed step by step:

1.  <strong>Show running containers:</strong> First, list all active containers so I can make sure I don't stop anything important. Suggest `!docker ps`.
2.  <strong>Stop all containers:</strong> After my approval, suggest a command to stop ALL running containers. Command: `!docker stop $(docker ps -q)`.
3.  <strong>Global cleanup:</strong> Now perform a full system cleanup of "dangling" images, stopped containers, unused networks, and build cache. Suggest the safest and most efficient command `!docker system prune -af`.
4.  <strong>Report:</strong> After execution, report how much space was freed, based on the output of the last command.
    </code></pre>
<ol start="2">
<li><strong>Run the scenario in Gemini CLI:</strong></li>
</ol>
<pre class="line-numbers"><code class="language-text">&gt; Read and execute the Docker cleanup scenario from the file 'docker-cleanup.md'</code></pre>
<p><strong>Result:</strong> Gemini will guide you through a safe cleanup process, asking for confirmation at each critical step.</p>
<blockquote>
<p><strong>Gemini's response:</strong></p>
<pre class="line-numbers"><code class="language-text">&gt; Okay, opening Task Scheduler.
&gt;
&gt; Execute `!taskschd.msc`? (y/n)
&gt; </code></pre>
</blockquote>
<p>After confirmation, the standard Windows utility will open on your screen.</p>
<h3>Scenario: "Launching System Applications"</h3>
<p>As shown in the example, Gemini handles launching applications perfectly. Let's formalize this into a simple scenario for Windows.</p>
<ol>
<li><strong>Create the file <code>open-windows-tools.md</code></strong>:</li>
</ol>
<pre class="line-numbers"><code class="language-markdown">You are a Windows system administrator. Your task is to open system utilities on request.

- If I ask for "task scheduler", suggest launching `!taskschd.msc`.
- If I ask for "registry editor", warn about the danger and suggest launching `!regedit`.
- If I ask for "resource monitor", suggest launching `!resmon`.
- If I ask for "task manager", suggest launching `!taskmgr`.
- If I ask for "command prompt", suggest launching `!cmd`.
- If I ask for "explorer", suggest launching `!explorer`.
Similarly for other utilities.</code></pre>
<ol start="2">
<li><strong>Run the scenario and give the command:</strong></li>
</ol>
<pre class="line-numbers"><code class="language-text">&gt; Use instructions from 'open-windows-tools.md'. Open task scheduler.</code></pre>
<p><strong>Result:</strong> Gemini will understand the context from the file and your request, and then suggest executing the necessary command.</p>
<blockquote>
<p><strong>Gemini's response:</strong></p>
<pre class="line-numbers"><code class="language-text">&gt; Okay, opening Task Scheduler.
&gt;
&gt; Execute `!taskschd.msc`? (y/n)
&gt; </code></pre>
</blockquote>
<p>After confirmation, the standard Windows utility will open on your screen.</p>
