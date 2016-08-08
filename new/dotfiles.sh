#!/usr/bin/env bash
#
# dotfiles
# Last Changed: Wed, 13 Jul 2016 16:47:38 -0700
#
# Usage:
# $ bash dotfiles
#
# A simple installation script to automate symbolic linking of dotfiles to
# HOME.
#
# All portions of this script should have the following two characteristics:
# - Idempotence: running the script multiple times should not cause problems
# - Early Failure: if any command fails then the script exits with an error


#
# CONSTANTS
#

# readonly DOTFILE_DIR="${HOME}/dotfiles"
readonly DOTFILE_BIN_DIR="$(cd $(dirname "$0"); pwd -P)"
readonly DOTFILE_DIR="$(dirname "${DOTFILE_BIN_DIR}")"


#
# SCRIPT
#

main() {
  # Process options using getops builtin
  parse_opts "$@"
  # Link dotfiles to home directory
  link_files "${DOTFILES}" "${HOME}" "."
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
usage: $(basename $0) [-d dotfiles]
EOF
  exit 64
}

parse_opts () {
  # process options using getops builtin
  local OPTIND
  local opt
  while getopts ":d:" opt; do
    case ${opt} in
      d)
        DOTFILES_ARG="${OPTARG}"
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
  readonly DOTFILES="${DOTFILES_ARG:-$DOTFILE_DIR}"
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

if_exists () {
  # first argument determines type of second argument
  # if second argument exists then do third
  case $1 in
    'file')
      if [[ -f "$2" ]]; then
        do_or_exit "$3"
      fi
      ;;
    'dir')
      if [[ -d "$2" ]]; then
        do_or_exit "$3"
      fi
      ;;
    'link')
      if [[ -h "$2" ]]; then
        do_or_exit "$3"
      fi
      ;;
    'exec')
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

link_files () {
  # symbolically link all files in first argument to second argument
  # optional third argument can be used to prefix links, e.g. with '.'
  if (( $# > 2 )); then
    pre="$3"
  else
    pre=""
  fi
  for src_file in ${1}/*; do
    base_name="$(basename ${src_file})"
    if_exists "link" "${2}/${pre}${base_name}" "rm ${2}/${pre}${base_name}"
    if_exists "file" "${2}/${pre}${base_name}" "mv ${2}/${pre}${base_name} ${2}/${pre}${base_name}.old"
    if_exists "file" "${src_file}" "ln -s ${src_file} ${2}/${pre}${base_name}"
  done
}


#
# RUN MAIN()
#

main "$@"
exit 0
