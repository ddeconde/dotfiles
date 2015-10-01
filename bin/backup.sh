#!/bin/env bash


#
# Constants
#

readonly BACKUP_DIR="${HOME}/.backup"
readonly EXCLUDE="${BACKUP_DIR}/.rsync.exclude"
readonly BACKUP_DRIVE="Backup"
readonly BACKUP_PATH="/Volumes/${BACKUP_DRIVE}/${HOSTNAME}"
readonly DTS=$(date -u "+%Y%m%d-%H%M%S")
readonly DATE_TIME=$(date "+%FT%T%z")
readonly HOSTNAME=$(hostname -s)
readonly SOURCE="${HOME}"
readonly SOURCE_NAME="$(basename ${HOME})"
readonly PREVIOUS="${BACKUP_PATH}/${SOURCE_NAME}-current"
readonly TARGET="${BACKUP_PATH}/${DTS}-${SOURCE_NAME}"
readonly TARGET_HOST="localhost"
readonly TARGET_USER="${USER}"
readonly RSYNC_PATH="/usr/local/bin/rsync"
readonly LOG_PATH="${BACKUP_DIR}/log"
readonly MAX_LOG_LENGTH=1000
readonly TRUNC_LOG_LENGTH=10


#
# Functions
#

echo_error () {
  # conveniently print errors to stderr
  printf "$0: $@\n" >&2
}

do_or_exit () {
  # execute first argument command with success or exit
  # optional second argument gives error message
  # commands typically provide their own error messages, tests do not
  $@
  retval=$?
  if (( $retval != 0 )); then
    if (( $# > 1 )); then
      backup_log "ERROR: $2 - no backup made"
      echo_error "$2"
    fi
    exit $retval
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
          backup_log "ERROR: $3 - no backup made"
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "dir")
      if [[ ! -d "$2" ]]; then
        if (( $# > 2 )); then
          backup_log "ERROR: $3 - no backup made"
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "link")
      if [[ ! -h "$2" ]]; then
        if (( $# > 2 )); then
          backup_log "ERROR: $3 - no backup made"
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "read")
      if [[ ! -r "$2" ]]; then
        if (( $# > 2 )); then
          backup_log "ERROR: $3 - no backup made"
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "write")
      if [[ ! -w "$2" ]]; then
        if (( $# > 2 )); then
          backup_log "ERROR: $3 - no backup made"
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    "exec")
      if [[ ! -x "$2" ]]; then
        if (( $# > 2 )); then
          backup_log "ERROR: $3 - no backup made"
          echo_error "$3"
        fi
        exit 1
      fi
    ;;
    *)
      if [[ ! -e "$2" ]]; then
        if (( $# > 2 )); then
          backup_log "ERROR: $3 - no backup made"
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
    "read")
      if [[ -r "$2" ]]; then
        do_or_exit "$3"
      fi
    ;;
    "write")
      if [[ -w "$2" ]]; then
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

backup_log () {
  # write to a logfile if it exists; stay quiet if no log file exists
  local log_line="${DATE_TIME} ${HOSTNAME} ${1}"
  if_exists "write" "${LOG_PATH}" "echo ${log_line} >> ${LOG_PATH}"
}

trim_backup_log () {
  # truncate the backup log file so it never gets too long
  if [[ $(wc -l < ${LOG_PATH}) -gt ${MAX_LOG_LENGTH} ]]; then
    tail -n ${TRUNC_LOG_LENGTH} ${LOG_PATH} > ${LOG_PATH}.tmp && \
      cat ${LOG_PATH}.tmp > ${LOG_PATH} && \
        rm ${LOG_PATH}.tmp || \
          { echo_error "log file truncation of ${LOG_PATH} failed"; exit 1; }
  fi
}


#
# Script
#

# # Validate sudo privileges first so it can be used with rsync
# printf "Superuser privileges required.\n"
sudo -v

# Default rsync is out of date and lacks some necessary options
require "exec" "${RSYNC_PATH}" "updated rsync found"

# Verify that source is readable
require "read" "${SOURCE}" "source directory readable"

# Verify that target is available and writable
require "write" "${TARGET}" "target directory writable"

# Use rsync to make a backup with '--link-dest' used to save space
do_or_exit "sudo ${RSYNC_PATH} \
  --archive \
  --verbose \
  --xattrs \
  --hard-links \
  --acls \
  --progress \
  --human-readable \
  --one-file-system \
  --delete \
  --delete-excluded \
  --exclude-from=${EXCLUDE} \
  --link-dest=${PREVIOUS} \
  ${SOURCE} ${TARGET}" \
  "rsync failed - no backup made"

# Remove the previous backup directory as the new backup has hard links to it
do_or_exit "sudo rm -f ${PREVIOUS}" "previous backup not removed"
# Restablish the "current backup" symbolic link pointing to the latest backup
do_or_exit "sudo ln -s ${TARGET} ${PREVIOUS}" "current backup link not created"
# Log successful backup
backup_log "SUCCESS: backup of ${SOURCE} to ${TARGET} completed"

# Truncate the logfile if necessary
if_exists "write" "${LOG_PATH}" "trim_backup_log"
