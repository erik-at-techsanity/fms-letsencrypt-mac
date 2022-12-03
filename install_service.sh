#!/bin/bash

PREFIX=$(dirname ${BASH_SOURCE})

source ${PREFIX}/common.sh

log "INFO" "Copying ${PLIST_FILE} to ${LAUNCH_DAEMONS_DIR}"
cp ${PLIST_FILE} ${LAUNCH_DAEMONS_DIR}

log "INFO" "Changing ownership of ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
chown root:wheel ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}

log "INFO" "Changing file mode of ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE}"
chmod o-w ${LAUNCH_DAEMONS_DIR}/${PLIST_FILE} 

log "INFO" "Done"
