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
HOME_DIR="$(cd ~ && pwd)"
DOTFILE_DIR="${HOME_DIR}/.dotfiles"
DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
DOTFILE_GIT_REPO="https://github.com/ddeconde/dotfiles.git"
# The name (path) of the brewfile script
BREWFILE="${DOTFILE_BIN_DIR}/brew.sh"

ZSH_PATH="/usr/local/bin/zsh"
COLORSCHEMES_PATH="${HOME_DIR}/.colorschemes"
VUNDLE_PATH="${HOME_DIR}/.vim/bundle/Vundle.vim"
README="${DOTFILE_BIN_DIR}/README.md"

SYSTEM_NAME="${1?"Please provide a host name as argument."}"


#
# FUNCTIONS
#

run_with_sudo () {
  # run this script with superuser privileges via exec sudo
  # BE VERY CAREFUL about the commands contained in this script
  if (( $(id -u) != 0 )); then
    printf "Superuser privileges required.\n"
    exec sudo "$0" "$@"
    exit $?
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
  if [[ "$1" ]]; then
    do_or_exit "$2"
  fi
}

if_dir_empty_do () {
  if [[ -d $1 ]] && [[ ! "$(ls -A $1)" ]]; then
    do_or_exit "$2"
  fi
}


#
# SCRIPT
#

# Run this script with superuser privileges - BE CAREFUL!
# This is necessary for some of these actions
run_with_sudo "$@"

# Set the system name
do_or_exit "scutil --set ComputerName ${SYSTEM_NAME}"
do_or_exit "scutil --set LocalHostName ${SYSTEM_NAME}"
do_or_exit "scutil --set HostnameName ${SYSTEM_NAME}"

# Install Xcode Command Line Tools
if_cmd_do "! xcode-select --print-path" "xcode-select --install"

# Install Homebrew
require_cmd "xcode-select --print-path" "Xcode Command Line Tools installed"
if_cmd_do "! which brew" 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

# Install Git via Homebrew
require_cmd "which brew" "Homebrew installed"
do_or_exit "brew install git"

# Clone dotfiles repository if necessary and link dotfiles to $HOME
require_cmd "which git" "Git installed"
# if_path_do "! -d ${DOTFILE_DIR}" "mkdir -p ${DOTFILE_DIR}"
# require_path "-d ${DOTFILE_DIR}"
# if_dir_empty_do "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
if_path_do "! -d ${DOTFILE_DIR}" "git clone ${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"
for dotfile in "$DOTFILE_DIR/*"; do
  if_path_do "-f ${HOME_DIR}/.${dotfile}" "mv ${HOME_DIR}/.${dotfile} ${HOME_DIR}/.${dotfile}.old"
  do_or_exit "ln -s ${DOTFILE_DIR}/${dotfile} ${HOME_DIR}/.${dotfile}"
done

# Install applications via Homebrew
require_cmd "which brew" "Homebrew installed"
do_or_exit "brew update"
do_or_exit "brew doctor"
if_path_do "-x ${BREWFILE}" "source ${BREWFILE}"
do_or_exit "brew cleanup"

# Change login shell to (Homebrew installed) Z Shell
require_path "-h ${ZSH_PATH}" "Homebrewed Z Shell installed"
if_cmd_do "! grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | tee -a /etc/shells"
do_or_exit "chsh -s ${ZSH_PATH} ${USER}"
# do_or_exit "chsh -s /bin/zsh ${USER}"

# Download Solarized colorscheme
require_cmd "which git" "Git installed"
# if_path_do "! -d ${COLORSCHEMES_PATH}" "mkdir -p ${COLORSCHEMES_PATH}"
# require_path "-d ${COLORSCHEMES_PATH}"
# if_dir_empty_do "${COLORSCHEMES_PATH}" "git clone git://github.com/altercation/solarized.git ${COLORSCHEMES_PATH}"
if_path_do "! -d ${COLORSCHEMES_PATH}" "git clone https://github.com/altercation/solarized.git ${COLORSCHEMES_PATH}"
printf "Solarized color scheme files are in ${COLORSCHEMES_PATH}\n"

