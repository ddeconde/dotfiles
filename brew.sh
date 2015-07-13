#!/usr/bin/env bash

### Begin Homebrew commands ###

# Installations via BREW
brew install zsh
brew install vim
brew install zsh-history-substring-search
# brew install zsh-completions
brew install tmux
brew install the_silver_searcher
brew install ctags-exuberant
brew install
brew install
brew install
brew install
brew install git
# brew install git-flow

packages=(
    zsh
    bash
    vim
    zsh-history-substring-search
    tmux
    the_silver_searcher
    ctags-exuberant
    git
)

brew install ${packages[@]}

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
    firefox
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

brew cask install ${applications[@]}

# Remove out-dated versions and extra files from the cellar
brew cleanup

