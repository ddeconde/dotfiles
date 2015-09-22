#!/bin/env bash

EXCLUDE=${HOME}/.rsync_exclude
BACKUP_PATH="/Backups"
DTS=$(date "+%Y%m%d-%H%M%S")
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
  ${SOURCE} "${TARGET_USER}@${TARGET_HOST}:${TARGET}-partial" \
  && ssh "${TARGET_USER}@${TARGET_HOST}" \
  "mv ${TARGET}-partial ${TARGET} \
  && rm -f ${PREVIOUS_BACKUP} \
  && ln -s ${TARGET} ${PREVIOUS_BACKUP}"


if_path_do () {
  # if first argument yields successful test then do second
  if [[ "$1" ]]; then
    do_or_exit "$2"
  fi
}

# make certain target drive is mounted
if_path_do "! -e ${TARGET}" ""

# verify that source is readable
if_path_do "! -r ${SOURCE}" ""

# verify that target is writable
if_path_do "! -w ${TARGET}" ""
