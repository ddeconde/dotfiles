#!/usr/bin/env bash
#
# private
# Last Changed: Wed, 13 Jul 2016 16:47:38 -0700
#
# Usage:
# $ bash private
#
# A simple installation script to automate symbolic linking of private files
# like credentials and local configuration files to $HOME.
#
# All portions of this script should have the following two characteristics:
# - Idempotence: running the script multiple times should not cause problems
# - Early Failure: if any command fails then the script exits with an error


#
# CONSTANTS
#

# readonly PRIVATE_DIR="${HOME}/private"
readonly PRIVATE_BIN_DIR="$(cd $(dirname "$0"); pwd -P)"
readonly PRIVATE_DIR="$(dirname "${PRIVATE_BIN_DIR}")"


#
# SCRIPT
#

main() {
  # Process options using getops builtin
  parse_opts "$@"
  # Link private files like credentials and local conf files
  link_dir_files "${PRIVATE}" "${HOME}" "."
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
usage: $(basename $0) [-p private]
EOF
  exit 64
}

parse_opts () {
  # process options using getops builtin
  local OPTIND
  local opt
  while getopts ":p:" opt; do
    case ${opt} in
      p)
        PRIVATE_ARG="${OPTARG}"
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
  readonly PRIVATE="${PRIVATE_ARG:-$PRIVATE_DIR}"
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
  for src_file in ${1}/*; do
    base_name="$(basename ${src_file})"
    if_exists "link" "${2}/${3}${base_name}" "rm ${2}/${3}${base_name}"
    if_exists "file" "${2}/${3}${base_name}" "mv ${2}/${3}${base_name} ${2}/${3}${base_name}.old"
    if_exists "file" "${src_file}" "ln -s ${src_file} ${2}/${3}${base_name}"
  done
}

link_subdir_files () {
  # for each subdirectory of the first argument, create a corresponding
  # subdirectory in the second argument and symbolically link all files
  # in those subdirectories of the first argument to the corresponding
  # subdirectories of the second argument
  # optional third argument can be used to prefix directories, e.g. with '.'
  for subdir in ${1}/*; do
    base_name="$(basename ${subdir})"
    # ignore the directory containing this script
    if [[ "${subdir}" == "${PRIVATE_BIN_DIR}" ]]; then
      continue
    fi
    if [[ -d "${subdir}" ]]; then
      mkdir -p ${2}/${3}${base_name}
      link_files "${subdir}" "${2}/${3}${base_name}"
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
# RUN MAIN()
#

main "$@"
exit 0
