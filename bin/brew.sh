#!/usr/bin/env bash

### Begin Homebrew commands ###

# Installations via BREW
# brew install zsh-completions
# brew install coreutils

# Enable easy brewing of duplicate utilities
brew tap homebrew/dupes

packages=(
  zsh
  bash
  vim
  zsh-history-substring-search
  tmux
  the_silver_searcher
  ctags-exuberant
  git
  rsync
  curl
)


# Install packages via brew
for package in ${packages}; do
  brew install ${package}
done

# Install Cask so that Homebrew can also install OS X Applications
brew install caskroom/cask/brew-cask

# Installations via BREW CASK
# brew cask install fantastical
# brew install alfred
# brew cask install ghc
# brew cask install arq
# brew cask install adium
# brew cask install gpgtools

applications=(
  iterm2
  spectacle
  the-unarchiver
  macvim
  mactex
  icecat
  little-snitch
  onepassword
  things
  viscosity
  virtualbox
  vagrant
  vlc
  flux
)


# Install applications via brew cask
for application in ${applications}; do
  brew cask install ${application}
done


exit 0
