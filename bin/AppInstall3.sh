

main () {
  # is_newer_version $1 $2
  # echo $?
  if is_outdated $1 $2; then
    echo "outdated"
  fi
}

get_app () {
  curl -s -L -o ${APP_PATH} ${APP_URL}
  if is_not_installed ${APP_NAME}; then
    install_app "${APP_PATH}" "${TYPE}"
  elif is_outdated "${APP_NAME}"; then
    install_app "${APP_PATH}" "${TYPE}"
  fi
}

install_app () {
  if [[ $2 == "dmg" ]]; then
    hdiutil attach ${APP_PATH} -nobrowse -mountpoint ${MOUNT_PT}
    cp -R "${APP_PATH}/${APP_NAME}" "${APP_DIR}"
    hdiutil detach ${MOUNT_PT}
    rm -rf ${APP_PATH}
  elif [[ $2 == "zip" ]]; then
    unzip -qq ${APP_PATH}
    mv "${APP_NAME}.app" "${APP_DIR}"
    rm -rf ${APP_PATH}
  elif [[ $2 == "tar" ]]; then
    tar -zxf ${APP_PATH}
    mv "" "${APP_DIR}"
    rm -rf ${APP_PATH}
  fi
}

APP_DIR="/Applications"


_compare_version_component() {
  # Compare a single component of two version numbers
  (( $1 == $2 )) && return 0
  (( $1 > $2 )) && return 1
  (( $1 < $2 )) && return 2
  # If somehow the above exhaustive cases are passed, exit with error
  exit 1
}

is_newer_version() {
  # Determine whether first or second argument is a newer version number
  # and return 1 if the first is newer, 2 if the second, and 0 if equal.
  local A B i result
  A=(${1//./ })
  B=(${2//./ })
  i=0
  while (( i < ${#A[@]} )) && (( i < ${#B[@]})); do
      _compare_version_component "${A[i]}" "${B[i]}"
    result=$?
    [[ $result =~ [12] ]] && return $result
    let i++
  done
  # More version components means newer version when otherwise equal
  _compare_version_component "${#A[i]}" "${#B[i]}"
  return $?
}

is_outdated () {
  local VERSION_ATTR="CFBundleShortVersionString"
  local INFO_PATH="${APP_NAME}.app/Contents/Info"
  local current_version=$( defaults read "${APP_DIR}/${INFO_PATH}" "${VERSION_ATTR}" )
  local new_version=$( defaults read "${APP_PATH}/${INFO_PATH}" "${VERSION_ATTR}" )
  is_newer_version ${current_version} ${new_version}
  if (( $? > 1 )); then
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

main $@
exit 0
