#!/usr/bin/env bash
#
# private
# Last Changed: Sun, 31 Jul 2016 20:23:29 -0700}
#
# Usage:
# $ bash hosts.sh
#
# A simple script to update the `/etc/hosts` file from online sources of
# community consolidated lists of adware and malware domains. Before using this
# the original `/etc/hosts` file should be renamed to `/etc/hosts.default` to
# allow for recovery of the system defaults.
#
# All portions of this script should have the following two characteristics:
# - Idempotence: running the script multiple times should not cause problems
# - Early Failure: if any command fails then the script exits with an error


#
# CONSTANTS
#

readonly GIT_LOCAL="${HOME}/.git.local"


#
# SCRIPT
#

main() {
  # Process options using getops builtin
  parse_opts "$@"

  # Execute appropriate subcommand
  case ${IDENTITY} in
    default)
      require "file" "${GIT_LOCAL}.default" "no default credentials found"
      do_or_exit "cp ${GIT_LOCAL}.default ${GIT_LOCAL}"
      ;;
    private)
      require "file" "${GIT_LOCAL}.private" "no private credentials found"
      do_or_exit "cp ${GIT_LOCAL}.private ${GIT_LOCAL}"
      ;;
    work)
      require "file" "${GIT_LOCAL}.work" "no work credentials found"
      do_or_exit "cp ${GIT_LOCAL}.work ${GIT_LOCAL}"
      ;;
    *)
      usage
      ;;
  esac
}


#
# FUNCTIONS
#
# Most of these functions are just wrappers for simple control flow but they
# allow for the script itself to consist nearly entirely of readable
# single-line statements.

usage () {
  # print usage message from here doc
  # here doc requires no indentation
cat <<EOF
usage: $(basename $0) default | private | work
EOF
  exit 64
}

parse_opts () {
  # process options using getops builtin
  local OPTIND
  local opt
  while getopts ":u:" opt; do
    case ${opt} in
      u)
        HOSTS_URL_ARG="${OPTARG}"
        ;;
      \?)
        printf "$(basename $0): illegal option -- %s\n" ${OPTARG} >&2
        usage
        ;;
      :)
        printf "$(basename $0): missing argument for -%s\n" ${OPTARG} >&2
        usage
        ;;
    esac
  done
  # Shift to process positional arguments
  shift $(( OPTIND - 1 ))
  # An argument specifying the subcommand is required
  if (( $# != 1 )); then
    usage
  fi
  readonly COMMAND="$1"
  readonly HOSTS_URL="${HOSTS_URL_ARG:-$DEFAULT_URL}"
}

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

require () {
  # first argument determines type of second argument
  # exit if second argument path does not exist as correct type
  # optional third argument gives error message
  case $1 in
    'file')
      if [[ ! -f "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
      ;;
    'dir')
      if [[ ! -d "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
      ;;
    'link')
      if [[ ! -h "$2" ]]; then
        if (( $# > 2 )); then
          echo_error "$3"
        fi
        exit 1
      fi
      ;;
    'exec')
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


#
# RUN MAIN()
#

main "$@"
exit 0
