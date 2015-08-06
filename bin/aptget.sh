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
  curl
  the_silver_searcher
  ctags-exuberant
  build-essentials
  python-pip
)


# Install packages via apt-get
for package in ${packages}; do
  apt-get install -y ${package}
done

# Remove out-dated versions and extra files from the cellar
brew cleanup


exit 0
