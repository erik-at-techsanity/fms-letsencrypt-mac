#!/bin/bash

PREFIX=$(dirname "${BASH_SOURCE[0]}")

source "${PREFIX}/common.sh"
if [[ ! -e "${PREFIX}/config.sh" ]] ; then
  echo "ERROR: Please ensure config.sh exists. You may need to copy it from config.dist.sh and edit it."
  exit ${E_NO_CONFIG}
fi
source "${PREFIX}/config.sh"

# Checks to see if script is running as root.
if [[ ${EUID} -ne 0 ]] ; then
  echo "Please run as root."
  exit ${E_USER}
fi

if [[ -d "${INSTALL_DIR}" ]] ; then
  log "INFO" "Removing ${INSTALL_DIR}"
  rm -rf "${INSTALL_DIR}"
fi

if [[ -e "${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}" ]] ; then
  log "INFO" "Stopping service ${SERVICE_NAME}"
  launchctl stop ${SERVICE_NAME}

  log "INFO" "Unloading ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
  launchctl unload ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}

  log "INFO" "Removing ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
  rm -f "${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
fi

log "INFO" "Done"
