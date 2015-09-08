#!/usr/bin/env bash

HOME_DIR="$(cd ~ && pwd)"
SYS_NAME="${1?"Please provide a host name as argument."}"

run_with_sudo () {
  # run this script with superuser privileges via exec sudo
  # BE VERY CAREFUL about the commands contained in this script
  if (( $(id -u) != 0 )); then
    # printf "Superuser privileges required.\n"
    exec sudo "$0" "$@"
    # exec sudo "$0" "${HOME}" "$@"
    exit $?
  # else
  #   USER_HOME="$1"
  #   shift
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
  if [[ $1 ]]; then
    do_or_exit "$2"
  fi
}

if_dir_empty_do () {
  if [[ -d $1 ]] && [[ ! "$(ls -A $1)" ]]; then
    do_or_exit "$2"
  fi
}

echo $(id -u)
run_with_sudo "$@"
cd ~

# PATH_TEST=${USER_HOME}/Desktop
# USER_NAME=$(logname)
# PATH_TEST=~${USER_NAME}

# echo ${USER_NAME}
# echo $PATH_TEST
# cd "${PATH_TEST}"
# whoami
# PATH_TEST=$(pwd)/Desktop
# echo $PATH_TEST
# echo "$@"
echo $HOME_DIR
require_cmd "which brew" "Homebrew installed"
# require_path "-d ${PATH_TEST}" "${PATH_TEST} directory exists"
# do_or_exit "brew list"
# if_cmd_do "which gitt" "ls -l"
if_dir_empty_do "$(pwd)/tst" "brew list"