# Install Vundle and use it to install Vim plugins
require_cmd "which git" "Git installed"
require_cmd "which vim" "Vim installed"
if_path_do "! -d ${VUNDLE_PATH}" "git clone https://github.com/gmarik/Vundle.vim.git ${VUNDLE_PATH}"
do_or_exit "vim +PluginInstall +qall"

# Setup Vagrant
# require_cmd "which vagrant" "Vagrant installed"
# if_cmd_do "! vagrant plugin list | grep -q vagrant-vbguest" "vagrant plugin install vagrant-vbguest"
# do_or_exit "vagrant init minimal/jessie64"

# Reminder of where the iTerm2 preferences file is
printf "Reminder: set iTerm2 -> Preferences -> General to use ${DOTFILE_BIN_DIR}/iterm2.plist\n"

# Make $HOME/bin directory for symbolic links to Homebrew-installed executables
if_path_do "! -d ${HOME}/bin" "mkdir -p ${HOME}/bin"
printf "To use Homebrew-installed executables over defaults link them to ${HOME}/bin."

# Direct user to $README
printf "See ${README} for installation and configuration instructions.\n"

exit 0



# #
# # HOMEBREW
# #

# # Install Xcode command line developer tools (required for Homebrew)
# if ! xcode-select --print-path > /dev/null 2>&1; then
#   xcode-select --install && \
#     printf "+ Xcode Command Line Tools installed.\n" || \
#       { printf "- FAILED: Xcode command line tools not installed.\n"; \
#         exit 1; }
# fi

# # Install Homebrew
# if ! which brew > /dev/null 2>&1; then
#   ruby -e \
#   "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && \
#     printf "+ Homebrew installed.\n" || \
#     { printf "- FAILED: Homebrew not installed.\n" >&2; \
#       exit 1; }
# fi

# if which brew > /dev/null 2>&1; then
#   # Make certain that formulae are up-to-date
#   brew update && \
#     printf "+ Homebrew formulae updated.\n" || \
#       { printf "- FAILED: Homebrew formulae not updated.\n"; \
#         exit 1; }

#   # Make certain that homebrew is ready for brewing
#   # Right now brew doctor must be completely satisfied to continue
#   printf "Running 'brew doctor'...\n"
#   brew doctor && \
#     printf "+ Brew doctor satisfied.\n"|| \
#       { printf "- FAILED: Unresolved brew doctor warnings or errors.\n"; \
#         exit 1; }

#   # If the brewfile script exists and is executable, run it
 
#   [[ -x "${BREWFILE}" ]] && \
#     { printf "Running ${BREWFILE}...\n"; source "${BREWFILE}" } || \
#       { printf "- FAILED: A problem occured while running ${BREWFILE}.\n"; \
#         exit 1; }

#   # Remove out-dated versions and extra files from the cellar
#   printf "Running 'brew cleanup'...\n"
#   brew cleanup && \
#     printf "+ Brew cleanup succeeded.\n" || \
#       printf "- FAILED: Brew cleanup failed.\n"
# fi

# # Make certain that Git is installed
# if ! which git > /dev/null 2>&1; then
#   printf "No installation of Git was found.\n" >&2
#   printf "Install Git via Homebrew or Xcode command line tools.\n" >&2
#   exit 1
# fi


# #
# # VAGRANT
# #

# if which vagrant > /dev/null 2>&1; then
#   if ! vagrant plugin list | grep -q vagrant-vbgest; then
#     vagrant plugin install vagrant-vbguest || \
#       { printf "A problem occured while installing vagrant-vbguest.\n" >&2; \
#         exit 1; }
#   fi
#   # Initialize a mininalist Debian box
#   vagrant init minimal/jessie64 || \
#     printf "- FAILED: Vagrant box minimal/jessie64 not initialized.\n"
# fi



