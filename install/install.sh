#!/usr/bin/env bash

#
# install.sh
# Last Changed: Thu, 11 Dec 2014 12:30:58 -0800
#

#
# Usage:
# $ sudo install.sh
#


# Make certain that sudo is used to run this script
if [ $(id -u) != 0 ]; then
    echo "Please run this command with superuser privileges:";
    echo "$ sudo install.sh";
    exit 1
fi


#
# DOTFILE SYMBOLIC LINKS
#

DOTFILES=~/.dotfiles/*

for DOTFILE in $DOTFILES; do
    [ -f "~/.$DOTFILE" ] && mv ~/.$DOTFILE ~/.$DOTFILE.old;
    [ -f "~/.dotfiles/$DOTFILE" ] && ln -s ~/.dotfiles/$DOTFILE ~/.$DOTFILE
done


#
# HOMEBREW
#

# Install Xcode command line developer tools (required for Homebrew)
xcode-select --print-path
if [ $? -ne 0 ]; then
    xcode-select --install
fi

# Install Homebrew
[ $(which brew) = /usr/local/bin/brew ] || \
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Make certain that homebrew is ready for brewing
# Right now brew doctor must be completely satisfied to continue
brew doctor
if [ $? -ne 0 ]; then
    echo "Resolve Homebrew warnings and errors before brewing.";
    exit 1
fi

# Run homebrew on brewfile to install applications
brew bundle

# Make certain that git is installed
which git
if [ $? -ne 0 ]; then
    echo "Install git via homebrew or Xcode command line tools.";
    exit 1
fi


#
# SHELL
#

# Append Homebrewed zsh path to /etc/shells to authorize it as a login shell
[ $(grep /usr/local/bin/zsh /etc/shells) = /usr/local/bin/zsh ] || \
    echo /usr/local/bin/zsh | tee -a /etc/shells

# Change this user's default shell to Homebrewed zsh
[ $(echo $SHELL) = /usr/local/bin/zsh ] || \
    chsh -s /usr/local/bin/zsh $USER


#
# COLOR SCHEME
#

# Install Solarized
[ -d "~/.solarized" ] || \
    git clone git://github.com/altercation/solarized.git ~/.solarized
echo "Solarized color scheme files are in ~/.solarized."


#
# ITERM2
#

# Reminder of where the iTerm2 preferences file is
echo "iTerm2 preferences file is at ~/.dotfiles/install/com.googlecode.iterm2.plist"


#
# VIM PLUGINS
#

# Install Vundle to manage Vim plugins
[ -d "~/.vim/bundle/Vundle.vim" ] || \
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install Vim plugins via Vundle
vim +PluginInstall +qall


#
# HOMEBREW SYMBOLIC LINKS
#

# Make a user bin directory that occurs early in PATH
[ -d "~/bin" ] || \
    mkdir ~/bin

# Actual linking of executables to ~/bin should be done by hand
echo "To use specific homebrewed executables over defaults link them to ~/bin."
