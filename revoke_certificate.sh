#!/bin/bash

PREFIX=$(dirname "${BASH_SOURCE[0]}")

source "${PREFIX}/common.sh"
if [[ ! -e "${PREFIX}/config.sh" ]] ; then
  echo "ERROR: Please ensure config.sh exists. You may need to copy it from config.dist.sh and edit it."
  exit ${E_NO_CONFIG}
fi
source "${PREFIX}/config.sh"

function usage() {
    echo "Usage: ${SELF} [ -t ] [ -h ]"
    echo "Where: -t indicates to use the Lets Encrypt testing environment"
    echo "       -h Prints this help message and exits"
    exit ${E_USAGE}
}

while getopts "htx" OPT ; do
	case ${OPT} in
        "t")
            TESTING=1
            ;;
        "h"|*)
            usage
            exit ${E_USAGE}
            ;;
    esac
done
shift $((OPTIND-1))

if [[ ${TESTING} -eq 1 ]] ; then
    TEST_CERT_ARG="--test-cert"
else
    TEST_CERT_ARG=""
fi

certbot revoke "${TEST_CERT_ARG}" --agree-tos -m "${EMAIL}" --cert-path "${LETS_ENCRYPT_DIR}/${DOMAIN}/cert.pem" -n
