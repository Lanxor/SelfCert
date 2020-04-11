#! /usr/bin/env bash

##
# Create the Intermediate CA Certificate
##

ROOT_PROJECT_DIR=$(dirname "$(dirname "`readlink -f "$0"`")")
source "${ROOT_PROJECT_DIR}/include/base-function.sh"

source "${ROOT_PROJECT_DIR}/conf/global.conf"
source "${ROOT_PROJECT_DIR}/include/arg-parser.sh"
source "${ROOT_PROJECT_DIR}/conf/config.conf"

source "${ROOT_PROJECT_DIR}/include/msg-error.sh"
source "${ROOT_PROJECT_DIR}/include/msg-warning.sh"

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

##
# Prepare the Intermediate CA environment
##
cai_prepare_env
case $? in
    0) ;;
    1) err_cai_exists;;
    2) err_cai_env_conf;;
    *) cai_clean; err_cai_env;;
esac

##
# Create the Intermediate CA certificate
##
cai_create_key
case $? in
    0) ;;
    2) warn_cai_key_bad_permissions;;
    *) cai_clean; err_cai_create_key;;
esac

cai_create_csr
if [ $? -ne 0 ]; then
    cai_clean; err_cai_created_csr
fi

cai_create_cert
case $? in
    0) ;;
    2) warn_cai_cert_bad_permissions;;
    *) cai_clean; err_cai_create_cert;;
esac

cai_create_chain
case $? in
    0) ;;
    2) warn_cai_chain_bad_permissions;;
    *) err_cai_create_chain;;
esac

green "The Intermediate CA Certificate is ready to be used !"

exit 0
