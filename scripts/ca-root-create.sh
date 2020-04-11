#! /usr/bin/env bash

##
# Create the Root CA Certificate
##

ROOT_PROJECT_DIR=$(dirname "$(dirname "`readlink -f "$0"`")")
source "${ROOT_PROJECT_DIR}/include/base-function.sh"

source "${ROOT_PROJECT_DIR}/conf/global.conf"
source "${ROOT_PROJECT_DIR}/include/arg-parser.sh"
source "${ROOT_PROJECT_DIR}/conf/config.conf"

source "${ROOT_PROJECT_DIR}/include/msg-error.sh"
source "${ROOT_PROJECT_DIR}/include/msg-warning.sh"

source "${ROOT_PROJECT_DIR}/include/ca-root-function.sh"

##
# Prepare the environment
##
ca_prepare_env
case $? in
    0) ;;
    1) err_ca_exists;;
    2) err_ca_env_conf;;
    *) ca_clean; err_ca_env;
esac

##
# Create the Root CA Certificate
##
ca_create_key
case $? in
    0) ;;
    2) warn_ca_key_bad_permissions;;
    *) ca_clean; err_ca_create_key;;
esac

ca_create_cert
case $? in
    0) ;;
    2) warn_ca_cert_bad_permissions;;
    *) ca_clean; err_ca_create_cert;;
esac

green "The Root CA Certificate is ready to be used !"

exit 0
