


getApp () {
  curl -s -L -o ${APP_PATH} ${APP_URL}
}

installApp () {
  curl -s -L -o ${APP_PATH} ${APP_URL}
  if [[  ]]; then
    hdiutil attach ${APP_PATH} -nobrowse -mountpoint ${MOUNT_PT}
    cp -R "${APP_PATH}/${APP_NAME}" "${APPLICATIONS_DIR}"
    hdiutil detach ${MOUNT_PT}
    rm -rf ${APP_PATH}
  elif [[  ]]; then
    unzip -qq ${APP_PATH}
    mv "${APP_NAME}.app" "${APPLICATIONS_DIR}"
  elif [[  ]]; then
    tar -zxf ${APP_PATH}
    mv "" "${APPLICATIONS_DIR}"
  fi
}

APPLICATIONS_DIR="/Applications"

if_outdated () {
  local VERSION_ATTR="CFBundleShortVersionString"
  local INFO_PATH="${APPLICATIONS_DIR}/${APP_NAME}.app/Contents/Info"
  local version=$( defaults read "${INFO_PATH}" "${VERSION_ATTR}" )
  
}

# Compare with one element of version components
_ver_cmp_1() {
  (( $1 == $2 )) && return 0
  (( $1 > $2 )) && return 1
  (( $1 < $2 )) && return 2
  # This should not be happening
  exit 1
}

ver_cmp() {
  local A B i result
  A=(${1//./ })
  B=(${2//./ })
  i=0
  while (( i < ${#A[@]} )) && (( i < ${#B[@]})); do
    _ver_cmp_1 "${A[i]}" "${B[i]}"
    result=$?
    [[ $result =~ [12] ]] && return $result
    let i++
  done
  # Which has more, then it is the newer version
  _ver_cmp_1 "${#A[i]}" "${#B[i]}"
  return $?
}
