#! /usr/bin/env bash

##
# Create a Server Certificate
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
source "${ROOT_PROJECT_DIR}/include/server-function.sh"

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
    *) err_cai_env_conf;;
esac

##
# Prepare the Server environment
##
serv_prepare_env
case $? in
    0);;
    1) err_serv_exists;;
    2) err_serv_env_conf;;
    *) err_serv_env_prepare;;
esac

##
# Create the Server Certificate
##
serv_create_key
case $? in
    0) ;;
    2) warn_serv_key_bad_permissions;;
    *) cert_serv_clean; err_serv_create_key;;
esac

serv_create_csr
if [ $? -ne 0 ]; then
    cert_serv_clean
    err_serv_create_csr
fi

serv_create_cert
case $? in
    0) ;;
    2) warn_serv_cert_bad_permissions;;
    *) cert_serv_clean; err_serv_create_cert;;
esac

serv_create_chain
case $? in
    0) ;;
    2) warn_serv_chain_bad_permission;;
    *) err_serv_create_chain;;
esac

green "The Server Certificate is ready to be used !"

exit 0
