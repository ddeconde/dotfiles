#!/bin/env bash

EXCLUDE=${HOME}/.rsync/exclude
BACKUP_PATH="/Backups"
DTS=$(date "+%Y%m%d-%H%M%S")
HOSTNAME=$(hostname)
SOURCE="${HOME}"
PREVIOUS_BACKUP="${BACKUP_PATH}/current-${HOSTNAME}-${SOURCE}-backup"
TARGET="${BACKUP_PATH}/${DTS}-${HOSTNAME}-${SOURCE}-backup"
TARGET_HOST="localhost"
TARGET_USER="${USER}"

rsync -axzP \
  --delete \
  --delete-excluded \
  --exclude-from=${EXCLUDE} \
  --link-dest=${PREVIOUS_BACKUP} \
  ${SOURCE} "${TARGET_USER}@${TARGET_HOST}:${TARGET}-partial" \
  && ssh "${TARGET_USER}@${TARGET_HOST}" \
  "mv ${TARGET}-partial ${TARGET} \
  && rm -f ${PREVIOUS_BACKUP} \
  && ln -s ${TARGET} ${PREVIOUS_BACKUP}"
