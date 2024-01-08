<h1>Welcome to my PowerShell Repository!</h1>

<p>This repository is dedicated to my exciting projects, where I utilize the power of <a href="https://ohmyposh.dev/">Oh My Posh</a> alongside Windows Terminal and Visual Studio Code. Get ready to dive into a vibrant coding experience!</p>

<h2>Technologies Used</h2>

<ul>
  <li><a href="https://ohmyposh.dev/">Oh My Posh</a>: An amazing framework that enhances the command-line interface with beautiful and customizable prompts.</li>
  <li><a href="https://aka.ms/terminal">Windows Terminal</a>: The modern, fast, efficient, and powerful terminal application for Windows.</li>
  <li><a href="https://code.visualstudio.com/">Visual Studio Code</a>: A highly extensible, feature-rich code editor that provides an exceptional development environment.</li>
  <li><a href= "https://github.com/Cavanite/main/blob/main/.vscode/VScode-Extensions.ps1"> Installed Extensions</a>: This are my installed extensions.

<h2>Why Oh My Posh?</h2>

<p>Oh My Posh has revolutionized my coding environment by adding a touch of color and personalization to my command-line interface. With its extensive theming support and prompt customizability, Oh My Posh makes the coding experience even more enjoyable and visually appealing.</p>
<p>The theme is use is <a href="https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/blue-owl.omp.json">Blue-Owl.</a></p>
<h2>Windows Terminal Setup</h2>

<p>To use Oh My Posh with Windows Terminal, follow these steps:</p>

<ol>
  <li>Install Windows Terminal from the <a href="https://aka.ms/terminal">Microsoft Store</a>.</li>
  <li>Open Windows Terminal and navigate to the settings file by clicking on the downward arrow icon in the title bar and selecting "Settings".</li>
  <li>In the settings file, locate the "profiles" section and find the profile you want to customize.</li>
  <li>Add the following configuration under the selected profile:</li>
</ol>

<pre><code>oh-my-posh --init --shell pwsh --config C:\PowerShell\blue-owl.omp.json | Invoke-Expression
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
</code></pre>

<p>Save the settings file, and now you can enjoy the colorful prompt provided by Oh My Posh in Windows Terminal!</p>

<h2>Visual Studio Code Integration</h2>

<p>To integrate Oh My Posh with Visual Studio Code, perform the following steps:</p>

<ol>
  <li>Install the <a href="https://marketplace.visualstudio.com/items?itemName=JanDeDobbeleer.oh-my-posh">Oh My Posh extension</a> from the Visual Studio Code Marketplace.</li>
  <li>Open Visual Studio Code and press <kbd>Ctrl+Shift+P</kbd> (or <kbd>Cmd+Shift+P</kbd> on macOS) to open the command palette.</li>
  <li>Search for "Oh My Posh: Select Theme" and choose your preferred theme from the list.</li>
</ol>

<p>Voila! Your Visual Studio Code now showcases a stunning prompt powered by Oh My Posh.</p>

<h2>Repository Contents</h2>

<p>This repository contains a collection of projects where I employ the delightful combination of Oh My Posh, Windows Terminal, and Visual Studio Code.</p>
<p>Happy Coding!!</p>
