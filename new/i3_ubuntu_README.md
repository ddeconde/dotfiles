


## Base Installation

## Packages

### i3wm as DE

- polkit??

- Help
  * List keybindings etc
  * man pages
- Accessibility
  * Font Size
  * Colors
- System Misc
  * Airplane Mode
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
- External Storage Mounting
  * udevil/udiskie
- Keyboard Settings !
- copy/paste ?
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
if [[ ! $DISPLAY && $XDG_VTNR -le 3 ]]; then
  exec startx
fi
```
with the test condition being something like `-eq 1` for only starting X on the first virtual terminal.
- Plymouth splash (and theme)

### Backups

### Passwords

### Encryption

### Email

### Web

### Chat

### Containers

### Shell / Multiplexer

### Editor

## Configuration


## Applications
- File Manager: vifm, mc, ranger
- PDF Reader: zathura,
- Backup: rsnapshot/borgbackup, restic
- Passwords: pass, passmenu
- Web: Firefox, Luakit, Lynx,
- Core Utilities:

- Misc:
  * Dictionary
  * Thesaurus
  *
- Audio Player: cmus
- Video Player: mpv
- Image Viewer: feh
- Organization: taskwarrior, calcurse
- Chat: weechat, finch?,
- Mail: mutt, 
- System: htop, ncdu,


- System Prefs:
  * Accessibility
  * Airplane Mode
  * Network !
  * Bluetooth
  * Notifications
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
- i3
- j4-dmenu-desktop
- brightnessctl
- tlp, tlp-rdw
- alsa-utils
- xrandr
- sct
- network-manager, network-manager-openvpn
- dictd, dict-gcide, dict-moby-thesaurus
- silversearcher-ag
