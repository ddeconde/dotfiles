#!/usr/bin/env bash
#
# install
# Last Changed: Sun, 20 Mar 2016 20:45:34 -0700
#
# Usage:
# $ bash setup
#
# A simple installation script to automate many of the tasks involved in
# setting up a new system. The structure of this script has been kept
# exceedingly simple as it is meant more as a list of commands required to put
# a new system in order than a configuration management tool and the
# expectation is that it will need frequent and significant alteration.
#
# All portions of this script should have the following two characteristics:
# - Idempotence: running the script multiple times should not cause problems
# - Early Failure: if any command fails then the script exits with an error


#
# "CONSTANTS" (global readonly variables)
#

# Packages to be installed by apk
readonly packages=(
  # Basics
  curl
  vim
  bash
  zsh
  zsh-vcs
  # -zsh-completion
  tmux
  git
  tig
  rsync
  ag
  fzf
  htop
  mc
  calcurse
  task
  # Network
  iproute2
  iw
  wpa_supplicant
  openvpn
  # Security
  pass
  # Backup
  rsnapshot
  restic
  # Web
  lynx
  luakit

  # Mail
  mutt
  isync
  notmuch
  # Chat
  weechat
  # Documents
  texlive-full
  zathura
  # Media
  feh
  cmus
  mpv
  # Containers
  lxd
  # Desktop
  i3wm
  i3status
  rxvt-unicode
  # Fonts
  terminus
  ttf-dejavu
  # System
  acpi
  powertop
  # X
  xf86-video-intel
  xf86-input-libinput
  xorg-server
  eudev
  # # AWS
  # awscli
  # # Python
  # python-pip
  # virtualenv
)

# Python packages to be installed by pip
pip_packages=(
  numpy
)


# The default name for the required administrative user account
readonly ADMIN_USER="admin"
# The default paths to installation and configuration related assets
readonly DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
readonly DOTFILE_DIR="${HOME}/dotfiles"
readonly PRIVATE_DIR="${HOME}/private"
readonly BACKUP_VOL="/Volumes/Haversack"
readonly TMP_DIR="~${USER}/apps"
readonly APP_DIR="/Applications"
readonly ZSH_PATH="/usr/local/bin/zsh"
readonly COLORS_PATH="${HOME}/etc/solarized"
# Verbose by default
readonly VERBOSE_DEFAULT=1


# Directories to be copied from backup volume
readonly backup_dirs=(
  dotfiles
  private
  etc
  Documents
  Projects
)



#
# SCRIPT
#

main () {
  # Process options using getops builtin
  parse_opts "$@"

  # Run this script with superuser privileges - BE CAREFUL!
  # This is necessary for some of these actions
  sudo -v

  # Require network connectivity
  require_success "check_ip_and_dns"

  # Install Git and Curl via apt-get
  do_or_exit "sudo apt-get update"
  do_or_exit "sudo apt-get -y upgrade"
  do_or_exit "sudo apt-get -y install curl"
  require_success "which curl" "curl not found"
  do_or_exit "sudo apt-get -y install git"
  require_success "which git" "git not found"

  # Install packages via apt-get
  for package in "${packages[@]}"; do
    sudo apt-get install -y "${package}"
    echo "$package"
  done
  # do_or_exit "sudo apt-get clean"

  # Copy backup data into place if available
  for dir in "${backup_dirs[@]}"; do
    if_exists "dir" "${BACKUP}/${dir}" "cp -R ${BACKUP}/${dir} ${HOME}/${dir}"
  done

  # Clone dotfiles repository if necessary
  require_success "which git" "git not found"
  if_not_exists "dir" "${DOTFILES}" "git clone git://github.com/${GIT_REPO} ${DOTFILES}"

  # Link dotfiles to home directory
  require "dir" "${DOTFILES}" "${DOTFILES} not found"
  link_files "${DOTFILES}" "${HOME}" "."

  # Link private files like credentials and local conf files
  if_exists "dir" "${PRIVATE}" "link_dir_files ${PRIVATE} ${HOME} '.'"

  # Change login shell to (Homebrew installed) Z Shell
  add_login_shell "${ZSH_PATH}"
  do_or_exit "sudo chsh -s ${ZSH_PATH} ${USER}"

  # Make $HOME/bin directory for symbolic links to Homebrew-installed executables
  if_not_exists "dir" "${HOME}/bin" "mkdir -p ${HOME}/bin"
  # Symlink Homebrew-installed executables to $HOME/bin
  for bin in "${HOME_BIN_LINKS[@]}"; do
    if_exists "any" "/usr/local/bin/${bin}" "ln -s /usr/local/bin ${HOME}/bin/${bin}"
  done

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
usage: $(basename $0) [-a admin] [-b backup] [-d dotfiles] [-p private]
[-q] [-r repo] hostname
EOF
  exit 64
}

parse_opts () {
  # process options using getops builtin
  local OPTIND
  local opt
  while getopts ":a:b:d:pqr:" opt; do
    case ${opt} in
      a)
        ADMIN_ARG="${OPTARG}"
        ;;
      b)
        BACKUP_ARG="${OPTARG}"
        ;;
      d)
        DOTFILES_ARG="${OPTARG}"
        ;;
      p)
        PRIVATE_ARG="${OPTARG}"
        ;;
      q)
        VERBOSE_ARG=0
        ;;
      r)
        REPO_ARG="${OPTARG}"
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
  # An argument specifying the hostname is required
  if (( $# != 1 )); then
    usage
  fi
  readonly SYSTEM_NAME="$1"
  readonly ADMIN="${ADMIN_ARG:-$ADMIN_USER}"
  readonly BACKUP_PATH="${BACKUP_VOL}/Users/${USER}"
  readonly BACKUP="${BACKUP_ARG:-$BACKUP_PATH}"
  readonly DOTFILES="${DOTFILES_ARG:-$DOTFILE_DIR}"
  readonly PRIVATE="${PRIVATE_ARG:-$PRIVATE_DIR}"
  readonly GIT_REPO="${REPO_ARG:-$DOTFILES_GIT_REPO}"
  readonly VERBOSE="${VERBOSE_ARG:-$VERBOSE_DEFAULT}"
}

echo_error () {
  # conveniently print errors to stderr
  printf "$0: $@\n" >&2
}

echo_if_verbose () {
  # if the VERBOSE variable is set then print argument to stdout
  if (( $VERBOSE > 0 )); then
    printf "$0: $@\n"
  fi
  # if [[ -z ${VERBOSE+x} ]]; then
  #   printf "$0: $@\n"
  # fi
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

if_not_exists () {
  # first argument determines type of second argument
  # if second argument does not exist then do third
  case $1 in
    'file')
      if [[ ! -f "$2" ]]; then
        do_or_exit "$3"
      fi
      ;;
    'dir')
      if [[ ! -d "$2" ]]; then
        do_or_exit "$3"
      fi
      ;;
    'link')
      if [[ ! -h "$2" ]]; then
        do_or_exit "$3"
      fi
      ;;
    'exec')
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
  link_files "${1}" "${2}" "${3}"
  link_subdir_files "${1}" "${2}" "${3}"
}

check_ip_and_dns () {
  # verify IP and DNS connectivity
  # replace google.com with 8.8.8.8 below to check only IPv4 connectivity
  if ping -q -c 1 -W 1 google.com > /dev/null 2>&1 ; then
    echo_if_verbose "network check successful"
    return 0
  else
    echo_error "network connection not found"
    return 1
  fi
}


#
# RUN MAIN()
#

main "$@"
exit 0
