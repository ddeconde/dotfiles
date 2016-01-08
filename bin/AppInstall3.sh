


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
