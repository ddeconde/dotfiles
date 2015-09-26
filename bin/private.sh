#!/usr/bin/env bash
#
# private
# Laste Changed: Fri, 25 Sep 2015 21:56:00 -0700
#
# Usage:
# $ private
#
# A simple installation script to automate the linking of several sensitive
# configuration and credential files from a convenient private directory into
# the locations where applications expect them to be found.


readonly HOME_DIR="$(cd ~ && pwd)"
readonly PRIVATE_DIR="${HOME_DIR}/private"
readonly SSH_DIR=".ssh"
readonly GPG_DIR=".gpg"
readonly AWS_DIR=".aws"
readonly LOCAL_DIR=".local"
readonly PRIVATE_ETC="${PRIVATE_DIR}/etc"


do_or_exit () {
  # execute argument command with success or exit
  $@
  retval=$?
  if (( $retval != 0 )); then
    echo_error "[ $@ ] failed."
    exit $retval
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

if_path_do () {
  # if first argument yields successful test then do second
  if [[ "$1" ]]; then
    do_or_exit "$2"
  fi
}

link_files () {
  # symbolically link all files in first argument to second argument in $HOME
  for src_file in "${1}/*"; do
      if_path_do "-f ${2}/.${src_file}" "mv ${2}/.${src_file} ${2}/.${src_file}.old"
    do_or_exit "ln -s ${1}/${src_file} ${2}/${src_file}"
  done
}


#
# Script
# 

require_path "-d ${PRIVATE_DIR}" "${PRIVATE_DIR} exists"

# Link ssh files
require_path "-d ${PRIVATE_DIR}/${SSH_DIR}" "${PRIVATE_DIR}/${SSH_DIR} exists"
if_path_do "! -d ${HOME_DIR}/.${SSH_DIR}" "mkdir -p ${HOME_DIR}/.${SSH_DIR}"
link_files "${PRIVATE_DIR}/${SSH_DIR}" "${HOME_DIR}/.${SSH_DIR}"

# Link gpg files
require_path "-d ${PRIVATE_DIR}/${GPG_DIR}" "${PRIVATE_DIR}/${GPG_DIR} exists"
if_path_do "! -d ${HOME_DIR}/.${GPG_DIR}" "mkdir -p ${HOME_DIR}/.${GPG_DIR}"
link_files "${PRIVATE_DIR}/${GPG_DIR}" "${HOME_DIR}/.${GPG_DIR}"

# Link aws files
require_path "-d ${PRIVATE_DIR}/${AWS_DIR}" "${PRIVATE_DIR}/${AWS_DIR} exists"
if_path_do "! -d ${HOME_DIR}/.${AWS_DIR}" "mkdir -p ${HOME_DIR}/.${AWS_DIR}"
link_files "${PRIVATE_DIR}/${AWS_DIR}" "${HOME_DIR}/.${AWS_DIR}"

# Link local configuration files
link_files "${PRIVATE_DIR}/${LOCAL_DIR}" "${HOME_DIR}"

printf "Private data/configuration files are in ${PRIVATE_ETC}:\n"
ls ${PRIVATE_ETC}


exit 0
