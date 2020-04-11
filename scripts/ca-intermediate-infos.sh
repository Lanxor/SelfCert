#! /usr/bin/env bash

##
# Get informations about the Intermediate CA Certificate
##

ROOT_PROJECT_DIR=$(dirname "$(dirname "`readlink -f "$0"`")")
source "${ROOT_PROJECT_DIR}/include/base-function.sh"

source "${ROOT_PROJECT_DIR}/conf/global.conf"
source "${ROOT_PROJECT_DIR}/include/arg-parser.sh"
source "${ROOT_PROJECT_DIR}/conf/config.conf"

source "${ROOT_PROJECT_DIR}/include/msg-error.sh"

source "${ROOT_PROJECT_DIR}/include/ca-root-function.sh"
source "${ROOT_PROJECT_DIR}/include/ca-intermediate-function.sh"

##
# Check the environment
##
ca_check_env
case $? in
    0) ;;
    1) err_ca_nexists;;
    *) err_ca_env_conf;;
esac

cai_check_env
case $? in
    0) ;;
    1) err_cai_nexists;;
    *) erri_cai_env_conf;;
esac

##
# Get informations
##
openssl x509 -in "${CAI_CERT}" ${ARGS_OPENSSL}
if [ $? -ne 0 ]; then
    err_openssl
fi

exit 0