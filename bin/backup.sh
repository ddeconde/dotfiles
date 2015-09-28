#!/bin/env bash


#
# Constants
#

readonly EXCLUDE=${HOME}/.backup/exclude
readonly BACKUP_DRIVE=""
readonly BACKUP_PATH="/Volumes/${BACKUP_DRIVE}/Backups/${HOSTNAME}"
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
readonly MAX_LOG_LENGTH=1000
readonly TRUNC_LOG_LENGTH=10


#
# Functions
#

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
  # write to a logfile if it exists; stay quiet if no log file exists
  local log_line="${DATE_TIME} ${HOSTNAME} ${1}"
  if_path_do "-w ${LOG_PATH}" "echo ${log_line} >> ${LOG_PATH}"
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
# sudo -v
#
# Too many sudo-requring commands, just use run_as_sudo instead

# Default rsync is out of date and lacks some necessary options
require_path "-x ${RSYNC_PATH}" "updated rsync found"

# Verify that source is readable
require_path "-r ${SOURCE}" "source directory readable"

# Verify that target is available and writable
require_path_ "-w ${TARGET}" "target directory writable"

# Use rsync to make a backup with '--link-dest' used to save space
do_or_exit "${RSYNC_PATH} \
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
  ${SOURCE} ${TARGET}"

# Remove the previous backup directory as the new backup has hard links to it
do_or_exit "rm -f ${PREVIOUS}"
# Restablish the "current backup" symbolic link pointing to the latest backup
do_or_exit "ln -s ${TARGET} ${PREVIOUS}"
# Log successful backup
backup_log "SUCCESS: backup of ${SOURCE} to ${TARGET} completed"

# Truncate the logfile if necessary
if_path_do "-w ${LOG_PATH}" "trim_backup_log"
