#
# Return Codes
#
E_OK=0
E_USAGE=1
E_USER=2
E_MISSING_REQUIREMENTS=3
E_FMS_SERVER_NOT_RUNNING=4
E_NO_CONFIG=5
E_INSTALL_DIRECTORY_EXISTS=6

#
# Metadata
#
INSTALLABLES=(
  LICENSE
  README.md
  common.sh
  get_certificate.sh
  revoke_certificate.sh
)

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
