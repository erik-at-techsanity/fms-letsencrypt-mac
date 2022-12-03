#
# Paths
#
LETS_ENCRYPT_DIR="/etc/letsencrypt/live"
FILEMAKER_SERVICE="com.filemaker.fms"
CERTBOT_LOG="/var/log/letsencrypt/letsencrypt.log"
LAUNCH_DAEMONS_DIR="/Library/LaunchDaemons"
TEMP_DIR=/tmp

#
# Behaviour Settings
#
DRY_RUN=0
FMS_STOP_SLEEP_TIME=5
FETCH_CERTIFICATE=1
TESTING=0

#
# Deployment Settings
#
DOMAIN="yourserver.yourdomain.com"
EMAIL="you@yourdomain.com"
FMS_USER="your_fms_admin_username"
FMS_PASSWORD="your_fms_admin_password"
FMS_SERVER_PATH="/Library/FileMaker Server"
INSTALL_DIR="/path/to/your/install/dir"
SERVICE_NAME="com.techsanity.fms-ssl"
#
# Derived Settings
#
WEB_ROOT="${FMS_SERVER_PATH}/HTTPServer/htdocs"
CSTORE_DIR="${FMS_SERVER_PATH}/CStore"
SERVER_KEY="${CSTORE_DIR}/serverKey.pem"

FULLCHAIN_SOURCE="${LETS_ENCRYPT_DIR}/${DOMAIN}/fullchain.pem"
FULLCHAIN_DESTINATION="${CSTORE_DIR}/fullchain.pem"

PRIVKEY_SOURCE="${LETS_ENCRYPT_DIR}/${DOMAIN}/privkey.pem"
PREVKEY_DESTINATION="${CSTORE_DIR}/privkey.pem"

PLIST_FILE="${SERVICE_NAME}.plist"
PLIST_TEMPLATE_FILE="${PLIST_FILE}.template"

#
# Return Codes
#
E_OK=0
E_USAGE=1
E_USER=2
E_MISSING_REQUIREMENTS=3
E_FMS_SERVER_NOT_RUNNING=4

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
