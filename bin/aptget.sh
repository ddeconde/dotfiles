#!/usr/bin/env bash

#
# APT_GET
#

packages=(
  zsh
  bash
  vim
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


exit 0
