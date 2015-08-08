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
# CONSTANTS
#

# The paths of the dotfiles directories
DOTFILE_DIR="${HOME}/.dotfiles"
DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The name (path) of the brewfile script
BREWFILE="${DOTFILE_BIN_DIR}/brew.sh"


# Make certain that sudo is used to run this script
if [[ $(id -u) != 0 ]]; then
  printf "This command must be run with superuser privileges:\n" >&2
  printf "$ sudo install\n" >&2
  exit 1
fi


#
# HOMEBREW
#

# Install Xcode command line developer tools (required for Homebrew)
if [[ ! $(xcode-select --print-path) ]]; then
  xcode-select --install || \
    { printf "Xcode command line developer tools installation failed\n." >&2; \
      exit 1; }
fi


# Install Homebrew
if [[ ! $(which brew) ]]; then
  ruby -e \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || \
    { printf "No installation of Homebrew found; installation failed.\n" >&2; \
      exit 1; }
fi


# Make certain that formulae are up-to-date
brew update || \
  { printf "A problem occurred while updating Homebrew formulae.\n" >&2; \
    exit 1; }


# Make certain that homebrew is ready for brewing
# Right now brew doctor must be completely satisfied to continue
brew doctor || \
  { printf "Brew doctor \n";
    printf "Resolve Homebrew warnings and errors before running again.\n";
    exit 1; }


# If the brewfile script exists and is executable, run it
[[ -x "${BREWFILE}" ]] && . "${BREWFILE}" || \
  { printf "A problem occurred while running brew.\n" >&2; \
    exit 1; }

# Remove out-dated versions and extra files from the cellar
brew cleanup || \
  { printf "A problem occured while running brew cleanup.\n" >&2; \
    exit 1; }

# Make certain that Git is installed
if [[ ! $(which git) ]]; then
  printf "No installation of Git was found.\n" >&2
  printf "Install Git via Homebrew or Xcode command line tools.\n" >&2
  exit 1
fi


#
# SHELL
#

# Append Homebrewed Zsh path to /etc/shells to authorize it as a login shell
# and then change this user's login shell to this Zsh
if [[ -h "/usr/local/bin/zsh" ]]; then
  if [[ -z $(grep /usr/local/bin/zsh /etc/shells) ]]; then
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
if [[ ! -d "${HOME}/.colorscheme" ]]; then
  git clone git://github.com/altercation/solarized.git ~/.colorscheme && \
    printf "Solarized color scheme files are in ${HOME}/.colorscheme\n" || \
      { printf "A problem occured while cloning the Solarized repository." >&2; \
        exit 1; }
if


#
# VIM PLUGINS
#

# Install Vundle, then use it to install Vim plugins
if [[ $(which vim) ]]; then
  if [[ ! -d "${HOME}/.vim/bundle/Vundle.vim" ]]; then
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim && \
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
printf "Reminder: set iTerm2 -> Preferences -> General to use
${DOTFILE_DIR}/install/iterm2.plist\n"


#
# HOMEBREW SYMBOLIC LINKS
#

# Make a user bin directory that occurs early in PATH
if [[ ! -d "~/bin" ]]; then
  mkdir ~/bin && \
    echo "To use specific homebrewed executables over defaults link them to ~/bin."
fi
# Actual linking of executables to ~/bin should be done by hand


exit 0
