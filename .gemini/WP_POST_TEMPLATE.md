[:en]<!-- wp:paragraph -->
<p>In<a href="https://davidka.net/gemini-cli-introduction-and-first-steps/" data-type="link" data-id="https://davidka.net/gemini-cli-introduction-and-first-steps/" target="_blank" rel="noreferrer noopener"> the previous part</a>, we covered the basics: installation, authentication, and executing single commands. Now, let's move to the next level. In this part, we will teach Gemini CLI to execute complex, multi-step scenarios that can be saved, reused, and shared with the team. This will turn the tool from a simple assistant into a powerful automation engine.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Scenario Execution Mechanism</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>The key idea is to use <code>.md</code> files as "recipes" or "scenarios" for Gemini. Inside such a file, we describe in natural language the sequence of actions that the AI should perform.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>To run a scenario, we will use the built-in <code>ReadFile</code> tool. We will simply ask Gemini to read the instruction file and execute them.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>The basic command to run any scenario:</strong></p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>&gt; Read and execute the instructions from the file 'scenario_name.md'
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>Now let's look at a few useful scenarios.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Create a <code>scenarios</code> directory.</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>/path/to/gemini-cli &gt; mkdir scenarios
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>in which we will store our scenarios.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Scenario: "Git Repository Audit"</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>This task is familiar to every developer: before starting work, you need to check the current state of the project. Let's create a scenario that will do this for us.</p>
<!-- /wp:paragraph -->

<!-- wp:list {"ordered":true} -->
<ol class="wp-block-list"><!-- wp:list-item -->
<li><strong>In the <code>scenarios</code> directory, create a <code>git-health-check.md</code> file</strong> with the following content:</li>
<!-- /wp:list-item --></ol>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>    You are an experienced Git engineer. Your task is to conduct a full audit of the current repository. 

    Follow these steps strictly in order and wait for my confirmation for each command:

    1.  <strong>Check status:</strong> Show me the current status of the repository to see untracked or modified files. Suggest the command `!git status`.
    2.  <strong>Fetch updates:</strong> Get the latest changes from the remote server, but do not apply them. Suggest the command `!git fetch origin`.
    3.  <strong>Compare branches:</strong> Show me the difference between my local `main` branch and the remote `origin/main`. Suggest the command `!git log main..origin/main --oneline`.
    4.  <strong>Find large files:</strong> Find the 5 largest files in the project that are not in `.git`. Suggest the command `!find . -type f -not -path "./.git/*" -printf "%s %p\n" | sort -rn | head -n 5`.
    5.  <strong>Summarize:</strong> At the end, briefly describe the state of the repository based on the data obtained.
</code></pre>
<!-- /wp:code -->

<!-- wp:list {"ordered":true,"start":2} -->
<ol start="2" class="wp-block-list"><!-- wp:list-item -->
<li><strong>Run the scenario in Gemini CLI:</strong></li>
<!-- /wp:list-item --></ol>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>&gt; Read and execute the 'git-health-check.md' script
</code></pre>
<!-- /wp:code -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/1.png" alt="1"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>In fact, there is no repository in this directory, Gemini will offer to create a new repository. Gemini CLI will independently correct errors during the creation of the repository, for example, if you forgot to initialize it, it will offer to do so, as well as current errors during the execution of the script</p>
<!-- /wp:paragraph -->

<!-- wp:heading -->
<h2 class="wp-block-heading">Step 1: Status Check</h2>
<!-- /wp:heading -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/2.png" alt="2"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>&gt;✦ I am an experienced Git engineer. Starting the audit of your repository.
&gt; Step 1: Status Check
&gt;To check the current status of the repository and see untracked or modified files, I will execute the command `git status`.
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>Executing the <code>git status</code> command...</p>
<!-- /wp:paragraph -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/3.png" alt="3"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>✦ Error: C:\Users\user\Documents\repos is not a Git repository.

  Please specify in which of the subdirectories I should run the audit. For example, public_repositories.
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>We ask to create a new repository.</p>
<!-- /wp:paragraph -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/4.png" alt="4"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>✦ Excellent, the Git repository has been created. Now I can continue the audit.


  Running git status to check for untracked files.
