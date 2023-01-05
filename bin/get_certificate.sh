#!/bin/bash

#
# Creates an SSL Certificate from the Let's Encrypt Certificate Authority (CA) to encrypt data in motion for FileMaker.
# Notes:
#   1. Certbot requires that port 80 be forwarded to your server.
#   2. This must be run as root.
#
# TODO:
#  * logrotate
#

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
SELF=$(basename "${BASH_SOURCE[0]}")

TESTING=0
DRY_RUN=0
SKIP_FILEMAKER_RESTART=9

source "${SCRIPT_DIR}/common.sh"

if [[ ! -e ${CONFIG_FILE} ]] ; then
  echo "ERROR: Please ensure ${CONFIG_FILE} exists. You may need to copy it from ${CONFIG_FILE_DIST} and edit it."
  exit ${E_NO_CONFIG}
fi

source ${CONFIG_FILE}

function usage() {
  echo "Usage: ${SELF} [-d] [-f] [-t] [-h]"
  echo "Where: -d don't actually perform the certificate creation"
  echo "       -f skip FileMaker-related steps (for testing)"
  echo "       -t use the Lets Encrypt testing environment"
  echo "       -h prints this help message and exits"
  exit ${E_USAGE}
}

while getopts "dfht" OPT ; do
	case ${OPT} in
	  "f")
	    SKIP_FILEMAKER_STEPS=1
	    ;;
    "t")
      TESTING=1
      ;;
    "d")
      DRY_RUN=1
      ;;
    "h"|*)
      usage
      exit ${E_USAGE}
      ;;
	esac
done
shift $((OPTIND-1))

# Checks to see if script is running as root.
if [[ ${DRY_RUN} -eq 0 && "${EUID}" -ne 0 ]] ; then
  echo "Please run as root"
  exit ${E_USER}
fi

# Check to see if certbot is installed.
if ! type certbot > /dev/null ; then
    log "ERROR" "Certbot could not be found. Run 'brew install certbot'."
    exit ${E_MISSING_REQUIREMENTS}
fi

if ! type fmsadmin > /dev/null ; then
    echo "ERROR" "fmsadmin could not be found - is FileMaker Server installed?"
    exit ${E_MISSING_REQUIREMENTS}
fi

log "INFO" "Domain:              ${DOMAIN}"
log "INFO" "Email:               ${EMAIL}"
log "INFO" "Server Path:         ${FMS_SERVER_PATH}"
log "INFO" "Web Root:            ${WEB_ROOT}"
log "INFO" "CStore Dir:          ${CSTORE_DIR}"
log "INFO" "CertBot Logfile:     ${CERTBOT_LOG}"
log "INFO" "Dry Run:             ${DRY_RUN}"

if [[ ${DRY_RUN} -eq 1 ]] ; then
  exit ${E_OK}
fi

PSCOUNT=$(fms_process_count)
if [[ ${PSCOUNT} -eq 0 && ${SKIP_FILEMAKER_STEPS} -ne 1 ]] ; then
  log "ERROR" "FileMaker service is not running - quitting"
  exit ${E_FMS_SERVER_NOT_RUNNING}
fi

if [[ ${DRY_RUN} -eq 0 ]] ; then
  if [[ ${TESTING} -eq 1 ]] ; then
    TEST_CERT_ARG="--test-cert"
  else
    TEST_CERT_ARG=""
  fi

  # Get the certificate
  log "INFO" "Fetching Certificate"
  certbot certonly ${TEST_CERT_ARG} --webroot -w "${WEB_ROOT}" -d "${DOMAIN}" --agree-tos -m "${EMAIL}" --preferred-challenges "http" -n > /dev/null 2>&1
  RESULT=$?
  log "INFO" "Certificate Fetch return code: ${RESULT}"
else
  log "INFO" "Not fetching certificate as requested"
fi

if [[ -e "${FULLCHAIN_DESTINATION}" && -e "${PRIVATE_KEY_DESTINATION}" ]] ; then
  if [[ ! $(diff "${FULLCHAIN_SOURCE}" "${FULLCHAIN_DESTINATION}") && ! $(diff "${PRIVATE_KEY_SOURCE}" "${PRIVATE_KEY_DESTINATION}") ]] ; then
    log "INFO" "No updated certificate received - quitting"
    exit ${E_OK}
  fi
fi

log "INFO" "Updated certificate received - installing"

cp "${FULLCHAIN_SOURCE}" "${FULLCHAIN_DESTINATION}"
cp "${PRIVATE_KEY_SOURCE}" "${PRIVATE_KEY_DESTINATION}"

chmod 640 "${CSTORE_DIR}/privkey.pem"

# move the old certificate if there is one to prevent an error
if [[ -e "${SERVER_KEY}" ]]; then
    log "WARNING" "${SERVER_KEY} exists. Moving to serverKey-old.pem to prevent an error."
    mv "${SERVER_KEY}" "${CSTORE_DIR}/serverKey-old.pem"
fi

if [[ ${SKIP_FILEMAKER_STEPS} -ne 1 ]] ; then
  log "INFO" "Removing old certificate"
  fmsadmin -u "${FMS_USER}" -p "${FMS_PASSWORD}" certificate delete --yes > /dev/null
  RESULT=$?
  log "INFO" "certificate delete return code: ${RESULT}"

  # Install the certificate
  log "INFO" "Installing new certificate"
  fmsadmin \
    -u "${FMS_USER}" \
    -p "${FMS_PASSWORD}" \
    certificate import "${CSTORE_DIR}/fullchain.pem" \
    --keyfile "${CSTORE_DIR}/privkey.pem" \
    -y > /dev/null

  RESULT=$?
  log "INFO" "certificate import return code: ${RESULT}"

  # Stop FileMaker Server
  log "INFO" "Stopping FileMaker Server"
  launchctl stop ${FILEMAKER_SERVICE}

  PSCOUNT=$(fms_process_count)
  while [[ ${PSCOUNT} -ne 0 ]] ; do
    log "INFO" "Sleeping for ${FMS_STOP_SLEEP_TIME} seconds while the service stops (Process count: ${PSCOUNT})"
    sleep ${FMS_STOP_SLEEP_TIME}
    PSCOUNT=$(fms_process_count)
  done

  # Start FileMaker Server again
  log "INFO" "Starting FileMaker Server"
  launchctl start ${FILEMAKER_SERVICE}
fi

log "INFO" "Done"

exit ${E_OK}
