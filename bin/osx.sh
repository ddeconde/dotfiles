#!/usr/bin/env bash
#
# install
# Last Changed: Sun, 12 Jul 2015 22:06:02 -0700
#
# Usage:
# $ install
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
# CONSTANTS
#

# The paths of the dotfiles directories
readonly DOTFILE_DIR="${HOME}/dotfiles"
readonly DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
readonly DOTFILE_ETC_DIR="${DOTFILE_DIR}/etc"
readonly DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The name (path) of the brewfile script
readonly BREWFILE="${DOTFILE_BIN_DIR}/Brewfile"
readonly ZSH_PATH="/usr/local/bin/zsh"
readonly COLORS_PATH="${HOME_DIR}/.colorschemes"
readonly BACKUP_DIR="${HOME}/.backup"
readonly README="${DOTFILE_ETC_DIR}/README.md"
readonly SYSTEM_NAME="${1}"
readonly PRIVATE_DIR="${HOME}/private"

# Installations via BREW

# Formulae for particular versions of packages can be installed via 'brew
# install homebrew/versions/<formula>'

# Formulae for more recent/bug-fixed versions of already included OS X
# utilities can be installed via 'brew install homebrew/dupes/<formula>'

# git is excluded as it will always be installed outside of brew.sh
packages=(
  zsh
  vim
  tmux
  zsh-history-substring-search
  the_silver_searcher
  ctags-exuberant
  homebrew/dupes/rsync
  bash
  curl
  lynx
)

# Installations via BREW CASK

# brew cask install gas-mask
# brew cask install ghc
# brew cask install arq
# brew cask install launchcontrol
# brew cask install things
# brew cask install hosts
# brew cask install flux
# brew cask install gpgtools

applications=(
  iterm2
  spectacle
  the-unarchiver
  macvim
  mactex
  firefox
  torbrowser
  vlc
  adium
  transmission
  little-snitch
  launchbar
  onepassword
  carbon-copy-cloner
  viscosity
  vmware-fusion
  dash
)

# Homebrew packages to link to HOME/bin for PATH priority over defaults
readonly HOME_BIN_LINKS=(
  git
  vim
  zsh
  bash
  curl
)


#
# SCRIPT
#

main () {
  # An argument specifying hostname is required
  if (( $# != 1 )); then
    printf "usage: $0 hostname\n"
    exit 64
  fi

  # Run this script with superuser privileges - BE CAREFUL!
  # This is necessary for some of these actions
  sudo -v

  # Set the system name
  do_or_exit "sudo scutil --set ComputerName ${SYSTEM_NAME}"
  do_or_exit "sudo scutil --set LocalHostName ${SYSTEM_NAME}"
  do_or_exit "sudo scutil --set HostnameName ${SYSTEM_NAME}"

  # Install Xcode Command Line Tools
  if_not_success "xcode-select --print-path" "xcode-select --install"
  require_success "xcode-select --print-path" "Xcode Command Line Tools not found"

  # Install Homebrew
  if_not_success "which brew" 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  require_success "which brew" "Homebrew not found"

  # Install Git via Homebrew
  do_or_exit "brew install git"
  require_success "which git" "Git not found"

  # Clone dotfiles repository if necessary and link dotfiles to $HOME
  if_not_exists "dir" "${DOTFILE_DIR}" "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
  require "dir" "${DOTFILE_DIR}" "${DOTFILE_DIR} not found"
  link_files "${DOTFILE_DIR}" "${HOME_DIR}" "."

  # Install applications via Homebrew
  do_or_exit "brew update"
  do_or_exit "brew doctor"
  for package in "${packages[@]}"; do
    brew install ${package}
  done

  # Install Cask so that Homebrew can also install OS X Applications
  brew install caskroom/cask/brew-cask

  # Install applications via brew cask
  for application in "${applications[@]}"; do
    brew cask install ${application}
  done
  do_or_exit "brew cleanup"

  # Link private files like credentials and local conf files
  # require "dir" "${PRIVATE_DIR}" "${PRIVATE_DIR} not found"
  if_exists "dir" "${PRIVATE_DIR}" "link_dir_files ${PRIVATE_DIR} ${HOME} '.'"

  # Change login shell to (Homebrew installed) Z Shell
  require "exec" "${ZSH_PATH}" "Homebrewed Z Shell not found"
  if_not_success "grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | sudo tee -a /etc/shells"
  do_or_exit "sudo chsh -s ${ZSH_PATH} ${USER}"

  # Make $HOME/.backup directory for rsync backup logs
  if_not_exists "dir" "${BACKUP_DIR}" "mkdir -p ${BACKUP_DIR}"

  # Download Solarized colorscheme
  if_not_exists "dir" "${COLORS_PATH}" "git clone https://github.com/altercation/solarized.git ${COLORS_PATH}"
  printf "Solarized color scheme files are in ${COLORS_PATH}\n"

  # Reminder of where the iTerm2 preferences file is
  printf "Reminder: set iTerm2 Preferences to load from a custom folder or URL:\n ${DOTFILE_ETC_DIR}\n"

  # Make $HOME/bin directory for symbolic links to Homebrew-installed executables
  if_not_exists "dir" "${HOME}/bin" "mkdir -p ${HOME}/bin"
  # Symlink Homebrew-installed executables to $HOME/bin
  for bin in "${HOME_BIN_LINKS[@]}"; do
    if_exists "any" "/usr/local/bin/${bin}" "ln -s /usr/local/bin ${HOME}/bin/${bin}"
  done

  # Direct user to $README
  printf "See ${README} for installation and configuration instructions.\n"
}


#
# FUNCTIONS
#
# Most of these functions are just wrappers for simple control flow but they
# allow for the script itself to consist nearly entirely of readable
# single-line statements.

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
    pre="$3"
  else
    pre=""
  fi
  for src_file in ${1}/*; do
    base_name="$(basename ${src_file})"
    if_exists "file" "${2}/${pre}${base_name}" "mv ${2}/${pre}${base_name} ${2}/${pre}${base_name}.old"
    if_exists "link" "${2}/${pre}${base_name}" "rm ${2}/${pre}${base_name}"
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

get_app () {
  curl -s -L -o "${APP_TEMP_DIR}/${APP_NAME}" "${APP_URL}"
}

#
# RUN MAIN()
#

main "$@"
exit 0
