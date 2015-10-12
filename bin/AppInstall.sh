#!/usr/bin/env bash

# An alternative to using Homebrew for application management is to just
# install all applications natively. This is an incompletely example of one way
# to do that via script.

mkdir ~/appstemp
cd ~/appstemp

# Installing Firefox
curl -L -o Firefox.dmg
"http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
hdiutil mount -nobrowse Firefox.dmg
cp -R "/Volumes/Firefox/Firefox.app" /Applications
hdiutil unmount "/Volumes/Firefox"
rm Firefox.dmg

# Installing VLC Player
curl -L -o vlc.dmg
"http://vlc.mirror.uber.com.au/vlc/2.2.0/macosx/vlc-2.2.0.dmg"
hdiutil mount -nobrowse vlc.dmg -mountpoint /Volumes/vlc
cp -R "/Volumes/vlc/VLC.app" /Applications
hdiutil unmount "/Volumes/vlc"
rm vlc.dmg

# Installing Transmission
curl -L -o Transmission.dmg
"https://transmission.cachefly.net/Transmission-2.84.dmg"
hdiutil mount -nobrowse Transmission.dmg
cp -R "/Volumes/Transmission/Transmission.app" /Applications
hdiutil unmount "/Volumes/Transmission"
rm Transmission.dmg

# Installing Adium
curl -L -o Adium.dmg
"http://downloads.sourceforge.net/project/adium/Adium_1.5.10.dmg"
hdiutil mount -nobrowse Adium.dmg -mountpoint /Volumes/Adium
cp -R "/Volumes/Adium/Adium.app" /Applications
hdiutil unmount "/Volumes/Adium"
rm Adium.dmg

# Installing iterm2
curl -L -o iTerm2.zip "http://www.iterm2.com/downloads/stable/iTerm2_v2_0.zip"
unzip iTerm2.zip
mv iTerm.app /Applications
rm iTerm2.zip

# Installing 1Password
curl -L -o 1Password.zip
"https://d13itkw33a7sus.cloudfront.net/dist/1P/mac4/1Password-5.1.zip"
unzip 1Password.zip
mv "1Password 4.app" /Applications
rm 1Password.zip

# Installing The Unarchiver
curl -L -o TheUnarchiver.zip
"http://theunarchiver.googlecode.com/files/TheUnarchiver3.9.1.zip"
unzip TheUnarchiver.zip
mv "The Unarchiver.app" /Applications
rm TheUnarchiver.zip

rm -rf ~/appstemp
