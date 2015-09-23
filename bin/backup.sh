#!/bin/env bash

EXCLUDE=${HOME}/.rsync_exclude
BACKUP_PATH="/Backups"
DTS=$(date -u "+%Y%m%d-%H%M%S")
DATE_TIME=$(date "+%FT%T%z")
HOSTNAME=$(hostname)
SOURCE="${HOME}"
PREVIOUS_BACKUP="${BACKUP_PATH}/current-${HOSTNAME}-${SOURCE}-backup"
TARGET="${BACKUP_PATH}/${DTS}-${HOSTNAME}-${SOURCE}-backup"
TARGET_HOST="localhost"
TARGET_USER="${USER}"

rsync -ahvxPE \
  --progress \
  --delete \
  --delete-excluded \
  --exclude-from=${EXCLUDE} \
  --link-dest=${PREVIOUS_BACKUP} \
  ${SOURCE} "${TARGET}-partial" \
  && ssh "${TARGET_USER}@${TARGET_HOST}" \
  "mv ${TARGET}-partial ${TARGET} \
  && rm -f ${PREVIOUS_BACKUP} \
  && ln -s ${TARGET} ${PREVIOUS_BACKUP}"


echo_error () {
  # conveniently print errors to stderr
  printf "ERROR: $@\n" >&2
}

do_or_exit () {
  # execute first argument command with success or exit
  $@
  retval=$?
  if (( $retval != 0 )); then
    backup_log "ERROR: [ $@ ] failed - no backup made"
    echo_error "[ $@ ] failed - no backup made"
    exit $retval
  fi
}

require_path () {
  # exit if first argument path does not exist as correct type
  if [[ ! "$1" ]]; then
    if (( $# > 1 )); then
      backup_log "ERROR: requirement [ $@ ] unfullfilled - no backup made"
      echo_error "requirement [ $2 ] unfullfilled"
    fi
    exit 1
  fi
}

if_path_do () {
  # if first argument yields successful test then do second
  if [[ "$1" ]]; then
    do_or_exit "$2"
  fi
}

backup_log () {
  # write to a logfile
  if_path_do "! -d $(dirname ${LOG_PATH})" "mkdir -p $(dirname ${LOG_PATH})"
  cat "${DATE_TIME} ${HOSTNAME} ${1}" >> "${LOG_PATH}"
}

# make certain target drive is mounted
require_path "! -e ${TARGET}" "backup drive mounted"

# verify that source is readable
require_path "! -r ${SOURCE}" "source directory readable"

# verify that target is writable
require_path_ "! -w ${TARGET}" "target directory writable"
