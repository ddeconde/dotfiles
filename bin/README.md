# Mac OS X Setup

This document describes one way to set up a new Mac. These instructions
are meant to prescribe manual configuration steps to be taken in
addition to the automated actions included in the `osx.sh` script.

---
Go straight to the [setup instructions](#setup-instructions).
---

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

- Use Mac hardware and software for direct interface use, BSD/Linux
  otherwise.
- Use as little software as possible.
- Prefer programs that do one thing well.
- When possible use software that still functions without a network
  connection.
- Do not use beta software when avoidable.
- Prefer plain text over all other formats.
- Use only open formats.
- Avoid DRM encumbered media.
- Prefer open source software whenever possible.
- Pay for software of quality (paying for open source software is best).
- Only use maintained software.

N.B. These setup instructions represent one particular compromise between
security/privacy and accessibility/usability, thus they produce some
notable inconveniences not present in some defaults for this software
and at the same time are quite unsuitably insecure for high risk threat
models.

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
- [Ruby and RVM](#ruby-and-rvm)
- [Projects folder](#projects-folder)
- [Apps](#apps)

## Setup Instructions

On first boot, hold the `Command` `Option` `P` `R` keys to clean the
NVRAM. Wait for the system to reboot once.

When OS X first starts, you will be greeted by **Setup Assistant**. Do
not connect to networking yet; skip that part of setup for now.

Create a user account with:
- a **strong password** without a hint, and
- a not too identifiable account name.

### Firmware Password

Setting a firmware password prevents a Mac from starting up from any
device other than the startup disk. It can only be reset at an
[Apple Retail Store](https://www.apple.com/retail/storelist/) or 
[Apple Authorized Service Provider](https://locate.apple.com/country)
so be careful not to lose or forget it.

1. Shut down the Mac.
2. Start up the Mac again and immediately hold the keys `Command` `R`
   after hearing the startup sound to start **OS X Recovery**.
3. When the Recovery window appears, choose **Firmware Password
   Utility** from the Utilities menu.
4. In the **Firmware Utility** window click **Turn on Firmware
   Password**.
5. Enter a new password, then re-enter it in the Verify field.
6. Select **Set Password**.
7. Select **Quit Firmware Utility**.
8. Select the **Apple** menu and choose **Restart** or **Shutdown**.

### System update

Immediately upon finishing a new system installation update the system:
**Apple Icon > Software Update...**

### System Preferences

It is possible to script System Preferences changes (including some options
not available in the GUI) via the `defaults` command, however defaults can
be structured in complex ways and change significantly with operating
system versions so automating these changes can involve considerable
amounts of maintenance.

Make the following manual changes to the System Preferences.

In **Apple Icon > System Preferences**:

- General > Appearance > Graphite
- General > Highlight color > Graphite
- General > Show scroll bars > Always
- Language & Region > Time format > 24-Hour Time
- Trackpad > Tap to click
- Trackpad > Tracking Speed > Fast (most of the way to the right)
- Energy Saver > Turn display off after: 1 hr
- Energy Saver > Turn computer off after: 1 hr
- Keyboard > Key Repeat > Fast (all the way to the right)
- Keyboard > Delay Until Repeat > Short (all the way to the right)
- Keyboard > Modifier Keys > Caps Lock = Control
- Keyboard > Use all F1, F2, etc. keys as standard function keys
- Dock > Automatically hide and show the Dock
- Dock > Size > 
- Dock > 
- Spotlight > Search Results > Uncheck Spotlight Suggestions and Bing Web
  Searches
- Security & Privacy > Location Services > Disable Location Services
- Security & Privacy > Diagnostics & Usage > Disable everything
- Security & Privacy > General > Require password immediately after sleep or
  screen saver begins
- Security & Privacy > Firewall > Turn On Firewall
- Sharing > Turn off all sharing
- Sharing >  Computer Name > Change this to taste
- Network > Advanced > DNS > DNS Servers > 84.200.69.80
  [dns.watch](https://dns.watch/index)
- Network > Advanced > DNS > DNS Servers > 84.200.70.40
  [dns.watch](https://dns.watch/index)

### Safari

Even if it is not going to be used as default browser it is wise to
configure the built-in web browser Safari to be relatively safe if used.
In particular **Search > Smart Search Field > Include Spotlight
Suggestions** should be disabled.

In **Preferences...**:

- General > Homepage > https://startpage.com
- General > New windows open with > Homepage
- General > New tabs open with > Homepage
- General > Remove history items > After one day
- General > Remove download list items > When Safari quits
- General > Do not Open "safe" files after downloading
- AutoFill > Disable all
- Passwords > Do not AutoFill user names and passwords
- Search > Search engine > Do not Include search engine suggestions
- Search > Smart Search Field > Disable all
- Security > Fraudulent sites > Do not Warn when visiting a fraudulent
  website
- Security > Web content > Disable JavaScript
- Security > Web content > Block pop-up windows
- Security > Web content > Do not Allow WebGL
- Security > Internet plug-ins > Do not Allow Plug-ins
- Privacy > Cookies and website data > Always block
- Privacy > Website use of location services > Deny without prompting
- Notifications > Do not Allow websites to ask for permission to send
  push notifications
- Advanced > Smart Search Field > Show full website address
- Advanced > Accessibility > Never use font sizes smaller than 9
- Advanced > Accessibility > Press Tab to highlight each item on a
  webpage

[1Password Browser Extension](https://agilebits.com/onepassword/extensions)

### Setup Script

Open `Terminal.app` and run the following commands at the prompt to
download and run the setup script:

```
cd ~
curl -fsSL "https://raw.githubusercontent.com/ddeconde/dotfiles/master/bin/osx.sh"
bash osx.sh [hostname]
```

### Firefox

[Firefox](https://www.mozilla.org/en-US/firefox/desktop/) will be our default
browser and is installed via Homebrew, but it still needs
[Add-ons](https://addons.mozilla.org/en-US/firefox/) and some configuration.

#### Add-ons

Install the following Firefox Add-ons:
- [1Password Browser Extension](https://agilebits.com/onepassword/extensions)
- [uMatrix](https://addons.mozilla.org/en-US/firefox/addon/umatrix/)
- [Privacy Settings](https://addons.mozilla.org/en-US/firefox/addon/privacy-settings/)

In **Privacy Settings** select the **Full Privacy** settings group.

#### Search Engines

Go to each of the following websites and select **Add to Firefox**:
- [Startpage](https://startpage.com)
- [ixquick](https://ixquick.com)

### iTerm2

[iTerm2](http://www.iterm2.com/) is installed via Homebrew but needs
configuring.

In **iTerm > Preferences...**, under the tab **General**, uncheck **Confirm closing multiple sessions** and **Confirm "Quit iTerm2 (Cmd+Q)" command** under the section **Closing**.

In the tab **Profiles**, create a new one with the "+" icon, and rename it to your first name for example. Then, select **Other Actions... > Set as Default**. Finally, under the section **Window**, change the size to something better, like **Columns: 125** and **Rows: 35**.

#### Beautiful terminal

Since we spend so much time in the terminal, we should try to make it a more pleasant and colorful place. What follows might seem like a lot of work, but trust me, it'll make the development experience so much better.

Let's go ahead and start by changing the font. In **iTerm > Preferences...**, under the tab **Profiles**, section **Text**, change both fonts to **Consolas 13pt**.

Now let's add some color. I'm a big fan of the [Solarized](http://ethanschoonover.com/solarized) color scheme. It is supposed to be scientifically optimal for the eyes. I just find it pretty.

Scroll down the page and download the latest version. Unzip the archive. In it you will find the `iterm2-colors-solarized` folder with a `README.md` file, but I will just walk you through it here:

- In **iTerm2 Preferences**, under **Profiles** and **Colors**, go to **Load Presets... > Import...**, find and open the two **.itermcolors** files we downloaded.
- Go back to **Load Presets...** and select **Solarized Dark** to activate it. Voila!

### Vagrant

[Vagrant](https://www.vagrantup.com/) and its dependencies
[VirtualBox](https://www.virtualbox.org/) and **Virtualbox Extension Pack**
are installed by Homebrew, but to keep the **VirtualBox Guest Additions**
up to date on guest systems automatically the Vagrant plugin
[vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) is needed.
This plugin is installed by the bootstrap script.

### Spectacle

Choose **Preferences...** from the status icon menu in the menu bar and
enable **Launch Spectacle at login**.

### Adium

[Adium](https://adium.im/) has Off-the-Record (OTR) encryption for chat,
but by default it logs all chats and sends the contents of some messages
through the **OS X Notification Center**. For greater privacy disable
these features.

In **Adium > Preferences...**:

- General > Messages > Do not Log Messages
- Events > Remove any Display a notification entries

### GPGTools

...

### Little Snitch

[Little Snitch](https://www.obdev.at/products/littlesnitch/index.html)
is an _outgoing_ application firewall. It monitors and can block
outgoing network connections on a process by process basis with rules
that can be configured easily during use to block or allow connections
for particular process, address, port combinations. These features make
it a critical privacy tool.

#### Run the Little Snitch Installer

Homebrew-cask installs the Little Snitch installer, but to complete the
installation this installer must be run manually.

#### Add License

1. Choose **Open Little Snitch Preferences...** from the Little Snitch
   status icon menu in the menu bar.
2. In **Registration** enter license information.

#### Preferences

...
Set rules to maximum restrictiveness -- block _all_ by default.

### 1Password

[1Password](https://agilebits.com/onepassword/mac) is a password
generation and management application that makes use of many different
strong passwords easy.

#### Add License

1. Choose **1Password > License** from the menu bar.
2. Click the **Add License** button.
3. Select the license file and click **Open**.

#### Restore from Backup

**1Password** stores backup files in
```
~/Library/Application Support/1Password 4/Backups/
```
so copying the most recent backup from this directory in the system
backup to this same directory in the new system will make it possible to
restore the 1Password vault database. After copying go to **File >
Restore**.

#### Start Over

...

### Viscosity

A directory (we will call **openvpn**) of OpenVPN configuration files
should be obtained from your VPN provider.

1. In **Preferences... > Connections > + > Import Connection > From
   File...** select the **openvpn** folder and **Open** it.
2. Click **OK** after the connection import confirmation.

### Things

#### Add License

1. Choose **Things > License...** from the menu bar.
2. ...

#### ...

### Mail.app

### Calendar.app

### Reminders.app

### Contacts.app

### TextEdit.app

### F.lux

In **Preferences...** from the status icon menu in the menu bar:
- **Recommended colors**
- Location (as appropriate)
- Wake up time
- **Start f.lux at login**1

### Sensitive Material

Sensitive material includes encryption keys, personal data, and other
files that cannot be hosted publicly for obvious reasons. These must be
backed up locally and restored separately.

#### Identifiers

You have already selected the following potentially identifying labels:

- host name
- user account name

#### Local Configuration Files

gitgonfig_local
zshrc_local

#### Credentials

ssh
aws
gpg

#### Miscellaneous

bookmarks
contacts
1Password data
backed up data

## Maintenance

### Backup

The script `backup` is based around the `rsync` utility and should be
run daily. The **Time Machine** application may be used in addition. On
a weekly basis `backup` should be used to place backups in one
additional physical location (like the workplace).

```
```

### System Updates

In the **Apple Menu** select **Software Update...**

### Application Updates

#### Homebrew

Run `brew doctor` and resolve any **Warning** issues.

Run the following commands to update the Homebrew formula directory, see
what installed packages are outdated, and upgrade all installed
packages:

```
brew update
brew outdated
brew upgrade --all
```

Homebrew keeps old versions in case you want to roll-back so
periodically you may want to clean this out with

```
brew cleanup
```

#### Homebrew Cask

As the homebrew-cask repository is a Homebrew Tap, casks should be
updated by the `brew update` command, however currently homebrew-cask
does not always detect if an application has been updated. Cask updates
can be forced via the `brew cask install --force` command if necessary.

### Dotfiles Repository

This repository must be maintained for it to remain useful. While
changes to dotfiles themselves are automatically saved via git and the
regular backups, this file **README.md** and the bootstrap scripts
**osx.sh** and **debian.sh** are likely to need modification as
operating system and application versions change.

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

## Git

[Git](http://git-scm.com/) is installed via Homebrew and `$HOME/.gitconfig`
and `$HOME/.gitignore` are linked to `$HOME/.dotfiles/gitconfig` by the
bootstrap script, but `$HOME/.gitconfig_local` must be placed manually as
it may contain sensitive material.
    
## Vim

[Vim](http://www.vim.org/)

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

### Full Disk Encryption

**FileVault 2** provides full volume encryption with negligible
performance cost. To enable it select:

**System Preferences > Security & Privacy > FileVault > Turn on
FileVault**

As FileVault security relies on the pseudo-random number generator (PRNG)
it may be better to activate it after the PRNG has been seeded with a
bit of entropy from manual system use.
