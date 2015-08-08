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
PKGFILE="${DOTFILE_BIN_DIR}/packages.sh"


# Make certain that sudo is used to run this script
if [[ $(id -u) != 0 ]]; then
  printf "This command must be run with superuser privileges:\n" >&2
  printf "$ sudo install\n" >&2
  exit 1
fi


#
# APT-GET
#


# Make certain that formulae are up-to-date
apt-get update || \
  { printf "A problem occurred while updating package indices.\n" >&2; \
    exit 1; }

apt-get upgrade || \
  { printf "A problem occurred while upgrading packages.\n" >&2; \
    exit 1; }

# If the pkgfile script exists and is executable, run it
[[ -x "${PKGFILE}" ]] && . "${PKGFILE}" || \
  { printf "A problem occurred while running apt-get.\n" >&2; \
    exit 1; }

apt-get clean || \
  { printf "A problem occurred while cleaning up local .deb files.\n" >&2; \
    exit 1; }

# Make certain that Git is installed
if [[ ! $(which git) ]]; then
  printf "No installation of Git was found.\n" >&2
  printf "Install Git via apt-get.\n" >&2
  exit 1
fi

# Make certain that Curl is installed
if [[ ! $(which curl) ]]; then
  printf "No installation of Curl was found.\n" >&2
  printf "Install Curl via apt-get.\n" >&2
  exit 1
fi


#
# SHELL
#

# Change this user's login shell to Zsh
if [[ -h "/usr/bin/zsh" ]]; then
  chsh -s /usr/bin/zsh "${USER}" || \
    { printf "A problem occurred while changing the login shell.\n" >&2; \
      exit 1; }
elif [[ -x "/bin/zsh" ]]; then
  chsh -s /bin/zsh "${USER}" && \
    printf "/usr/bin/zsh not found, using /bin/zsh as login shell.\n" >&2 || \
      { printf "A problem occured while changing the login shell.\n" >&2; \
        exit 1; }
else
  printf "Zsh not found, leaving login shell unchanged.\n" >&2
fi

# Install zsh-history-substring-search
ZSH_USERS_REPO="https://raw.githubusercontent.com/zsh-users/"
MASTER_BRANCH="zsh-history-substring-search/master/"
ZSH_FILE="zsh-history-substring-search.zsh"
ZSH_HISTORY_SUBSTRING_SEARCH_URL="${ZSH_USERS_REPO}${MASTER_BRANCH}${ZSH_FILE}"

ZSH_HISTORY_SUBSTRING_SEARCH_PATH="/usr/local/zsh-history-substring-search/"

curl -fsSL \
  --create-dirs \
  --output "${ZSH_HISTORY_SUBSTRING_SEARCH_PATH}${ZSH_FILE}" \
  "${ZSH_HISTORY_SUBSTRING_SEARCH_URL}" || \
    { printf "A problem occurred while installing zsh-history-substring-search.\n" >&2; \
    exit 1; }


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


exit 0