</code></pre>
<!-- /wp:code -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/5.png" alt="5"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>...</p>
<!-- /wp:paragraph -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/6.png" alt="6"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>✦ There are many untracked files and folders in the repository. To continue, I need to add them to the index. I will add all the files.
</code></pre>
<!-- /wp:code -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/7.png" alt="7"/></figure>
<!-- /wp:image -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/8.png" alt="8"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>An error occurred during the execution of the command</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>error: pathspec "commit"" did not match any file(s) known to git
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>✦ It seems there was an error with the quotes in the command. I will try again, using single quotes for the commit message.
</code></pre>
<!-- /wp:code -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/9.png" alt="9"/></figure>
<!-- /wp:image -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/10.png" alt="10"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>This time it worked!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>✦ Excellent, the first commit has been successfully created. Now I will delete the temporary file with the commit message.
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>Now gemini will delete the temporary file with the commit message.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>gemini cli applies the relevant command in turn ('rm','del')</p>
<!-- /wp:paragraph -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/11.png" alt="11"/></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Step 2: Fetching updates</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Since the remote repository does not exist, gemini cli will get an error. Note that it expects an error itself</p>
<!-- /wp:paragraph -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/12.png" alt="12"/></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Step 3: Comparing branches</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>There will also be an error here, since the <code>main</code> branch does not exist.</p>
<!-- /wp:paragraph -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/13.png" alt="13"/></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Step 4: Finding large files</h3>
<!-- /wp:heading -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/14.png" alt="14"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>The `find` command did not work because in Windows you need to use `dir`. Gemini will correct the error itself and suggest the correct command.

Next, gemini cli discusses the next steps:
✦ THINK: The user wants me to find the 5 largest files in the project.
  The previous command find . -type f -not -path "./.git/*" -printf "%s %p\n" | sort -rn | head -n 5 failed because find, sort, and head
  are not native Windows commands. I need to use a PowerShell equivalent.

   1. Get all files: Get-ChildItem -Recurse -File
   2. Exclude .git directory: Where-Object { $_.FullName -notlike "*.git\*" }
   3. Sort by size (descending): Sort-Object -Property Length -Descending
   4. Select the top 5: Select-Object -First 5
   5. Format the output: ForEach-Object { "{0} {1}" -f $_.Length, $_.FullName }

  Let's combine these into a single PowerShell command.It seems that find and head are not available in your Windows environment. I will use PowerShell,
  to perform the same task.
</code></pre>
<!-- /wp:code -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/15.png" alt="15"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Failure again</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Gemini cli continues to reason about what to do next: Gemini's response:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code> ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
✦ THINK: The user wants to find the 5 largest files.
  The PowerShell command is still not executing correctly. It seems that the pipe | and special characters are being misinterpreted by the
  shell when passed as a single command string.

  I will try to execute the command by first saving the script to a file and then executing the file with PowerShell.

   1. Create a PowerShell script file (find_large_files.ps1).
   2. The content of the script will be: Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notlike "*.git\*" } | Sort-Object
      -Property Length -Descending | Select-Object -First 5 | Format-Table Length, FullName -AutoSize
   3. Execute the script using powershell -File find_large_files.ps1.
   4. Delete the script file.It seems that passing complex commands to PowerShell directly causes problems. I will create a temporary PowerShell script file,
      execute it, and then delete it.

</code></pre>
<!-- /wp:code -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/16.png" alt="16"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>This time everything worked!</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Step 5: Summary</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>gemini cli summarizes:</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code> Repository status:

   * Local repository: Initialized, and all files in the root folder C:\Users\user\Documents\repos have been added to the first commit.
   * Remote repository: Not configured. There is no remote origin, so it is not possible to get updates or compare branches.
   * Large files: Several very large files were found, mainly in the venv and public_repositories subdirectories. The largest of them are
     .lib libraries and .zip archives. It is recommended to add paths containing large binary files (e.g., venv, *.zip) to the .gitignore file,
     to avoid them getting into the repository.

  The audit is complete.
