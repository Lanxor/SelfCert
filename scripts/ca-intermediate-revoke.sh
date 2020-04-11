#! /usr/bin/env bash

##
# Revoke the Intermediate CA Certificate
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

cai_check_env
case $? in
    0) ;;
    1) err_cai_nexists;;
    2)
        if [ "${CLEAN}" == '1' ]; then
            cai_clean
            if [ $? -ne 0 ]; then
                err_cai_clean
            fi
            green "The Intermediate CA has been cleaned !"
        fi;;
    *) err_cai_env_conf;;
esac

##
# Revoke the Intermediate CA Certificate
##
if [ "$FORCE" != '1' ]; then
    echo -n "Are you sure to revoke the certificate [N/y] ? "; ask_action default_no
    if [ $? -eq 0 ]; then
        green "The certificate has not been revoked !"
        exit 0
    fi
fi

cai_revoke
case $? in
    0)
        green "The Intermediate CA has been revoked !";;
    2) warn_cai_already_revoked;;
    *) err_cai_revoke;;
esac

if [ "${CLEAN}" == '1' ]; then
    cai_clean
    if [ $? -ne 0 ]; then
        err_cai_clean
    fi
    green "The Intermediate CA has been cleaned !"
fi

exit 0
