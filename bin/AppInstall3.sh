

install_apps () {
  # This function is a wrapper for multiple calls to the 'get_app' function,
  # one for each GUI application to be installed. Each call to 'get_app'
  # requires the following arguments:
  # 1) download URL
  # 2) application name (the filename of the .app directory, excluding ".app")
  # 3) filetype of the downloaded application (i.e. "zip", "dmg", "pkg", "tar")

  get_app "https://iterm2.com/downloads/stable/iTerm2-2_1_4.zip" "iTerm" "zip"
  get_app "https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.0.1.zip" "Spectacle" "zip"
  get_app "https://github.com/macvim-dev/macvim/releases/download/snapshot-94/MacVim.dmg" "MacVim" "dmg"
  get_app "http://unarchiver.c3.cx/downloads/TheUnarchiver3.10.1.dmg" "The Unarchiver" "dmg"
  get_app "https://d13itkw33a7sus.cloudfront.net/dist/1P/mac4/1Password-6.0.1.zip" "1Password 6" "zip"
  get_app "https://www.obdev.at/downloads/littlesnitch/LittleSnitch-3.6.1.dmg" "Little Snitch Installer" "dmg"
  get_app "https://www.obdev.at/downloads/MicroSnitch/MicroSnitch-1.2.zip" "Micro Snitch" "zip"
  get_app "https://www.obdev.at/downloads/launchbar/LaunchBar-6.5.dmg" "LaunchBar" "dmg"
  get_app "http://download.transmissionbt.com/files/Transmission-2.84.dmg" "Transmission" "dmg"
  get_app "http://downloads.sourceforge.net/project/adium/Adium_1.5.10.dmg" "Adium" "dmg"
  get_app "https://www.torproject.org/dist/torbrowser/5.0.7/TorBrowser-5.0.7-osx64_en-US.dmg" "TorBrowser" "dmg"
  get_app "http://get.videolan.org/vlc/2.2.1/macosx/vlc-2.2.1.dmg" "VLC" "dmg"
  get_app "https://update.cyberduck.io/Cyberduck-4.7.3.zip" "Cyberduck" "zip"
  get_app "http://london.kapeli.com/Dash.zip" "Dash" "zip"
  get_app "https://www.vmware.com/go/try-fusion-en" "VMware Fusion" "dmg"
  get_app "http://tug.org/cgi-bin/mactex-download/MacTeX.pkg" "MacTeX" "pkg"
  get_app "http://bombich.com/software/download_ccc.php?v=latest" "Carbon Copy Cloner" "zip"
  get_app "http://www.sparklabs.com/downloads/Viscosity.dmg" "Viscosity" "dmg"
  get_app "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US" "Firefox" "dmg"

  # Uncomment the line below to automatically remove the downloaded
  # applications after installation.
  # clean_up_apps
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

download_app () {
  local APP_URL=$1
  local APP_NAME=$2
  local FILE_TYPE=$3
  local APP_PATH="${TMP_DIR}/${APP_NAME}.${FILE_TYPE}"
  if_not_exists "dir" "${TMP_DIR}" "mkdir -p ${TMP_DIR}"
  curl -s -L -o ${APP_PATH} ${APP_URL}
}

install_app () {
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

get_app () {
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
