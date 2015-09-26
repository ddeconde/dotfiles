#!/usr/bin/env bash


readonly HOME_DIR="$(cd ~ && pwd)"
readonly PRIVATE_DIR="${HOME_DIR}/.private"


do_or_exit () {
  # execute argument command with success or exit
  $@
  retval=$?
  if (( $retval != 0 )); then
    echo_error "[ $@ ] failed."
    exit $retval
  fi
}

if_path_do () {
  # if first argument yields successful test then do second
  if [[ "$1" ]]; then
    do_or_exit "$2"
  fi
}

# local config
# ssh
# aws
# gpg



if_path_do "! -d ${PRIVATE_DIR}" "git clone ${DOTFILE_GIT_REPO} ${PRIVATE_DIR}"

link_conf_files () {
  for conf_file in "${1}/*"; do
    if_path_do "-f ${HOME_DIR}/.${conf_file}" "mv ${HOME_DIR}/.${conf_file} ${HOME_DIR}/.${conf_file}.old"
    do_or_exit "ln -s ${1}/${conf_file} ${HOME_DIR}/${2}/${conf_file}"
  done
}


link_conf_files "${PRIVATE_DIR}/${SSH_DIR}" "${SSH_DIR}"
link_conf_files "${PRIVATE_DIR}/${GPG_DIR}" "${GPG_DIR}"
link_conf_files "${PRIVATE_DIR}/${AWS_DIR}" "${AWS_DIR}"

link_conf_files "${PRIVATE_DIR}/${LOCAL_DIR}" "."
link_conf_files "${PRIVATE_DIR}/${AWS_DIR}" "."
