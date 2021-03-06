# Mac OS X Setup

This document describes one way to set up a new Mac. These instructions
are meant to prescribe manual configuration steps to be taken in
addition to the automated actions included in the `osx.sh` script.

---
Go straight to the [setup instructions](#setup).
Go straight to the [maintenance instructions](#maintenance).
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
- Countenance defaults wherever possible, but configure where necessary.
- Security and privacy to the extent they are possible, usability to the
  extent it is necessary.

Some corollary tenets:

- Use Mac hardware and software for direct interface use, BSD/Linux
  otherwise.
- Use as little hardware and software as possible.
- Prefer programs that do one thing well.
- When possible use software that still functions without a network
  connection.
- Do not use beta software when avoidable.
- Prefer plain text over all other formats.
- Use only open formats.
- Avoid DRM encumbered media.
- Prefer open source software wherever possible.
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
- [Git](#git)
- [Vim](#vim)
- [Python](#python)
- [Virtualenv](#virtualenv)
- [IPython](#ipython)
- [Numpy and Scipy](#numpy-and-scipy)
- [Ruby and RVM](#ruby-and-rvm)
- [Projects folder](#projects-folder)
- [Apps](#apps)

## Setup

On first boot, hold the `Command` `Option` `P` `R` keys to clean the
NVRAM. Wait for the system to reboot once.

When OS X first starts, you will be greeted by **Setup Assistant**. Do
not connect to networking yet; skip that part of setup for now.

Create a user account with:
- a **strong password** without a hint, and
- standard account privileges,
- a not too identifiable account name.

Create an administrator account with:
- a **strong password** without a hint,
- admin account privileges,
- a not too identifiable account name,
- the full name "Administrator."

The administrator account is for installing software and updating the
operating system. The preferences for this account should be left at
defaults and it should not be used for ordinary computing.

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
**Apple Icon > App Store... > Updates**

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

### Setup Script

Open `Terminal.app` and run the following commands at the prompt to
download and run the setup script:

```
cd ~
curl -fsSL --output "osx.sh" "https://raw.githubusercontent.com/ddeconde/dotfiles/master/bin/osx.sh" && chmod 755 osx.sh
bash osx.sh [hostname]
```

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

In **iTerm > Preferences...**:
- General > Preferences > Load preferences from a custom folder or URL >
  $HOME/dotfiles/etc

### VMware Fusion

[VMware Fusion](http://www.vmware.com/products/fusion) is installed by
Homebrew-cask, and used to run instances of Linux or BSD to use as
development environments and test installations.

1. Download install images for a desired virtual machine OS.
2. Open VMware Fusion.
3. Use **Easy Install** to install VMware Tools in the new virtual machine.
4. Save a snapshot.
5. Load and run the appropriate bootstrap script on the virtual machine.

#### Virtual Machine Setup

Whether locally in VMWare Fusion or on [Amazon EC2](https://aws.amazon.com/ec2/)
new virtual machines will require setup. These systems should have their
own setup scripts to speed this process. After accessing a virtual
machine via SSH the appropriate setup script should be run. Here are the
commands to do so for a [Debian Linux](https://www.debian.org) system:

```
cd ~
sudo apt-get update && sudo apt-get -y install curl
curl -fsSL --output "debian.sh" "https://raw.githubusercontent.com/ddeconde/dotfiles/master/bin/debian.sh" && chmod 755 debian.sh && bash debian.sh
```

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

### Mail.app

First set up any accounts.

In **Preferences...**:
- Junk Mail > When junk mail arrives > Move it to the Junk mailbox
- Viewing > Do not load remote content in messages
- Viewing > Do not use Smart Addresses
- Composing > Message Format > Plain Text

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

Copy a backup of the `~/private` directory into your home directory and
then run the `private.sh` script to link these files to the appropriate
places.

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

### Full Disk Encryption

**FileVault 2** provides full volume encryption with negligible
performance cost. To enable it select:

**System Preferences > Security & Privacy > FileVault > Turn on
FileVault**

As FileVault security relies on the pseudo-random number generator (PRNG)
it may be better to activate it after the PRNG has been seeded with a
bit of entropy from manual system use.

## Maintenance

### Backup

The script `backup` is based around the `rsync` utility and should be
run daily. The **Time Machine** application should be used in addition. On
a weekly basis `backup` should be used to place backups in one
additional physical location (like the workplace).

#### backup.sh

```
```

#### Time Machine

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

#### Vim Plugins

The following commands are useful for keeping Vim plugins up-to-date:
- `PlugUpgrade` upgrades **vim-plug** the plugin manager itself
- `PlugUpdate` updates plugins
- `PlugSnapshot` can be used to generate a restore script

### Dotfiles Repository

This repository must be maintained for it to remain useful. While
changes to dotfiles themselves are automatically saved via git and the
regular backups, this file **README.md** and the bootstrap scripts
**osx.sh**, **debian.sh**, and **private.sh** are likely to need modification
as operating system and application versions change.
