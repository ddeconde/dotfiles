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
HOME_DIR="$(cd ~ && pwd)"
DOTFILE_DIR="${HOME_DIR}/.dotfiles"
DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The name (path) of the brewfile script
PKGFILE="${DOTFILE_BIN_DIR}/packages.sh"

ZSH_PATH="/usr/bin/zsh"

ZSH_USERS_REPO="https://raw.githubusercontent.com/zsh-users/"
MASTER_BRANCH="zsh-history-substring-search/master/"
ZSH_FILE="zsh-history-substring-search.zsh"
ZSH_HISTORY_SUBSTRING_SEARCH_URL="${ZSH_USERS_REPO}${MASTER_BRANCH}${ZSH_FILE}"
ZSH_HISTORY_SUBSTRING_SEARCH_PATH="/usr/local/opt/zsh-history-substring-search/"

VUNDLE_PATH="${HOME_DIR}/.vim/bundle/Vundle.vim"
README="${DOTFILE_BIN_DIR}/README.md"

USER_HOME=$


#
# FUNCTIONS
#

run_with_sudo () {
  # run this script with superuser privileges via exec sudo
  # BE VERY CAREFUL about the commands contained in this script
  if (( $(id -u) != 0 )); then
    # printf "Superuser privileges required.\n"
    exec sudo "$0" "$@"
    exit $?
  fi
}

echo_error () {
  # conveniently print errors to stderr
  printf "ERROR: $@\n" >&2
}

do_or_exit () {
  # execute first argument command with success or exit
  $@
  retval=$?
  if (( $retval != 0 )); then
    echo_error "[ $@ ] failed."
    exit $retval
  fi
}

require_cmd () {
  # exit if first argument command does not succeed
  if ! $1 > /dev/null 2>&1; then
    if (( $# > 1 )); then
      echo_error "Requirement [ $2 ] unfullfilled."
    fi
    exit 1
  fi
}

require_path () {
  # exit if first argument path does not exist as correct type
  if [[ ! $1 ]]; then
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
  if [[ $1 ]]; then
    do_or_exit "$2"
  fi
}


#
# SCRIPT
#

# Run this script with superuser privileges - BE CAREFUL!
# This is necessary for some of these actions
run_with_sudo "$@"


# Install Git and Curl via apt-get
do_or_exit "apt-get update"
do_or_exit "apt-get install git"
do_or_exit "apt-get install curl"

# Clone dotfiles repository if necessary and link dotfiles to $HOME
require_cmd "which git" "Git installed"
if_path_do "! -d ${DOTFILE_DIR}" "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
for dotfile in "$DOTFILE_DIR/*"; do
  if_path_do "-f ${HOME}/.${dotfile}" "mv ${HOME}/.${dotfile} ${HOME}/.${dotfile}.old"
  if_path_do "-f ${DOTFILE_DIR}/${dotfile}" "ln -s ${DOTFILE_DIR}/${dotfile} ${HOME}/.${dotfile}"
done

# Install applications via apt-get
do_or_exit "apt-get update"
do_or_exit "apt-get upgrade"
if_path_do "-x ${PKGFILE}" "source ${PKGFILE}"
do_or_exit "apt-get clean"

# Install zsh-history-substring-search
do_or_exit "curl - fsSL --create-dirs --output ${ZSH_HISTORY_SUBSTRING_SEARCH_PATH}/${ZSH_FILE} ${ZSH_HISTORY_SUBSTRING_SEARCH_URL}" 

# Change login shell to (Homebrew installed) Z Shell
require_path "-h ${ZSH_PATH}" "Z Shell installed"
if_cmd_do "! grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | tee -a /etc/shells"
do_or_exit "chsh -s ${ZSH_PATH} ${USER}"

# Install Vundle and use it to install Vim plugins
require_cmd "which git" "Git installed"
require_cmd "which vim" "Vim installed"
if_path_do "! -d ${VUNDLE_PATH}" "git clone git://github.com/gmarik/Vundle.vim.git ${VUNDLE_PATH}"
do_or_exit "vim +PluginInstall +qall"

exit 0
