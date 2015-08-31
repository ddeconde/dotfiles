#!/usr/bin/env bash
#
# install
# Last Changed: Sun, 12 Jul 2015 22:06:02 -0700
#
# Usage:
# $ sudo install
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
DOTFILE_DIR="${HOME}/.dotfiles"
DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The name (path) of the brewfile script
BREWFILE="${DOTFILE_BIN_DIR}/brew.sh"

README="${DOTFILE_BIN_DIR}/README.md"


# Make certain that sudo is used to run this script
if (( $(id -u) != 0 )); then
  printf "This command must be run with superuser privileges:\n" >&2
  printf "$ sudo install\n" >&2
  exit 1
fi


do_or_exit () {
  "$@"
  retval=$?
  if (( $retval != 0 )); then
    echo_error "[ $@ ] failed."
    exit $retval
  fi
}


do_or_exit_2 () {
  "$@" || \
    echo_error "[ $@ ] failed." && \
      exit 1
}


if_which () {
  if which "$1" > /dev/null 2>&1; then
    "$2"
  fi
}


echo_error () {
  printf "ERROR: $@\n" >&2
}


require () {
  # exit if first argument command does not succeed
  if ! "$1" > /dev/null 2>&1; then
    if (( $# > 1 )); then
      echo_error "Requirement [ $2 ] unfullfilled."
    fi
    exit 1
  fi
}

if_not_do () {
  # if first argument command does not succeed then do second
  if ! "$1" > /dev/null 2>&1; then
    do_or_exit "$2"
  fi
}

if_path_do () {
  if [[ "$1" ]]; then
    do_or_exit "$2"
  fi
}


#
# HOMEBREW
#

# Install Xcode command line developer tools (required for Homebrew)
if ! xcode-select --print-path > /dev/null 2>&1; then
  xcode-select --install && \
    printf "+ Xcode Command Line Tools installed.\n" || \
      { printf "- FAILED: Xcode command line tools not installed.\n"; \
        exit 1; }
fi

if_not_do "xcode-select --print-path" "xcode-select --install"
require "xcode-select --print-path" "Xcode Command Line Tools installed"
if_not_do "which brew" 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
require "which brew" "Homebrew installed"
do_or_exit "brew update"
do_or_exit "brew doctor"
if_path_do "-x ${BREWFILE}" "source ${BREWFILE}"
do_or_exit "brew cleanup"
require "which git" "Git installed"
require "which vagrant" "Vagrant installed"

# Install Homebrew
if ! which brew > /dev/null 2>&1; then
  ruby -e \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && \
    printf "+ Homebrew installed.\n" || \
    { printf "- FAILED: Homebrew not installed.\n" >&2; \
      exit 1; }
fi

if which brew > /dev/null 2>&1; then
  # Make certain that formulae are up-to-date
  brew update && \
    printf "+ Homebrew formulae updated.\n" || \
      { printf "- FAILED: Homebrew formulae not updated.\n"; \
        exit 1; }

  # Make certain that homebrew is ready for brewing
  # Right now brew doctor must be completely satisfied to continue
  printf "Running 'brew doctor'...\n"
  brew doctor && \
    printf "+ Brew doctor satisfied.\n"|| \
      { printf "- FAILED: Unresolved brew doctor warnings or errors.\n"; \
        exit 1; }

  # If the brewfile script exists and is executable, run it
 
  [[ -x "${BREWFILE}" ]] && \
    { printf "Running ${BREWFILE}...\n"; source "${BREWFILE}" } || \
      { printf "- FAILED: A problem occured while running ${BREWFILE}.\n"; \
        exit 1; }

  # Remove out-dated versions and extra files from the cellar
  printf "Running 'brew cleanup'...\n"
  brew cleanup && \
    printf "+ Brew cleanup succeeded.\n" || \
      printf "- FAILED: Brew cleanup failed.\n"
fi

# Make certain that Git is installed
if ! which git > /dev/null 2>&1; then
  printf "No installation of Git was found.\n" >&2
  printf "Install Git via Homebrew or Xcode command line tools.\n" >&2
  exit 1
fi


#
# VAGRANT
#

if which vagrant > /dev/null 2>&1; then
  if ! vagrant plugin list | grep -q vagrant-vbgest; then
    vagrant plugin install vagrant-vbguest || \
      { printf "A problem occured while installing vagrant-vbguest.\n" >&2; \
        exit 1; }
  fi
  # Initialize a mininalist Debian box
  vagrant init minimal/jessie64 || \
    printf "- FAILED: Vagrant box minimal/jessie64 not initialized.\n"
fi



#
# SHELL
#

# Append Homebrewed Zsh path to /etc/shells to authorize it as a login shell
# and then change this user's login shell to this Zsh
if [[ -h "/usr/local/bin/zsh" ]]; then
  if ! grep -q /usr/local/bin/zsh /etc/shells; then
      echo "/usr/local/bin/zsh" | tee -a /etc/shells && \
        chsh -s /usr/local/bin/zsh "${USER}" || \
          { printf "A problem occurred while changing the login shell.\n" >&2; \
            exit 1; }
  fi
elif [[ -x "/bin/zsh" ]]; then
  chsh -s /bin/zsh "${USER}" && \
    printf "Homebrewed Zsh not found, using /bin/zsh as login shell.\n" >&2 || \
      { printf "A problem occured while changing the login shell.\n" >&2; \
        exit 1; }
else
  printf "Zsh not found, leaving login shell unchanged.\n" >&2
fi


#
# COLOR SCHEMES
#

# Install Solarized
COLORSCHEMES_PATH="${HOME}/.colorschemes"
if [[ ! -d "${COLORSCHEMES_PATH}" ]]; then
  git clone git://github.com/altercation/solarized.git ${COLORSCHEMES_PATH} && \
    printf "Solarized color scheme files are in ${COLORSCHEMES_PATH}\n" || \
      { printf "A problem occured while cloning the Solarized repository.\n" >&2; \
        exit 1; }
fi


#
# VIM PLUGINS
#

# Install Vundle, then use it to install Vim plugins
VUNDLE_PATH="${HOME}/.vim/bundle/Vundle.vim"
if which vim > /dev/null 2>&1; then
  if [[ ! -d "${VUNDLE_PATH}" ]]; then
    git clone https://github.com/gmarik/Vundle.vim.git ${VUNDLE_PATH} && \
      vim +PluginInstall +qall || \
        { printf "A problem occured while setting up Vim plugins." >&2; \
          exit 1; }
  fi
else
  printf "No installation of Vim was found; Vim plugins not installed.\n" >&2
fi


#
# DOTFILES
#


if [[ ! -d "${DOTDIR}" ]]; then
  git clone git://github.com/"${DOTFILE_GIT_REPO}" "${DOTFILE_DIR}" || \
    { printf "A problem occured while cloning the dotfiles repository." >&2; \
      exit 1; }
fi

# Save any existing dotfiles and then sym-link from DOTFILE_DIR to HOME
for dotfile in "$DOTFILE_DIR/*"; do
  if [[ -f "${HOME}/.${dotfile}" ]]; then
    mv "${HOME}/.${dotfile}" "${HOME}/.${dotfile}.old" || \
      { printf "A problem occured while saving pre-existing dotfiles." >&2; \
        exit 1; }
  fi
  if [[ -f "${DOTFILE_DIR}/${dotfile}" ]]; then
    ln -s "${DOTFILE_DIR}/${dotfile}" "${HOME}/.${dotfile}" || \
      { printf "A problem occured while linking dotfiles to ${HOME}." >&2; \
        exit 1; }
  fi
done


#
# ITERM2
#

# Reminder of where the iTerm2 preferences file is
printf "Reminder: set iTerm2 -> Preferences -> General to use ${DOTFILE_BIN_DIR}/iterm2.plist\n"


#
# HOMEBREW SYMBOLIC LINKS
#

# Make a user bin directory that occurs early in PATH
if [[ ! -d "${HOME}/bin" ]]; then
  mkdir ~/bin && \
    echo "To use homebrewed executables over defaults link them to ${HOME}/bin."
fi
# Actual linking of executables to ~/bin should be done by hand


printf "See ${README} for installation and configuration instructions.\n"


exit 0
