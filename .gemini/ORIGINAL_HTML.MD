<h1>Complete Guide to WP-PageNavi Variables for WordPress</h1>
<p>Page navigation is an important part of any WordPress blog or news site. One of the most popular tools for convenient pagination is the <strong>WP-PageNavi</strong> plugin. It allows you to replace the standard "Previous / Next" links with more flexible and beautiful pagination.</p>
<p>One of the key features is the ability to customize link text using <strong>variables</strong> that automatically substitute the current page number, total number of pages, and other information.</p>
<p>In this article, we will analyze <strong>all available variables</strong>, examples of their use, and show with screenshots where to insert them.</p>
<hr>
<h2>Where to find WP-PageNavi settings</h2>
<p>After installing the plugin, go to the WordPress admin panel:</p>
<p><strong>Settings → PageNavi</strong></p>
<p>There you will see a menu for customizing link text (example in the screenshot below):</p>
<p><img src="https://github.com/hypo69/1001-python-ru/blob/master/assets/wordpress-pagenavi-guide/a34df3db-dcb3-4815-ac1c-a73c693fce39.png" alt="WP-PageNavi Settings in WordPress"></p>
<p>👉 In each field, you can use variables to dynamically display the current page, total number of pages, and other navigation elements.</p>
<hr>
<h2>Available WP-PageNavi Variables</h2>
<p>The plugin provides a set of placeholders (template variables) that can be used in the settings:</p>
<h3>🔹 %CURRENT_PAGE%</h3>
<p>Displays the <strong>current page number</strong>.</p>
<p>Example:</p>
<pre class="line-numbers"><code class="language-powershell">

You are on page %CURRENT_PAGE%

</code></pre>
<p>👉 If you are on page 3, the result will be:</p>
<pre class="line-numbers"><code class="language-powershell">

You are on page 3

</code></pre>
<hr>
<h3>🔹 %TOTAL_PAGES%</h3>
<p>Shows the <strong>total number of pages</strong>.</p>
<p>Example:</p>
<pre class="line-numbers"><code class="language-powershell">

Total pages: %TOTAL_PAGES%

</code></pre>
<p>👉 If there are 10 pages in total, the output will be:</p>
<pre class="line-numbers"><code class="language-powershell">

Total pages: 10

</code></pre>
<hr>
<h3>🔹 %PAGE_NUMBER%</h3>
<p>Used to display the <strong>number of each page</strong> in the list.</p>
<p>Example:</p>
<pre class="line-numbers"><code class="language-powershell">

Page %PAGE_NUMBER%

</code></pre>
<p>👉 In the navigation, links will appear:</p>
<pre class="line-numbers"><code class="language-powershell">

Page 1 | Page 2 | Page 3 | ...

</code></pre>
<hr>
<h2>WP-PageNavi Variables Table</h2>
<table>
<thead>
<tr>
<th>Variable</th>
<th>Description</th>
<th>Setting Example</th>
<th>Result (if 3rd page out of 10)</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>%CURRENT_PAGE%</strong></td>
<td>Current page number</td>
<td><code>You are currently on page %CURRENT_PAGE%</code></td>
<td><code>You are currently on page 3</code></td>
</tr>
<tr>
<td><strong>%TOTAL_PAGES%</strong></td>
<td>Total number of pages</td>
<td><code>Total pages: %TOTAL_PAGES%</code></td>
<td><code>Total pages: 10</code></td>
</tr>
<tr>
<td><strong>%PAGE_NUMBER%</strong></td>
<td>Number of each page in the list</td>
<td><code>Page %PAGE_NUMBER%</code></td>
<td><code>Page 1 | Page 2 | Page 3 …</code></td>
</tr>
<tr>
<td><strong>1 (static)</strong></td>
<td>First page (no variable)</td>
<td><code>First</code> or <code>Page 1</code></td>
<td><code>First</code></td>
</tr>
<tr>
<td><strong>%TOTAL_PAGES%</strong></td>
<td>Last page</td>
<td><code>Page %TOTAL_PAGES%</code></td>
<td><code>Page 10</code></td>
</tr>
<tr>
<td><strong>← / → / …</strong></td>
<td>Symbols for arrows and abbreviations</td>
<td><code>← Back</code>, <code>Forward →</code>, <code>…</code></td>
<td><code>← Back | 1 | 2 | 3 | … | 10 | Forward →</code></td>
</tr>
</tbody>
</table>
<hr>
<h2>Example of full configuration</h2>
<p>In the screenshot above, you can fill in the fields as follows:</p>
<ul>
<li><strong>Text For Number Of Pages</strong>:<br><code>Page %CURRENT_PAGE% of %TOTAL_PAGES%</code></li>
<li><strong>Text For Current Page</strong>:<br><code>%PAGE_NUMBER%</code></li>
<li><strong>Text For Page</strong>:<br><code>%PAGE_NUMBER%</code></li>
<li><strong>Text For First Page</strong>:<br><code>First</code></li>
<li><strong>Text For Last Page</strong>:<br><code>Page %TOTAL_PAGES%</code></li>
<li><strong>Text For Previous Page</strong>:<br><code>← Back</code></li>
<li><strong>Text For Next Page</strong>:<br><code>Forward →</code></li>
<li><strong>Text For Previous …</strong>:<br><code>…</code></li>
<li><strong>Text For Next …</strong>:<br><code>…</code></li>
</ul>
<p>👉 As a result, visitors will see approximately the following navigation:</p>
<pre class="line-numbers"><code class="language-powershell">

← Back | First | 1 | 2 | 3 | … | Page 10 | Forward →

</code></pre>
<hr>
<h2>Summary</h2>
<p>WP-PageNavi variables are simple but provide flexibility in navigation settings:</p>
<ul>
<li><code>%CURRENT_PAGE%</code> — current page</li>
<li><code>%TOTAL_PAGES%</code> — total pages</li>
<li><code>%PAGE_NUMBER%</code> — specific page number</li>
</ul>
<p>For the first page, use <code>1</code>, and for the last page, use <code>%TOTAL_PAGES%</code>.</p>
<p>Thanks to these settings, you can make website navigation more understandable and convenient for visitors.</p>