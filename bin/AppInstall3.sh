

main () {

  install_app "https://iterm2.com/downloads/stable/iTerm2-2_1_4.zip" "iTerm" "zip"
  install_app "https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.0.1.zip" "Spectacle" "zip"
  install_app "https://github.com/macvim-dev/macvim/releases/download/snapshot-94/MacVim.dmg" "MacVim" "dmg"
  install_app "http://unarchiver.c3.cx/downloads/TheUnarchiver3.10.1.dmg" "The Unarchiver" "dmg"
  install_app "https://d13itkw33a7sus.cloudfront.net/dist/1P/mac4/1Password-6.0.1.zip" "1Password 6" "zip"
  install_app "https://www.obdev.at/downloads/littlesnitch/LittleSnitch-3.6.1.dmg" "Little Snitch Installer" "dmg"
  install_app "https://www.obdev.at/downloads/MicroSnitch/MicroSnitch-1.2.zip" "Micro Snitch" "zip"
  install_app "https://www.obdev.at/downloads/launchbar/LaunchBar-6.5.dmg" "LaunchBar" "dmg"
  install_app "http://download.transmissionbt.com/files/Transmission-2.84.dmg" "Transmission" "dmg"
  install_app "http://downloads.sourceforge.net/project/adium/Adium_1.5.10.dmg" "Adium" "dmg"
  install_app "https://www.torproject.org/dist/torbrowser/5.0.7/TorBrowser-5.0.7-osx64_en-US.dmg" "TorBrowser" "dmg"
  install_app "http://get.videolan.org/vlc/2.2.1/macosx/vlc-2.2.1.dmg" "VLC" "dmg"
  install_app "https://update.cyberduck.io/Cyberduck-4.7.3.zip" "Cyberduck" "zip"
  install_app "http://london.kapeli.com/Dash.zip" "Dash" "zip"
  install_app "https://www.vmware.com/go/try-fusion-en" "VMware Fusion" "dmg"
  install_app "http://tug.org/cgi-bin/mactex-download/MacTeX.pkg" "MacTeX" "pkg"
  install_app "http://bombich.com/software/download_ccc.php?v=latest" "Carbon Copy Cloner" "zip"
  install_app "http://www.sparklabs.com/downloads/Viscosity.dmg" "Viscosity" "dmg"
  install_app "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US" "Firefox" "dmg"
}

readonly APP_DIR="/Applications"
readonly TMP_DIR="~/applications"


is_installed () {
  if [[ -d "${APP_DIR}/${1}.app" ]]; then
    return 0
  fi
  return 1
}

is_not_installed () {
  if [[ ! -d "${APP_DIR}/$1" ]]; then
    return 0
  fi
  return 1
}

get_application () {
  local APP_URL=$1
  local APP_NAME=$2
  local FILE_TYPE=$3
  local APP_PATH="${TMP_DIR}/${APP_NAME}.${FILE_TYPE}"
  if_not_exists "dir" "${TMP_DIR}" "mkdir -p ${TMP_DIR}"
  curl -s -L -o ${APP_PATH} ${APP_URL}
}

install_application () {
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
      yes | hdiutil attach ${APP_PATH} -nobrowse -mountpoint ${MOUNT_PT} > /dev/null 2>&1
      cp -R "${MOUNT_PT}/${APP_NAME}.app" "${APP_DIR}"
      hdiutil detach ${MOUNT_PT} > /dev/null 2>&1
    ;;
    "zip")
      unzip -qq ${APP_PATH}
      mv "${APP_NAME}.app" "${APP_DIR}"
    ;;
    "tar")
      tar -zxf ${APP_PATH}
      mv "${APP_NAME}.app" "${APP_DIR}"
    ;;
    "pkg")
      sudo installer -pkg ${APP_PATH} -target /
    ;;
  esac
}

install_app () {
  local APP_URL=$1
  local APP_NAME=$2
  local FILE_TYPE=$3
  local APP_PATH="${TMP_DIR}/${APP_NAME}.${FILE_TYPE}"

  get_application ${APP_URL} ${APP_NAME} ${FILE_TYPE}
  install_application ${APP_NAME} ${FILE_TYPE}
}

clean_up_apps () {
  rm -rf ${TMP_DIR}
}

main $@
exit 0
