#!/usr/bin/env bash

#
# APT_GET
#

packages=(
  # base
  zsh
  bash
  vim
  tmux
  git
  curl
  the_silver_searcher
  ctags-exuberant
  # development
  build-essentials
  python-pip
)


# Install packages via apt-get
for package in "${packages[@]}"; do
  apt-get install -y "${package}"
done


#
# PIP
#

pip_packages=(
  pip install virtualenv
  pip install virtualenvwrapper
)

# Install packages via pip
for package in "${pip_packages[@]}"; do
  pip install "${package}"
done


exit 0
