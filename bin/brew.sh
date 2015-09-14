#!/usr/bin/env bash

### Begin Homebrew commands ###

# Installations via BREW

# brew install zsh-completions
# brew install mutt ??
# brew install profanity
# brew install coreutils

# Enable easy brewing of duplicate utilities
# (necessary for rsync)
brew tap homebrew/dupes

# git is excluded as it will always be installed outside of brew.sh
packages=(
  zsh
  bash
  vim
  zsh-history-substring-search
  tmux
  the_silver_searcher
  ctags-exuberant
  rsync
  curl
  lynx
)

# Install packages via brew
for package in "${packages[@]}"; do
  brew install ${package}
done

# Install Cask so that Homebrew can also install OS X Applications
brew install caskroom/cask/brew-cask

# Installations via BREW CASK

# brew cask install fantastical
# brew cask install gas-mask
# brew cask install ghc
# brew cask install arq
# brew cask install torbrowser

# brew cask install launchcontrol
# brew cask install things
# brew cask install launchbar

applications=(
  # open source
  iterm2
  spectacle
  the-unarchiver
  macvim
  mactex
  firefox
  # virtualbox
  # virtualbox-extension-pack
  # vagrant
  vlc
  gpgtools
  adium
  transmission
  # proprietary
  little-snitch
  onepassword
  # things
  viscosity
  flux
)

# Install applications via brew cask
for application in "${applications[@]}"; do
  brew cask install ${application}
done

exit 0
