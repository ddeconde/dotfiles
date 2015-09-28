#!/usr/bin/env bash
#
# install
# Last Changed: Sun, 12 Jul 2015 22:06:02 -0700
#
# Usage:
# $ install
#
# A simple installation script to automate many of the tasks involved in
# setting up a new system. The structure of this script has been kept
# exceedingly simple as it is meant more as a list of commands required to put
# a new system in order than a configuration management tool and the
# expectation is that it will need frequent and significant alteration.
#
# All portions of this script should have the following two characteristics:
# - Idempotence: running the script multiple times should not cause problems
# - Early Failure: if any command fails then the script exits with an error


#
# CONSTANTS
#

# The paths of the dotfiles directories
readonly HOME_DIR="$(cd ~ && pwd)"
readonly DOTFILE_DIR="${HOME_DIR}/.dotfiles"
readonly DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
readonly DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The name (path) of the brewfile script
readonly BREWFILE="${DOTFILE_BIN_DIR}/Brewfile"
readonly ZSH_PATH="/usr/local/bin/zsh"
readonly COLORSCHEMES_PATH="${HOME_DIR}/.colorschemes"

readonly VUNDLE_PATH="${HOME_DIR}/.vim/bundle/Vundle.vim"
readonly README="${DOTFILE_BIN_DIR}/README.md"

readonly SYSTEM_NAME="${1?"Please provide a host name as argument."}"


#
# FUNCTIONS
#

run_with_sudo () {
  # run this script with superuser privileges via exec sudo
  # BE VERY CAREFUL about the commands contained in this script
  if (( $(id -u) != 0 )); then
    printf "Superuser privileges required.\n"
    exec sudo "$0" "$@"
    exit $?
  fi
}

echo_error () {
  # conveniently print errors to stderr
  printf "ERROR: $@\n" >&2
}

do_or_exit () {
  # execute argument command with success or exit
  $@
  retval=$?
  if (( $retval != 0 )); then
    echo_error "[ $@ ] failed."
    exit $retval
  fi
}

require_cmd () {
  # exit if first argument command does not succeed; echo second argument
  if ! $1 > /dev/null 2>&1; then
    if (( $# > 1 )); then
      echo_error "Requirement [ $2 ] unfullfilled."
    fi
    exit 1
  fi
}

require_path () {
  # exit if first argument path does not exist as correct type
  if [[ ! "$1" ]]; then
    if (( $# > 1 )); then
      echo_error "Requirement [ $2 ] unfullfilled."
    fi
    exit 1
  fi
}

if_cmd_do () {
  # if first argument command has successful exit then do second
  if $1 > /dev/null 2>&1; then
    do_or_exit "$2"
  fi
}

if_path_do () {
  # if first argument yields successful test then do second
  if [[ "$1" ]]; then
    do_or_exit "$2"
  fi
}

link_files () {
  # symbolically link all files in first argument to second argument in $HOME
  for src_file in "${1}/*"; do
    if_path_do "-e ${2}/.${src_file}" "mv ${2}/.${src_file} ${2}/.${src_file}.old"
    if_path_do "-f ${1}/${src_file}" "ln -s ${1}/${src_file} ${2}/${src_file}"
  done
}

#
# SCRIPT
#

# Run this script with superuser privileges - BE CAREFUL!
# This is necessary for some of these actions
run_with_sudo "$@"

# Set the system name
do_or_exit "scutil --set ComputerName ${SYSTEM_NAME}"
do_or_exit "scutil --set LocalHostName ${SYSTEM_NAME}"
do_or_exit "scutil --set HostnameName ${SYSTEM_NAME}"

# Install Xcode Command Line Tools
if_cmd_do "! xcode-select --print-path" "xcode-select --install"

# Install Homebrew
require_cmd "xcode-select --print-path" "Xcode Command Line Tools installed"
if_cmd_do "! which brew" 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

# Install Git via Homebrew
require_cmd "which brew" "Homebrew installed"
do_or_exit "brew install git"
require_cmd "which git" "Git installed"

# Clone dotfiles repository if necessary and link dotfiles to $HOME
if_path_do "! -d ${DOTFILE_DIR}" "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
require_path "-d ${DOTFILE_DIR}" "${DOTFILE_DIR} present"
link_files "${DOTFILE_DIR}" "${HOME_DIR}"

# Install applications via Homebrew
require_cmd "which brew" "Homebrew installed"
do_or_exit "brew update"
do_or_exit "brew doctor"
if_path_do "-x ${BREWFILE}" "source ${BREWFILE}"
do_or_exit "brew cleanup"

# Change login shell to (Homebrew installed) Z Shell
require_path "-h ${ZSH_PATH}" "Homebrewed Z Shell installed"
if_cmd_do "! grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | tee -a /etc/shells"
do_or_exit "chsh -s ${ZSH_PATH} ${USER}"
# do_or_exit "chsh -s /bin/zsh ${USER}"

# Download Solarized colorscheme
require_cmd "which git" "Git installed"
if_path_do "! -d ${COLORSCHEMES_PATH}" "git clone https://github.com/altercation/solarized.git ${COLORSCHEMES_PATH}"
printf "Solarized color scheme files are in ${COLORSCHEMES_PATH}\n"

# Install Vundle and use it to install Vim plugins
require_cmd "which git" "Git installed"
require_cmd "which vim" "Vim installed"
if_path_do "! -d ${VUNDLE_PATH}" "git clone https://github.com/gmarik/Vundle.vim.git ${VUNDLE_PATH}"
do_or_exit "vim +PluginInstall +qall"

# Setup Vagrant
# require_cmd "which vagrant" "Vagrant installed"
# if_cmd_do "! vagrant plugin list | grep -q vagrant-vbguest" "vagrant plugin install vagrant-vbguest"
# do_or_exit "vagrant init minimal/jessie64"

# Reminder of where the iTerm2 preferences file is
printf "Reminder: set iTerm2 -> Preferences -> General to use ${DOTFILE_BIN_DIR}/iterm2.plist\n"

# Make $HOME/bin directory for symbolic links to Homebrew-installed executables
if_path_do "! -d ${HOME}/bin" "mkdir -p ${HOME}/bin"
printf "To use Homebrew-installed executables over defaults link them to ${HOME}/bin."

# Direct user to $README
printf "See ${README} for installation and configuration instructions.\n"

exit 0
