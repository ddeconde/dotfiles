#!/usr/bin/env bash
#
# install
# Last Changed: Sun, 12 Jul 2015 22:06:02 -0700
#
# Usage:
# Set "shell" as provisioner in the appropriate Vagrantfile and the path to
# point to this script, i.e. the Vagrantfile should include a line like:
#
# config.vm.provision "shell", path: "/path/to/debian.sh"
#
# A simple provisioning script to make a minimal comfortable development
# environment out of a Debian Vagrant box. The structure of this script has
# been kept exceedingly simple as it is meant more as a list of commands
# required to put a new system in order than a configuration management tool
# and the expectation is that it will need frequent and significant alteration.
#
# All portions of this script should have the following two characteristics:
# - Idempotence: running the script multiple times should not cause problems
# - Early Failure: if any command fails then the script exits with an error


#
# CONSTANTS
#

# The paths of the dotfiles directories
readonly DOTFILE_DIR="${HOME}/dotfiles"
readonly DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
readonly DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The name (path) of the apt-get script
readonly PKGFILE="${DOTFILE_BIN_DIR}/Aptget"
readonly ZSH_PATH="/usr/bin/zsh"
readonly ZSH_USERS_REPO="https://raw.githubusercontent.com/zsh-users"
readonly ZSH_HSS_BRANCH="zsh-history-substring-search/master"
readonly ZSH_HSS_FILE="zsh-history-substring-search.zsh"
readonly ZSH_HSS_URL="${ZSH_USERS_REPO}/${ZSH_HSS_BRANCH}/${ZSH_HSS_FILE}"
readonly ZSH_HSS_PATH="/usr/local/opt/zsh-history-substring-search/${ZSH_HSS_FILE}"

 VUNDLE_PATH="${HOME}/.vim/bundle/Vundle.vim"
 README="${DOTFILE_BIN_DIR}/README.md"


#
# FUNCTIONS
#
# Most of these functions are just wrappers for simple control flow but they
# allow for the script itself to consist nearly entirely of readable
# single-line statements.

echo_error () {
  # conveniently print errors to stderr
  printf "$0: $@\n" >&2
}

do_or_exit () {
  # execute first argument command with success or exit
  # optional second argument gives error message
  # commands typically provide their own error messages, tests do not
  $@
  retval=$?
  if (( $retval != 0 )); then
    if (( $# > 1 )); then
      echo_error "$2"
    fi
    exit $retval
  fi
}

if_success () {
  # if first argument command has successful exit then do second
  if $1 > /dev/null 2>&1; then
    do_or_exit "$2"
  fi
}

if_not_success () {
  # if first argument command has successful exit then do second
  if ! $1 > /dev/null 2>&1; then
    do_or_exit "$2"
  fi
}

require_success () {
  # exit if first argument command does not succeed
  # optional second argument gives error message
  if ! $1 > /dev/null 2>&1; then
    if (( $# > 1 )); then
      echo_error "$2"
    fi
    exit 1
  fi
}

require () {
  # first argument determines type of second argument
  # exit if second argument path does not exist as correct type
  # optional third argument gives error message
  case $1 in
    "file")
      if [[ ! -f "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "dir")
      if [[ ! -d "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "link")
      if [[ ! -h "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "exec")
      if [[ ! -x "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    *)
      if [[ ! -e "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
  esac
}

if_exists () {
  # first argument determines type of second argument
  # if second argument exists then do third
  case $1 in
    "file")
      if [[ -f "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    "dir")
      if [[ -d "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    "link")
      if [[ -h "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    "exec")
      if [[ -x "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    *)
      if [[ -e "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
  esac
}

if_not_exists () {
  # first argument determines type of second argument
  # if second argument does not exist then do third
  case $1 in
    "file")
      if [[ ! -f "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    "dir")
      if [[ ! -d "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    "link")
      if [[ ! -h "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    "exec")
      if [[ ! -x "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    *)
      if [[ ! -e "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
  esac
}

link_files () {
  # symbolically link all files in first argument to second argument
  # optional third argument can be used to prefix links, e.g. with '.'
  if (( $# > 2 )); then
    pre="$3"
  fi
  for src_file in ${1}/*; do
    base_name="$(basename ${src_file})"
    if_exists "file" "${2}/${pre}${base_name}" "mv ${2}/${pre}${base_name} ${2}/${pre}${base_name}.old"
    if_exists "link" "${2}/${pre}${base_name}" "rm ${2}/${pre}${base_name}"
    if_exists "file" "${src_file}" "ln -s ${src_file} ${2}/${pre}${base_name}"
  done
}


#
# SCRIPT
#

# Run this script with superuser privileges - BE CAREFUL!
# This is necessary for some of these actions
sudo -v

# Install Git and Curl via apt-get
# do_or_exit "sudo apt-get update"
do_or_exit "sudo apt-get -y install git"
# do_or_exit "sudo apt-get -y install curl"

# Clone dotfiles repository if necessary and link dotfiles to $HOME
require_success "which git" "Git not found"
if_not_exists "dir" "${DOTFILE_DIR}" "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
require "dir" "${DOTFILE_DIR}" "${DOTFILE_DIR} not found"
link_files "${DOTFILE_DIR}" "${HOME_DIR}" "."

# Install applications via apt-get
# do_or_exit "sudo apt-get update"
# do_or_exit "sudo apt-get upgrade"
if_exists "any" "${PKGFILE}" "source ${PKGFILE}"
# do_or_exit "sudo apt-get clean"

# Install zsh-history-substring-search
if_not_exists "any" "${ZSH_HSS_PATH}" "sudo curl -fsSL --create-dirs --output ${ZSH_HSS_PATH} ${ZSH_HSS_URL}" 

# Change login shell to Z Shell
require "exec" "${ZSH_PATH}" "Z Shell not found"
if_not_success "grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | sudo tee -a /etc/shells"
do_or_exit "sudo chsh -s ${ZSH_PATH} ${USER}"

# Install Vundle and use it to install Vim plugins
# require_cmd "which git" "Git installed"
# require_cmd "which vim" "Vim installed"
# if_path_do "! -d ${VUNDLE_PATH}" "git clone git://github.com/gmarik/Vundle.vim.git ${VUNDLE_PATH}"
# do_or_exit "vim +PluginInstall +qall"

exit 0
