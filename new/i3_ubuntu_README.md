


## Base Installation

## Packages

### i3wm as DE

- polkit??

- Help
  * List keybindings etc !
  * man pages !
- Accessibility
  * Font Size !
  * Colors !
- System Misc
  * Airplane Mode !
- Power Management
  * TLP
- Audio Volume !
  * alsamixer
  * amixer
  * pactl
  * PAmix
  * apulse ?
- Display Management !
  * xrandr
- Screen Backlight !
  * brightnessctl
- Blue Light Control !
  * sct (redshift)
- Network Management !
  * (NetworkManager)
  * nmtui
  * nmcli
- Notifications !
  * dunst
- Launcher !
  * rofi (dmenu)
- External Storage Mounting
  * udevil/udiskie/udisks2
- Keyboard Settings !
- Copy/Paste !
  * xclip
- Hardware Control Keys
  Use `xev` to find out which physical hardware function key is mapped to which XF86 command by running `xev -event keyboard` in the terminal and pressing the keys in question.

  * Audio: XF86AudioMute, XF86AudioLowerVolume
  * Microphone: XF86MicMute
  * Screen Brightness: XF86MonBrightnessDown, XF86MonBrightnessUp
  * Display: XF86Display
  * Wifi: XF86WLAN
  * Tools: XF86Tools
  * Bluetooth: XF86Bluetooth

- Printer Management
- Default Applications/MIME type defaults
- GUI Application Appearance !
- Fonts
- Display Manager (and theme)
  * No DM needed:
  Add the following to the end of `~/.bash_profile` or `~/.zprofile`:
```
if [[ ! $DISPLAY && $XDG_VTNR -le 2 ]]; then
  exec startx
fi
```
with the test condition being something like `-eq 1` for only starting X on the first virtual terminal.
- Plymouth splash (and theme)

### Backups & file syncronization
- rsync, restic
- syncthing

### Passwords
pass (w/ passmenu)

### Encryption

### Email

### Web

### Chat

### Containers
lxd (lxc)/docker

### Shell / Multiplexer
bash
zsh
tmux

### Editor

## Configuration
- vimrc !

- tmux.conf
- zshrc
- bashrc

- password-store

- 

- muttrc
- 

- Xresources (colors) !
- i3/config (colors) !
- i3status/config (colors) !
- dunstrc (colors) !
- rofi (colors) !

- gtk.css (colors) !
- add all defaults color scheme

- mutt
- notmuchmail
- 

### copy/paste

## Applications
- File Manager: vifm, mc, ranger
- PDF Reader: zathura,
- Backup: restic, rclone, rsync/rsnapshot, syncthing
- Passwords: pass, passmenu
- Web: Firefox, Luakit, Lynx,
- Editors: vim
- Core Utilities: zsh, tmux

- Programming:
  * git, tig, git-crypt
  * pgcli
  * mycli
  * asciinema
- Misc:
  * Dictionary
  * Thesaurus
  * Calculator
  * visidata
  * pandoc
- Audio Player: cmus
- Video Player: mpv
- Image Viewer: feh
- Organization: taskwarrior, calcurse
- Chat: weechat, signal
- Mail: mutt, 
- System: htop, ncdu, sysstat, tree
- Containers:


- System Prefs:
  * Accessibility
  * Airplane Mode !
  * Network !
  * Bluetooth
  * Notifications !
  * Audio/Sound !
  * Display & Brightness !
  * Wallpaper
  * Themes
  * Fonts
  * Power Management
  * Passwords
  * Encryption
  * Firewall/Security
  * Account Management
  * Backup


## packages
### desktop
- i3
- unclutter-xfixes
- xrandr
- j4-dmenu-desktop
- dunst
- rofi
### security
- pass

### system
- brightnessctl
- sct
- tlp, tlp-rdw, acpi
- alsa-utils
- network-manager, network-manager-openvpn
- bluez
- bluez-tools
### applications
- dictd, dict-gcide, dict-moby-thesaurus
- bc, dc (GNU calculators), apcalc
### utilities
- silversearcher-ag
- sysstat
- command-not-found
- command-not-found-data
- rtorrent
