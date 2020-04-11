#! /usr/bin/env bash

##
# Revoke the Server Certificate
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

serv_check_env
case $? in
    0);;
    1) err_serv_nexists;;
    2)
        if [ "${CLEAN}" == '1' ]; then
            serv_clean
            if [ $? -ne 0 ]; then
                err_serv_clean
            fi
            green "The Server Certificate has been cleaned !"
        fi ;;
    *) err_serv_env_conf;;
esac

##
# Revoke the Server Certificate
##
if [ "$FORCE" != '1' ]; then
    echo -n "Are you sure to revoke the certificate [N/y] ? "; ask_action default_no
    if [ $? -eq 0 ]; then
        green "The certificate has not been revoked !"
        exit 0
    fi
fi

serv_revoke
case $? in
    0)
        green "The Server Certificate has been revoked !";;
    2) warn_serv_already_revoked;;
    *) err_serv_revoke;;
esac

if [ "${CLEAN}" == '1' ]; then
    serv_clean
    if [ $? -ne 0 ]; then
        err_serv_clean
    fi
    green "The Server Certificate has been cleaned !"
fi

exit 0
