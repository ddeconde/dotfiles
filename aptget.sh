#!/usr/bin/env bash

### Begin apt-get commands ###

# Installations via apt-get
brew install zsh
brew install vim
brew install zsh-history-substring-search
# brew install zsh-completions
brew install tmux
brew install the_silver_searcher
brew install ctags-exuberant
brew install git
# brew install git-flow

packages=(
  zsh
  bash
  vim
  zsh-history-substring-search
  tmux
  git
  the_silver_searcher
  ctags-exuberant
  build-essentials
  python-pip
)


# Install packages via brew
for package in ${packages}; do
  brew install ${package}
done

# Install Cask so that Homebrew can also install OS X Applications
brew install caskroom/cask/brew-cask

# Installations via BREW CASK
brew cask install iterm2
brew cask install spectacle
brew cask install mactex
brew cask install macvim
brew cask install the-unarchiver
brew cask install firefox
brew cask install little-snitch
brew cask install onepassword
brew cask install things
brew cask install cheatsheet
brew cask install viscosity
brew cask install vlc
# brew cask install adium
brew cask install virtualbox
brew cask install vagrant
brew cask install ghc
brew cask install

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
  cheatsheet
  virtualbox
  vagrant
  ghc
  vlc
  flux
)


# Install applications via brew cask
for application in ${applications}; do
  brew cask install ${application}
done


# Remove out-dated versions and extra files from the cellar
brew cleanup


exit 0