# #
# # SHELL
# #

# # Append Homebrewed Zsh path to /etc/shells to authorize it as a login shell
# # and then change this user's login shell to this Zsh
# if [[ -h "/usr/local/bin/zsh" ]]; then
#   if ! grep -q /usr/local/bin/zsh /etc/shells; then
#       echo "/usr/local/bin/zsh" | tee -a /etc/shells && \
#         chsh -s /usr/local/bin/zsh "${USER}" || \
#           { printf "A problem occurred while changing the login shell.\n" >&2; \
#             exit 1; }
#   fi
# elif [[ -x "/bin/zsh" ]]; then
#   chsh -s /bin/zsh "${USER}" && \
#     printf "Homebrewed Zsh not found, using /bin/zsh as login shell.\n" >&2 || \
#       { printf "A problem occured while changing the login shell.\n" >&2; \
#         exit 1; }
# else
#   printf "Zsh not found, leaving login shell unchanged.\n" >&2
# fi


# #
# # COLOR SCHEMES
# #

# # Install Solarized
# COLORSCHEMES_PATH="${HOME}/.colorschemes"
# if [[ ! -d "${COLORSCHEMES_PATH}" ]]; then
#   git clone git://github.com/altercation/solarized.git ${COLORSCHEMES_PATH} && \
#     printf "Solarized color scheme files are in ${COLORSCHEMES_PATH}\n" || \
#       { printf "A problem occured while cloning the Solarized repository.\n" >&2; \
#         exit 1; }
# fi


# #
# # VIM PLUGINS
# #

# # Install Vundle, then use it to install Vim plugins
# VUNDLE_PATH="${HOME}/.vim/bundle/Vundle.vim"
# if which vim > /dev/null 2>&1; then
#   if [[ ! -d "${VUNDLE_PATH}" ]]; then
#     git clone https://github.com/gmarik/Vundle.vim.git ${VUNDLE_PATH} && \
#       vim +PluginInstall +qall || \
#         { printf "A problem occured while setting up Vim plugins." >&2; \
#           exit 1; }
#   fi
# else
#   printf "No installation of Vim was found; Vim plugins not installed.\n" >&2
# fi


# #
# # DOTFILES
# #


# if [[ ! -d "${DOTDIR}" ]]; then
#   git clone git://github.com/"${DOTFILE_GIT_REPO}" "${DOTFILE_DIR}" || \
#     { printf "A problem occured while cloning the dotfiles repository." >&2; \
#       exit 1; }
# fi

# # Save any existing dotfiles and then sym-link from DOTFILE_DIR to HOME
# for dotfile in "$DOTFILE_DIR/*"; do
#   if [[ -f "${HOME}/.${dotfile}" ]]; then
#     mv "${HOME}/.${dotfile}" "${HOME}/.${dotfile}.old" || \
#       { printf "A problem occured while saving pre-existing dotfiles." >&2; \
#         exit 1; }
#   fi
#   if [[ -f "${DOTFILE_DIR}/${dotfile}" ]]; then
#     ln -s "${DOTFILE_DIR}/${dotfile}" "${HOME}/.${dotfile}" || \
#       { printf "A problem occured while linking dotfiles to ${HOME}." >&2; \
#         exit 1; }
#   fi
# done


# #
# # ITERM2
# #

# # Reminder of where the iTerm2 preferences file is
# printf "Reminder: set iTerm2 -> Preferences -> General to use ${DOTFILE_BIN_DIR}/iterm2.plist\n"


# #
# # HOMEBREW SYMBOLIC LINKS
# #

# # Make a user bin directory that occurs early in PATH
# if [[ ! -d "${HOME}/bin" ]]; then
#   mkdir ~/bin && \
#     echo "To use homebrewed executables over defaults link them to ${HOME}/bin."
# fi
# # Actual linking of executables to ~/bin should be done by hand


# printf "See ${README} for installation and configuration instructions.\n"


# exit 0
