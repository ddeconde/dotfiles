# Mac OS X Setup

This document describes one way to set up a new Mac. These instructions
are meant to prescribe manual configuration steps to be taken in
addition to the automated actions included in the `osx.sh` script.

Go straight to the [setup instructions](#)

## Philosophy

There are many tools available now for setting up a new system, ranging
from full-fledged professional configuration management tools to impressively
sophisticated ad hoc shell scripts. At the simplest, and hence most
robust end of the spectrum are **README** files describing what steps
should be taken manually to bring a new system to a state of readiness.

This document falls quite near that latter approach, but with a bit of
minimal shell scripting to automate those steps that seem most likely to
remain somewhat stable in the short term. As the underlying components
of this system can be expected to change with some rapidity, frequent
updates to this document and associated scripts are to be expected and
some guiding principles selected for the construction of these may be
useful to remember:

- Simplicity first, capacity second (maintenance is the highest cost).
- The greater the historical stability of a component, the greater the
  investment in automated configuration (cf. vim, zsh vs. OS X, Firefox).
- Abide defaults whenever possible, but configure when necessary.
- Security and privacy to the extent they are possible, usability to the
  extent it is necessary.

Some immediate corollaries:

- Use as little software as possible.
- Prefer programs that do one thing well.
- When possible use software that still functions without a network
  connection.
- Do not use beta software unless unavoidable.
- Prefer plain text over all other formats.
- Use only open formats.
- Avoid DRM encumbered media.
- Prefer open source software whenever possible.
- Pay for software of quality (paying for open source software is best).
- Only use maintained software.


The steps below were tested on **OS X Mountain Lion**.

- [System update](#system-update)
- [System preferences](#system-preferences)
- [Homebrew](#homebrew)
- [Firefox](#firefox)
- [iTerm2](#iterm2)
- [Beautiful terminal](#beautiful-terminal)
- [iTerm2](#iterm2)
- [Git](#git)
- [Vim](#vim)
- [Python](#python)
- [Virtualenv](#virtualenv)
- [IPython](#ipython)
- [Numpy and Scipy](#numpy-and-scipy)
- [Node.js](#nodejs)
- [JSHint](#jshint)
- [Ruby and RVM](#ruby-and-rvm)
- [Projects folder](#projects-folder)
- [Apps](#apps)

## System update

Immediately upon finishing a new system installation update the system:
**Apple Icon > Software Update...**

## System preferences

It is possible to script System Preferences changes (including options
not available in the GUI) via the `defaults` command, however defaults can
be structured in complex ways and change significantly with operating
system versions so automating these changes can involve considerable
amounts of maintenance.

Make the following manual changes to the System Preferences.

In **Apple Icon > System Preferences**:

- General > Appearance > Graphite
- General > Highlight color > Other
- General > Show scroll bars > Always
- Language & Region > Time format > 24-Hour Time
- Trackpad > Tap to click
- Trackpad > Tracking Speed > Fast (most of the way to the right)
- Energy Saver > Turn display off after: 1 hr
- Keyboard > Key Repeat > Fast (all the way to the right)
- Keyboard > Delay Until Repeat > Short (all the way to the right)
- Keyboard > Modifier Keys > Caps Lock = Control
- Dock > Automatically hide and show the Dock
- Dock > Size > Small (all the way to the left)
- Spotlight > Search Results > Uncheck Spotlight Suggestions and Bing Web
  Searches
- Security & Privacy > Location Services > Disable Location Services
- Security & Privacy > Diagnostics & Usage > Uncheck everything
- Security & Privacy > General > Require password immediately after sleep or
  screen saver begins
- Security & Privacy > Firewall > Turn On Firewall
- Sharing > Turn off all sharing
- Sharing >  Computer Name > Change this to taste
- Network > Advanced > DNS > DNS Servers > 84.200.69.80
  (dns.watch)
- Network > Advanced > DNS > DNS Servers > 84.200.70.40
  (dns.watch)

## Homebrew

The [Homebrew](http://brew.sh/) package manager for OS X is installed by
the command
`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)` 
which is run by the bootstrap script and then Homebrew is used to install
most other applications.

Homebrew depends on the **Command Line Tools** for **Xcode**. These can
be installed directly from the command line with `xcode-select --install`
and the bootstrap script does this before installing Homebrew.

One thing we need to do is tell the system to use programs installed by Hombrew (in `/usr/local/bin`) rather than the OS default if it exists. We do this by adding `/usr/local/bin` to your `$PATH` environment variable:

    $ echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile

Open a new terminal tab with **Cmd+T** (you should also close the old one), then run the following command to make sure everything works:

    $ brew doctor
    
### Usage

To install a package (or **Formula** in Homebrew vocabulary) simply type:

    $ brew install <formula>
        
To update Homebrew's directory of formulae, run:

    $ brew update
    
**Note**: I've seen that command fail sometimes because of a bug. If that ever happens, run the following (when you have Git installed):

    $ cd /usr/local
    $ git fetch origin
    $ git reset --hard origin/master

To see if any of your packages need to be updated:

    $ brew outdated
    
To update a package:

    $ brew upgrade <formula>
        
Homebrew keeps older versions of packages installed, in case you want to roll back. That rarely is necessary, so you can do some cleanup to get rid of those old versions:

    $ brew cleanup

To see what you have installed (with their version numbers):

    $ brew list --versions

## Firefox

[Firefox](https://www.mozilla.org/en-US/firefox/desktop/) is installed via
Homebrew, but it still needs [Add-ons](https://addons.mozilla.org/en-US/firefox/)
and some configuration.

### Add-ons

Install the following:
- [uMatrix](https://addons.mozilla.org/en-US/firefox/addon/umatrix/)
- [Privacy Settings](https://addons.mozilla.org/en-US/firefox/addon/privacy-settings/)
In **Privacy Settings** select the **Full Privacy** settings group.

### Search Engines

Go to each of the following websites and select **Add to Firefox**:
- [Startpage](https://startpage.com)
- [ixquick](https://ixquick.com)

## iTerm2

[iTerm2](http://www.iterm2.com/) is installed via Homebrew but needs
configuring.

In **iTerm > Preferences...**, under the tab **General**, uncheck **Confirm closing multiple sessions** and **Confirm "Quit iTerm2 (Cmd+Q)" command** under the section **Closing**.

In the tab **Profiles**, create a new one with the "+" icon, and rename it to your first name for example. Then, select **Other Actions... > Set as Default**. Finally, under the section **Window**, change the size to something better, like **Columns: 125** and **Rows: 35**.

## Beautiful terminal

Since we spend so much time in the terminal, we should try to make it a more pleasant and colorful place. What follows might seem like a lot of work, but trust me, it'll make the development experience so much better.

Let's go ahead and start by changing the font. In **iTerm > Preferences...**, under the tab **Profiles**, section **Text**, change both fonts to **Consolas 13pt**.

Now let's add some color. I'm a big fan of the [Solarized](http://ethanschoonover.com/solarized) color scheme. It is supposed to be scientifically optimal for the eyes. I just find it pretty.

Scroll down the page and download the latest version. Unzip the archive. In it you will find the `iterm2-colors-solarized` folder with a `README.md` file, but I will just walk you through it here:

- In **iTerm2 Preferences**, under **Profiles** and **Colors**, go to **Load Presets... > Import...**, find and open the two **.itermcolors** files we downloaded.
- Go back to **Load Presets...** and select **Solarized Dark** to activate it. Voila!


Not a lot of colors yet. We need to tweak a little bit our Unix user's profile for that. This is done (on OS X and Linux), in the `~/.bash_profile` text file (`~` stands for the user's home directory).

We'll come back to the details of that later, but for now, just download the files [.bash_profile](https://raw.githubusercontent.com/nicolashery/mac-dev-setup/master/.bash_profile), [.bash_prompt](https://raw.githubusercontent.com/nicolashery/mac-dev-setup/master/.bash_prompt), [.aliases](https://raw.githubusercontent.com/nicolashery/mac-dev-setup/master/.aliases) attached to this document into your home directory (`.bash_profile` is the one that gets loaded, I've set it up to call the others):

    $ cd ~
    $ curl -O https://raw.githubusercontent.com/nicolashery/mac-dev-setup/master/.bash_profile
    $ curl -O https://raw.githubusercontent.com/nicolashery/mac-dev-setup/master/.bash_prompt
    $ curl -O https://raw.githubusercontent.com/nicolashery/mac-dev-setup/master/.aliases
    
With that, open a new terminal tab (Cmd+T) and see the change! Try the list commands: `ls`, `ls -lh` (aliased to `ll`), `ls -lha` (aliased to `la`).

At this point you can also change your computer's name, which shows up in this terminal prompt. If you want to do so, go to **System Preferences** > **Sharing**. For example, I changed mine from "Nicolas's MacBook Air" to just "MacBook Air", so it shows up as `MacBook-Air` in the terminal.

Now we have a terminal we can work with!

(Thanks to Mathias Bynens for his awesome [dotfiles](https://github.com/mathiasbynens/dotfiles).)

## Git

[Git](http://git-scm.com/) is installed via Homebrew and `$HOME/.gitconfig`
and `$HOME/.gitignore` are linked to `$HOME/.dotfiles/gitconfig` by the
bootstrap script, but `$HOME/.gitconfig_local` must be placed manually as
it may contain sensitive material.
    
## Vim

[Vim](http://www.vim.org/)

## Vagrant

[Vagrant]() and its dependencies [VirtualBox]() and [Virtualbox
Extension Pack]() are installed by Homebrew, but to keep the VirtualBox
Guest Additions up to date on guest systems automatically the Vagrant
plugin [vagrant-vbguest]() is needed. This must be install by running
`vagrant plugin install vagrant-vbguest`.

## Python

OS X, like Linux, ships with [Python](http://python.org/) already installed. But you don't want to mess with the system Python (some system tools rely on it, etc.), so we'll install our own version with Homebrew. It will also allow us to get the very latest version of Python 2.7.

The following command will install Python 2.7 and any dependencies required (it can take a few minutes to build everything):

    $ brew install python
    
When finished, you should get a summary in the terminal. Running `$ which python` should output `/usr/local/bin/python`.

It also installed [Pip]() (and its dependency [Distribute]()), which is the package manager for Python. Let's upgrade them both:

    $ pip install --upgrade distribute
    $ pip install --upgrade pip
    
Executable scripts from Python packages you install will be put in `/usr/local/share/python`, so let's add it to the `$PATH`. To do so, we'll create a `.path` text file in the home directory (I've already set up `.bash_profile` to call this file):

    $ cd ~
    $ subl .path
    
And add these lines to `.path`:

```bash
PATH=/usr/local/share/python:$PATH
export PATH
```
    
Save the file and open a new terminal to take the new `$PATH` into account (everytime you open a terminal, `.bash_profile` gets loaded).

### Pip Usage

Here are a couple Pip commands to get you started. To install a Python package:

    $ pip install <package>

To upgrade a package:

    $ pip install --upgrade <package>
        
To see what's installed:

    $ pip freeze
    
To uninstall a package:

    $ pip uninstall <package>

## Virtualenv

[Virtualenv](http://www.virtualenv.org/) is a tool that creates an isolated Python environment for each of your projects. For a particular project, instead of installing required packages globally, it is best to install them in an isolated folder in the project (say a folder named `venv`), that will be managed by virtualenv.

The advantage is that different projects might require different versions of packages, and it would be hard to manage that if you install packages globally. It also allows you to keep your global `/usr/local/lib/python2.7/site-packages` folder clean, containing only critical or big packages that you always need (like IPython, Numpy).

### Install

To install virtualenv, simply run:

    $ pip install virtualenv

### Usage

Let's say you have a project in a directory called `myproject`. To set up virtualenv for that project:

    $ cd myproject/
    $ virtualenv venv --distribute
    
If you want your virtualenv to also inherit globally installed packages (like IPython or Numpy mentioned above), use:

    $ virtualenv venv --distribute --system-site-packages

These commands create a `venv` subdirectory in your project where everything is installed. You need to **activate** it first though (in every terminal where you are working on your project):

    $ source venv/bin/activate
    
You should see a `(venv)` appear at the beginning of your terminal prompt indicating that you are working inside the virtualenv. Now when you install something:

    $ pip install <package>

It will get installed in the `venv` folder, and not conflict with other projects.

**Important**: Remember to add `venv` to your project's `.gitignore` file so you don't include all of that in your source code!

As mentioned earlier, I like to install big packages (like Numpy), or packages I always use (like IPython) globally. All the rest I install in a virtualenv.

## Projects folder

This really depends on how you want to organize your files, but I like to put all my version-controlled projects in `~/Projects`. Other documents I may have, or things not yet under version control, I like to put in `~/Dropbox` (if you have Dropbox installed), or `~/Documents`.

## Apps

Here is a quick list of some apps I use, and that you might find useful as well:

- [1Password](https://agilebits.com/onepassword): Allows you to securely store your login and passwords. Even if you only use a few different passwords (they say you shouldn't!), this is really handy to keep track of all the accounts you sign up for! Also, they have a mobile app so you always have all your passwords with you (syncs with Dropbox). A little pricey though. There are free alternatives. **($50 for Mac app, $18 for iOS app)**
- [Marked](http://markedapp.com/): As a developer, most of the stuff you write ends up being in [Markdown](http://daringfireball.net/projects/markdown/). In fact, this `README.md` file (possibly the most important file of a GitHub repo) is indeed in Markdown, written in Sublime Text, and I use Marked to preview the results everytime I save. **($4)**
