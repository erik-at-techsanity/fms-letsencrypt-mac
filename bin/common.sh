#
# Paths and Files
#
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
PREFIX="$(dirname "${BASH_SOURCE[0]}")/.."
ETC_DIR="${PREFIX}/etc"
CONFIG_FILE=${ETC_DIR}/fms-letsencrypt-mac.conf
CONFIG_FILE_DIST=${ETC_DIR}/fms-letsencrypt-mac.dist.conf

#
# Return Codes
#
# shellcheck disable=SC2034
E_OK=0
E_USAGE=1
E_USER=2
E_MISSING_REQUIREMENTS=3
E_FMS_SERVER_NOT_RUNNING=4
E_NO_CONFIG=5
E_INSTALL_DIRECTORY_EXISTS=6

#
# Functions
#
function log {
  LEVEL=$1
  MESSAGE=$2
  TIMESTAMP=$(date +"%Y-%m-%d %H-%I-%S")
  echo "${TIMESTAMP} : ${LEVEL} : ${MESSAGE}"
}

function fms_process_count {
  COUNT=$(pgrep "fmserverd|fmsib|fmsased|fmslogtrimmer|fmserver_helperd" | wc -l | awk '{ print $1 }')
  echo "${COUNT}"
}
