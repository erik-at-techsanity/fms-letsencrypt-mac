#!/bin/bash

PREFIX=$(dirname "${BASH_SOURCE[0]}")

source "${PREFIX}/common.sh"
if [[ ! -e "${PREFIX}/config.sh" ]] ; then
  echo "ERROR: Please ensure config.sh exists. You may need to copy it from config.dist.sh and edit it."
  exit ${E_NO_CONFIG}
fi
source "${PREFIX}/config.sh"

function egress {
  if [[ -e ${TEMP_FILE} ]] ; then
    log "INFO" "Removing ${TEMP_FILE}"
    rm -f ${TEMP_FILE}
  fi
}

trap egress EXIT

# Checks to see if script is running as root.
if [[ ${EUID} -ne 0 ]] ; then
  echo "Please run as root."
  exit ${E_USER}
fi

if [[ -e ${INSTALL_DIR} ]] ; then
  log "ERROR" "Installation directory ${INSTALL_DIR} already exists. Please remove and retry"
  exit ${E_INSTALL_DIRECTORY_EXISTS}
else
  log "INFO" "Creating install directory ${INSTALL_DIR}"
  mkdir ${INSTALL_DIR}
fi

for INSTALLABLE in "${INSTALLABLES[@]}" ; do
  log "INFO" "Copying ${INSTALLABLE} to ${INSTALL_DIR}"
  cp "${INSTALLABLE}" "${INSTALL_DIR}"
done

TEMP_FILE=$(mktemp)
log "INFO" "Copying ${PLIST_TEMPLATE_FILE} to ${TEMP_FILE}"
cp "${PREFIX}/${PLIST_TEMPLATE_FILE}" "${TEMP_FILE}"

### Sed time
sed -i BAK "s|%%INSTALL_DIR%%|${INSTALL_DIR}|" "${TEMP_FILE}"
sed -i BAK "s|%%SERVICE_NAME%%|${SERVICE_NAME}|" "${TEMP_FILE}"

log "INFO" "Copying ${TEMP_FILE} to ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
cp "${TEMP_FILE}" "${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"

log "INFO" "Changing ownership of ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
chown root:wheel "${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"

log "INFO" "Changing file mode of ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
chmod o-w "${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"

log "INFO" "Done"