</code></pre>
<!-- /wp:code -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="assets/17.png" alt="17"/></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Scenario: "Cleaning up the Docker environment"</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Over time, Docker accumulates many unnecessary images, containers, and networks. This scenario will help you clean up everything safely.</p>
<!-- /wp:paragraph -->

<!-- wp:list {"ordered":true} -->
<ol class="wp-block-list"><!-- wp:list-item -->
<li><strong>Create a <code>docker-cleanup.md</code> file</strong>:</li>
<!-- /wp:list-item --></ol>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>    You are a DevOps engineer responsible for system cleanliness. Your task is to safely clean up the Docker environment.

    Follow these steps:

    1.  <strong>Show running containers:</strong> First, list all active containers so I can make sure I don't stop anything important. Suggest `!docker ps`.
    2.  <strong>Stop all containers:</strong> After my approval, suggest a command to stop ALL running containers. The command is: `!docker stop $(docker ps -q)`.
    3.  <strong>Global cleanup:</strong> Now perform a full system cleanup of dangling images, stopped containers, unused networks, and the build cache. Suggest the safest and most effective command `!docker system prune -af`.
    4.  <strong>Report:</strong> After execution, report how much space was freed, based on the output of the last command.
</code></pre>
<!-- /wp:code -->

<!-- wp:list {"ordered":true,"start":2} -->
<ol start="2" class="wp-block-list"><!-- wp:list-item -->
<li><strong>Run the scenario in Gemini CLI:</strong></li>
<!-- /wp:list-item --></ol>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>&gt; Read and execute the Docker cleanup script from the file 'docker-cleanup.md'
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p><strong>Result:</strong> Gemini will guide you through a safe cleanup process, asking for confirmation at each critical step.</p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity"/>
<!-- /wp:separator -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Scenario: "Launching system applications"</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>As shown in the example, Gemini is great at launching applications. Let's formalize this as a simple scenario for Windows.</p>
<!-- /wp:paragraph -->

<!-- wp:list {"ordered":true} -->
<ol class="wp-block-list"><!-- wp:list-item -->
<li><strong>Create an <code>open-windows-tools.md</code> file</strong>:</li>
<!-- /wp:list-item --></ol>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>    You are a Windows system administrator. Your task is to open system utilities on request.

    - If I ask for "task scheduler", suggest running `!taskschd.msc`.
    - If I ask for "registry editor", warn about the danger and suggest running `!regedit`.
    - If I ask for "resource monitor", suggest running `!resmon`.
    - If I ask for "task manager", suggest running `!taskmgr`.
    - If I ask for "command prompt", suggest running `!cmd`.
    - If I ask for "explorer", suggest running `!explorer`.
    Similarly for other utilities.
</code></pre>
<!-- /wp:code -->

<!-- wp:list {"ordered":true,"start":2} -->
<ol start="2" class="wp-block-list"><!-- wp:list-item -->
<li><strong>Run the scenario and give a command:</strong></li>
<!-- /wp:list-item --></ol>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>&gt; Use the instructions from 'open-windows-tools.md'. Open the task scheduler.
</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p><strong>Result:</strong> Gemini will understand the context from the file and your request, and then suggest executing the necessary command.</p>
<!-- /wp:paragraph -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><!-- wp:paragraph -->
<p><strong>Gemini's response:</strong></p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>Okay, opening the Task Scheduler.

Execute `!taskschd.msc`? (y/n)
</code></pre>
<!-- /wp:code --></blockquote>
<!-- /wp:quote -->

<!-- wp:paragraph -->
<p>After confirmation, the standard Windows utility will open on your screen.</p>
<!-- /wp:paragraph -->[:]