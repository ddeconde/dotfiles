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
readonly HOME_DIR="$(cd ~ && pwd)"
readonly DOTFILE_DIR="${HOME_DIR}/.dotfiles"
readonly DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
readonly DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The name (path) of the brewfile script
readonly PKGFILE="${DOTFILE_BIN_DIR}/Aptget"
readonly ZSH_PATH="/usr/bin/zsh"
readonly ZSH_USERS_REPO="https://raw.githubusercontent.com/zsh-users"
readonly ZSH_HSS_BRANCH="zsh-history-substring-search/master"
readonly ZSH_HSS_FILE="zsh-history-substring-search.zsh"
readonly ZSH_HSS_URL="${ZSH_USERS_REPO}/${ZSH_HSS_BRANCH}/${ZSH_HSS_FILE}"
readonly ZSH_HSS_PATH="/usr/local/opt/zsh-history-substring-search/${ZSH_HSS_FILE}"

 VUNDLE_PATH="${HOME_DIR}/.vim/bundle/Vundle.vim"
 README="${DOTFILE_BIN_DIR}/README.md"


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
  for src_file in ${1}/*; do
    base_name="$(basename ${src_file})"
    # if_path_do "-e ${2}/${base_name}" "mv ${2}/${base_name} ${2}/${base_name}.old"
    if_path_do "-e ${2}/${base_name}" "echo ${2}/${base_name}"
    if_path_do "-f ${src_file}" "ln -s ${src_file} ${2}/${base_name}"
  done
}


#
# SCRIPT
#

# Run this script with superuser privileges - BE CAREFUL!
# This is necessary for some of these actions
# run_with_sudo "$@"
sudo -v

# Install Git and Curl via apt-get
# do_or_exit "sudo apt-get update"
do_or_exit "sudo apt-get -y install git"
do_or_exit "sudo apt-get -y install curl"

# Clone dotfiles repository if necessary and link dotfiles to $HOME
require_cmd "which git" "Git installed"
if_path_do "! -d ${DOTFILE_DIR}" "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
require_path "-d ${DOTFILE_DIR}" "${DOTFILE_DIR} present"
link_files "${DOTFILE_DIR}" "${HOME_DIR}"
# for dotfile in "$DOTFILE_DIR/*"; do
#   if_path_do "-f ${HOME}/.${dotfile}" "mv ${HOME}/.${dotfile} ${HOME}/.${dotfile}.old"
#   if_path_do "-f ${DOTFILE_DIR}/${dotfile}" "ln -s ${DOTFILE_DIR}/${dotfile} ${HOME}/.${dotfile}"
# done

# Install applications via apt-get
# do_or_exit "sudo apt-get update"
# do_or_exit "sudo apt-get upgrade"
# if_path_do "-x ${PKGFILE}" "sudo source ${PKGFILE}"
# do_or_exit "sudo apt-get clean"

# Install zsh-history-substring-search
if_path_do "! -e ${ZSH_HSS_PATH}" "sudo curl -fsSL --create-dirs --output ${ZSH_HSS_PATH} ${ZSH_HSS_URL}" 

# Change login shell to (Homebrew installed) Z Shell
require_path "-h ${ZSH_PATH}" "Z Shell installed"
if_cmd_do "! grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | sudo tee -a /etc/shells"
do_or_exit "sudo chsh -s ${ZSH_PATH} ${USER}"

# Install Vundle and use it to install Vim plugins
# require_cmd "which git" "Git installed"
# require_cmd "which vim" "Vim installed"
# if_path_do "! -d ${VUNDLE_PATH}" "git clone git://github.com/gmarik/Vundle.vim.git ${VUNDLE_PATH}"
# do_or_exit "vim +PluginInstall +qall"

exit 0
