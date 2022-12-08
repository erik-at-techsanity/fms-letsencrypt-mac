                                     #
# Paths - you probably do not want to change these
#
LETS_ENCRYPT_DIR="/etc/letsencrypt/live"
FILEMAKER_SERVICE="com.filemaker.fms"
CERTBOT_LOG="/var/log/letsencrypt/letsencrypt.log"
LAUNCH_DAEMONS_DIR="/Library/LaunchDaemons"

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
DOMAIN="yourserver.yourcompany.ca"
EMAIL="you@yourcompany.ca"
FMS_USER="admin"
FMS_PASSWORD="bogus123"
FMS_SERVER_PATH="/Library/FileMaker Server"
INSTALL_DIR="/usr/local/fms-letsencrypt"
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
