#!/usr/bin/env bash

USER_HOME=${HOME}

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

echo $(id -u)
run_with_sudo "$@"
cd ~

# PATH_TEST=${USER_HOME}/Desktop
# USER_NAME=$(logname)
# PATH_TEST=~${USER_NAME}

# echo ${USER_NAME}
# echo $PATH_TEST
# cd "${PATH_TEST}"
whoami
PATH_TEST=$(pwd)/Desktop
echo $PATH_TEST
echo "$@"
require_cmd "which brew" "Homebrew installed"
do_or_exit "brew list"

