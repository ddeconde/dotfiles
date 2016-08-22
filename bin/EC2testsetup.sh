#!/usr/bin/env bash
#
# install
# Last Changed: Thu, 17 Dec 2015 10:49:22 -0800
#
# Usage:
# $ sudo chmod 755 EC2testsetup.sh && ./EC2testsetup.sh
#
# A simple provisioning script to make a minimal EC2 based testing
# environment out of a Debian virtual machine. The structure of this script has
# been kept exceedingly simple as it is meant more as a list of commands
# required to put a new system in order than a configuration management tool
# and the expectation is that it will need frequent and significant alteration.
#
# All portions of this script should have the following two characteristics:
# - Idempotence: running the script multiple times should not cause problems
# - Early Failure: if any command fails then the script exits with an error


#
# "CONSTANTS" (global readonly variables)
#

# Packages to be installed by apt-get
packages=(
  # BASE
  openssh-server
  curl
  git
  vim
  zsh
  bash
  screen
  # tmux
  build-essential
  awscli
  python-pip
  virtualenv
  # RESTLESS-EPHEMERIDES MODULE SUPPORT
  llvm-dev
  libedit-dev
  zlib1g-dev
  libxml2-dev
  libxslt1-dev
)

sandbox_pip_packages=(
  # BASE
  numpy
  ipython
)

# Python packages to be installed by pip
testing_pip_packages=(
  # BASE
  # RESTLESS-EPHEMERIDES MODULE SUPPORT
  'enum34'
  'llvmlite==0.5.0'
  'numba==0.19.2'
  'restless-ephemerides'
)

# The paths of the dotfiles directories
readonly DOTFILE_DIR="${HOME}/dotfiles"
readonly DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
readonly DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
readonly PRIVATE_DIR="${HOME}/private"

# name of the default python virtual environment
readonly SANDBOX_VIRTUAL_ENV="sandbox"
readonly TESTING_VIRTUAL_ENV="restless"
readonly PIP_CRT_PATH="s3://restless-vault/pip/local-pypi"


#
# SCRIPT
#

main () {
  # Superuser privileges are needed for some of these actions
  sudo -v

  # Install Git and Curl via apt-get
  do_or_exit "sudo apt-get update"
  do_or_exit "sudo apt-get -y upgrade"
  do_or_exit "sudo apt-get -y install curl"
  require_success "which curl" "curl not found"
  do_or_exit "sudo apt-get -y install git"
  require_success "which git" "git not found"

  # Clone dotfiles repository if necessary and link dotfiles to $HOME
  if_not_exists "dir" "${DOTFILE_DIR}" "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
  require "dir" "${DOTFILE_DIR}" "${DOTFILE_DIR} not found"
  link_files "${DOTFILE_DIR}" "${HOME}" "."

  # Install packages via apt-get
  for package in "${packages[@]}"; do
    sudo apt-get install -y "${package}"
    echo "$package"
  done
  # do_or_exit "sudo apt-get clean"

  # Link private files like credentials and local conf files
  # require "dir" "${PRIVATE_DIR}" "${PRIVATE_DIR} not found"
  if_exists "dir" "${PRIVATE_DIR}" "link_dir_files ${PRIVATE_DIR} ${HOME} '.'"

  # Make certain to install python packages within virtual envrinments
  require_success "which virtualenv" "virtualenv not found"
  do_or_exit "virtualenv ${TESTING_VIRTUAL_ENV}"
  do_or_exit "virtualenv ${SANDBOX_VIRTUAL_ENV}"

  # Restless Bandit pip credentials should be installed into virtualenv
  require_success "which aws" "awscli not found"
  # Before pip can install RB packages we must install our certificate
  do_or_exit "aws s3 cp ${PIP_CRT_PATH}/pip-ca.crt ${SANDBOX_VIRTUAL_ENV}/pip-ca.crt"
  do_or_exit "aws s3 cp ${PIP_CRT_PATH}/pip.conf ${SANDBOX_VIRTUAL_ENV}/pip.conf"
  do_or_exit "aws s3 cp ${PIP_CRT_PATH}/pip-ca.crt ${TESTING_VIRTUAL_ENV}/pip-ca.crt"
  do_or_exit "aws s3 cp ${PIP_CRT_PATH}/pip.conf ${TESTING_VIRTUAL_ENV}/pip.conf"

  # Install packages via pip
  for package in "${sandbox_pip_packages[@]}"; do
    ${SANDBOX_VIRTUAL_ENV}/bin/pip install "${package}"
  done
  for package in "${testing_pip_packages[@]}"; do
    ${TESTING_VIRTUAL_ENV}/bin/pip install "${package}"
  done

  # Pull restless-ephemerides from git
  do_or_exit "git clone https://github.com/restlessbandit/restless-ephemerides.git"

  # Prepare ephemerides flow configuration files
  do_or_exit "mkdir -p /etc/restless/astrologer/models/"
  do_or_exit "chmod -R a+x /etc/restless/"
  do_or_exit "cp ~/restless-ephemerides/emr_manager/confs/conf-template.yml /etc/restless/astrologer/conf"
  do_or_exit "cp ~/restless-ephemerides/emr_manager/models/models-template.yml /etc/restless/astrologer/models/default"
  # edit these configs as appropriate?

  # Change login shell to Z Shell
  # if_not_success "grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | sudo tee -a /etc/shells"
  # do_or_exit "sudo chsh -s ${ZSH_PATH} ${USER}"
  do_or_exit "sudo chsh -s zsh ${USER}"
}


#
# FUNCTIONS
#
# Most of these functions are just wrappers for simple control flow but they
# allow for the script itself to consist nearly entirely of readable
# single-line statements.

echo_error () {
  # conveniently print errors to stderr
  printf "$(basename $0): $@\n" >&2
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
    local pre="$3"
  else
    local pre=""
  fi
  for src_file in ${1}/*; do
    base_name="$(basename ${src_file})"
    if_exists "link" "${2}/${pre}${base_name}" "rm ${2}/${pre}${base_name}"
    if_exists "file" "${2}/${pre}${base_name}" "mv ${2}/${pre}${base_name} ${2}/${pre}${base_name}.old"
    if_exists "file" "${src_file}" "ln -s ${src_file} ${2}/${pre}${base_name}"
  done
}

link_subdir_files () {
  # for each subdirectory of the first argument, create a corresponding
  # subdirectory in the second argument and symbolically link all files
  # in those subdirectories of the first argument to the corresponding
  # subdirectories of the second argument
  # optional third argument can be used to prefix directories, e.g. with '.'
  if (( $# > 2 )); then
    local pre="$3"
  else
    local pre=""
  fi
  for subdir in ${1}/*; do
    base_name="$(basename ${subdir})"
    if [[ -d "${subdir}" ]]; then
      mkdir -p ${2}/${pre}${base_name}
      link_files "${subdir}" "${2}/${pre}${base_name}"
    fi
  done
}

link_dir_files () {
  # symbolically link all files in first argument to second argument
  # optional third argument can be used to prefix links, e.g. with '.'
  # also link files in subdirectories of first argument to
  # created (if necessary) subdirectories in the second argument
  # optional third argument is used to prefix created subdirectories
  link_files "${1}" "${2}" "."
  link_subdir_files "${1}" "${2}" "."
}

#
# Invoke main() to run script
#

main "$@"
exit 0
