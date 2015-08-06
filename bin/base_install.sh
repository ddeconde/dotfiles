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


# Make certain that git is installed
which git
if [ $? -ne 0 ]; then
    echo "Install git via using your package manager.";
    exit 1
fi


#
# SHELL
#

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
# VIM PLUGINS
#

# Install Vundle to manage Vim plugins
[ -d "~/.vim/bundle/Vundle.vim" ] || \
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install Vim plugins via Vundle
vim +PluginInstall +qall
