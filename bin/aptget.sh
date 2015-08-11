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


exit 0
