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

# Set VERBOSE variable to activate stdout messages; value does not matter
readonly VERBOSE="Yes"
# The paths of the dotfiles directories
readonly DOTFILE_DIR="${HOME}/dotfiles"
readonly DOTFILE_BIN_DIR="${DOTFILE_DIR}/bin"
readonly DOTFILE_ETC_DIR="${DOTFILE_DIR}/etc"
readonly DOTFILE_GIT_REPO="ddeconde/dotfiles.git"
# The paths to installation and configuration related assets
readonly README="${DOTFILE_ETC_DIR}/README.md"
readonly PRIVATE_DIR="${HOME}/private"
readonly COLORS_PATH="${HOME_DIR}/etc/solarized"
# Directories for GUI application installation
readonly APP_DIR="/Applications"
readonly TMP_DIR="~${ADMIN_USER}/applications"
# The path of the Homebrewed version of zsh
readonly ZSH_PATH="/usr/local/bin/zsh"
# The hostname is given by the required first argument to this script
readonly SYSTEM_NAME="${1}"
# The default name for the required administrative user account
readonly ADMIN_USER="admin"
readonly HOMEBREW_INSTALL_RUBY_CMD="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Packages to be installed via Homebrew
readonly packages=(
  git
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

readonly backup_dirs=(
  dotfiles
  private
  etc
  Documents
  Projects
)

# Homebrew packages to link to HOME/bin for PATH priority over defaults
readonly HOME_BIN_LINKS=(
  git
  vim
  zsh
  bash
  curl
)

# Definition of the GUI application installation function
install_apps () {
  # This function is a wrapper for multiple calls to the 'get_app' function,
  # one for each GUI application to be installed. Each call to 'get_app'
  # requires the following arguments:
  # 1) download URL
  # 2) application name (the filename of the .app directory, excluding ".app")
  # 3) filetype of the downloaded application (i.e. "zip", "dmg", "pkg", "tar")

  # Arguments to "get_app", particuarly URLs, must be kept up-to-date
  get_app "iTerm" "zip" "https://iterm2.com/downloads/stable/iTerm2-2_1_4.zip"
  get_app "Spectacle" "zip" "https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.0.1.zip"
  get_app "MacVim" "dmg" "https://github.com/macvim-dev/macvim/releases/download/snapshot-94/MacVim.dmg"
  get_app "The Unarchiver" "dmg" "http://unarchiver.c3.cx/downloads/TheUnarchiver3.10.1.dmg"
  get_app "1Password 6" "zip" "https://d13itkw33a7sus.cloudfront.net/dist/1P/mac4/1Password-6.0.1.zip"
  get_app "Little Snitch Installer" "dmg" "https://www.obdev.at/downloads/littlesnitch/LittleSnitch-3.6.1.dmg"
  get_app "Micro Snitch" "zip" "https://www.obdev.at/downloads/MicroSnitch/MicroSnitch-1.2.zip"
  get_app "LaunchBar" "dmg" "https://www.obdev.at/downloads/launchbar/LaunchBar-6.5.dmg"
  get_app "Transmission" "dmg" "http://download.transmissionbt.com/files/Transmission-2.84.dmg"
  get_app "Adium" "dmg" "http://downloads.sourceforge.net/project/adium/Adium_1.5.10.dmg"
  get_app "TorBrowser" "dmg" "https://www.torproject.org/dist/torbrowser/5.0.7/TorBrowser-5.0.7-osx64_en-US.dmg"
  get_app "VLC" "dmg" "http://get.videolan.org/vlc/2.2.1/macosx/vlc-2.2.1.dmg"
  get_app "Dash" "zip" "http://london.kapeli.com/Dash.zip"
  get_app "VMware Fusion" "dmg" "https://www.vmware.com/go/try-fusion-en"
  get_app "MacTeX" "pkg" "http://tug.org/cgi-bin/mactex-download/MacTeX.pkg"
  get_app "Carbon Copy Cloner" "zip" "http://bombich.com/software/download_ccc.php?v=latest"
  get_app "Viscosity" "dmg" "http://www.sparklabs.com/downloads/Viscosity.dmg"
  get_app "Firefox" "dmg" "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
  get_app "Chromium" "dmg" "https://sourceforge.net/projects/osxportableapps/files/latest/download?source=files"

  # Uncomment the line below to automatically remove the downloaded
  # applications after installation.
  # clean_up_apps
}


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

  # Require that an administrative user account has already been created
  require_success "id -Gn ${ADMIN_USER} | grep -q -w admin" "administrative user account: ${ADMIN_USER} not found"

  # Set the system name
  echo_if_verbose "setting hostname to $0"
  do_or_exit "sudo scutil --set ComputerName ${SYSTEM_NAME}"
  do_or_exit "sudo scutil --set LocalHostName ${SYSTEM_NAME}"
  do_or_exit "sudo scutil --set HostName ${SYSTEM_NAME}"

  # Install Xcode Command Line Tools
  echo_if_verbose "installing Xcode Command Line Tools"
  if_not_success "xcode-select --print-path" "xcode-select --install"
  require_success "xcode-select --print-path" "Xcode Command Line Tools not found"

  # Install Homebrew
  echo_if_verbose "installing homebrew"
  if_not_success "which brew" "sudo -u ${ADMIN_USER} /usr/bin/ruby -e ${HOMEBREW_INSTALL_RUBY_CMD}"
  require_success "which brew" "homebrew not found"

  # Install command line packages via Homebrew
  do_or_exit "brew update"
  do_or_exit "brew doctor"
  for package in "${packages[@]}"; do
    echo_if_verbose "installing ${package} via homebrew"
    sudo -u ${ADMIN_USER} brew install ${package}
  done
  do_or_exit "brew cleanup"

  # Install GUI applications
  install_apps

  # Copy backup data into place if available
  for dir in "${backup_dirs[@]}"; do
    if_exists "dir" "${BACKUP_VOL}/${dir}" "cp -R ${BACKUP_VOL}/${dir} ${HOME}/${dir}"
  done

  # Clone dotfiles repository if necessary
  require_success "which git" "git not found"
  if_not_exists "dir" "${DOTFILE_DIR}" "git clone git://github.com/${DOTFILE_GIT_REPO} ${DOTFILE_DIR}"

  # Download Solarized colorscheme if necessary
  if_not_exists "dir" "${COLORS_PATH}" "git clone https://github.com/altercation/solarized.git ${COLORS_PATH}"

  # Link dotfiles to home directory
  require "dir" "${DOTFILE_DIR}" "${DOTFILE_DIR} not found"
  link_files "${DOTFILE_DIR}" "${HOME_DIR}" "."

  # Link private files like credentials and local conf files
  if_exists "dir" "${PRIVATE_DIR}" "link_dir_files ${PRIVATE_DIR} ${HOME} '.'"

  # Change login shell to (Homebrew installed) Z Shell
  require "exec" "${ZSH_PATH}" "homebrewed Z Shell not found"
  if_not_success "grep -q ${ZSH_PATH} /etc/shells" "echo ${ZSH_PATH} | sudo tee -a /etc/shells"
  do_or_exit "sudo chsh -s ${ZSH_PATH} ${USER}"

  # Make $HOME/bin directory for symbolic links to Homebrew-installed executables
  if_not_exists "dir" "${HOME}/bin" "mkdir -p ${HOME}/bin"
  # Symlink Homebrew-installed executables to $HOME/bin
  for bin in "${HOME_BIN_LINKS[@]}"; do
    if_exists "any" "/usr/local/bin/${bin}" "ln -s /usr/local/bin ${HOME}/bin/${bin}"
  done

  # Reminder of where the iTerm2 preferences file is
  echo_if_verbose "iTerm2 preferences are at: ${DOTFILE_ETC_DIR}\n"

  # Direct user to README
  echo_if_verbose "see ${README} for installation and configuration instructions.\n"

  # Direct user to create administrative user
  echo_if_verbose "create a separate admin account and"
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

echo_if_verbose () {
  # if the VERBOSE variable is set then print argument to stdout
  if [[ -z ${VERBOSE+x} ]]; then
    printf "$0: $@\n"
  fi
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

is_installed () {
  # return success if first argument is the name of an application already
  # installed in the "/Applications" directory
  if [[ -d "${APP_DIR}/${1}.app" ]]; then
    return 0
  fi
  return 1
}

is_not_installed () {
  # return success if first argument is not the name of an application already
  # installed in the "/Applications" directory
  if [[ ! -d "${APP_DIR}/${1}" ]]; then
    return 0
  fi
  return 1
}

download_app () {
  # download application from URL listed as first argument, with download
  # filetype of third argument (i.e. "dmg", "zip", "pkg", "tar") and filename
  # according to the second argument--this name must be the correct name of the
  # ".app" file contained within the download
  local APP_URL=$1
  local APP_NAME=$2
  local FILE_TYPE=$3
  local APP_PATH="${TMP_DIR}/${APP_NAME}.${FILE_TYPE}"
  if_not_exists "dir" "${TMP_DIR}" "sudo -u ${ADMIN_USER} mkdir -p ${TMP_DIR}"
  sudo -u ${ADMIN_USER} curl -sLo ${APP_PATH} ${APP_URL}
}

install_app () {
  # install application with name according to the first argument and
  # downloaded install filetype of the second argument (i.e. "dmg", "zip",
  # "pkg", "tar")--if this application is already installed to the
  # "/Applications" directory then this function does nothing
  local APP_NAME=$1
  local FILE_TYPE=$2
  local APP_PATH="${TMP_DIR}/${APP_NAME}.${FILE_TYPE}"
  local MOUNT_PT="/Volumes/${APP_NAME}"

  # Skip over already installed applications; no updating
  if is_installed ${APP_NAME}; then
    return 0
  fi

  # Install according to type
  case ${FILE_TYPE} in
    "dmg")
      # yes handles required interactive agreements
      sudo -u ${ADMIN_USER} yes | hdiutil attach ${APP_PATH} -nobrowse -mountpoint ${MOUNT_PT} > /dev/null 2>&1
      sudo -u ${ADMIN_USER} cp -R "${MOUNT_PT}/${APP_NAME}.app" "${APP_DIR}"
      sudo -u ${ADMIN_USER} hdiutil detach ${MOUNT_PT} > /dev/null 2>&1
    ;;
    "zip")
      sudo -u ${ADMIN_USER} unzip -qq ${APP_PATH}
      mv "${APP_NAME}.app" "${APP_DIR}"
    ;;
    "pkg")
      sudo -u ${ADMIN_USER} installer -pkg ${APP_PATH} -target /
    ;;
    "tar")
      sudo -u ${ADMIN_USER} tar -zxf ${APP_PATH} > /dev/null 2>&1
      mv "${APP_NAME}.app" "${APP_DIR}"
    ;;
  esac
}

get_app () {
  # download and install application with name according to the second
  # argument, download URL according to the first argument, and download
  # filetype according to the third argument
  local APP_URL=$3
  local APP_NAME=$1
  local FILE_TYPE=$2
  local APP_PATH="${TMP_DIR}/${APP_NAME}.${FILE_TYPE}"

  # Skip over already installed applications; no updating
  if is_installed ${APP_NAME}; then
    return 0
  fi


  if [[ -z ${VERBOSE+x} ]]; then
    printf "$0: downloading and installing ${4}.\n"
  fi
  download_app ${APP_URL} ${APP_NAME} ${FILE_TYPE}
  install_app ${APP_NAME} ${FILE_TYPE}
}

clean_up_apps () {
  # delete downloaded application files and remove temporary directory
  sudo -u ${ADMIN_USER} rm -rf ${TMP_DIR}
  sudo -u ${ADMIN_USER} rmdir ${TMP_DIR}
}


#
# RUN MAIN()
#

main "$@"
exit 0
