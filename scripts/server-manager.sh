#! /usr/bin/env bash

usage() {
    echo "Usage: $0 {create|revoke|infos} --servername servername"
}

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

if [ $# -lt 1 ]; then
    red "Missing argument. Need at least one argument !"
    err_usage
fi

if [ -z "${SERV_NAME}" ]; then
    red "The servername option must be specified !"
    err_usage
fi

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

arg="$1"; shift
case "${arg}" in
    create)
        serv_prepare_env
        case $? in
            0) ;;
            2) warn_serv_key_bad_permissions;;
            *) serv_clean; err_serv_create_key;;
        esac

        serv_create_key
        case $? in
            0) ;;
            2) warn_serv_key_bad_permissions;;
            *) serv_clean; err_serv_create_key;;
        esac

        serv_create_csr
        if [ $? -ne 0 ]; then
            serv_clean
            err_serv_create_csr
        fi

        serv_create_cert
        case $? in
            0) ;;
            2) warn_serv_cert_bad_permission;;
            *) serv_clean; err_serv_create_cert;;
        esac

        serv_create_chain
        case $? in
            0) ;;
            2) warn_serv_chain_bad_permission;;
            *) err_serv_create_chain;;
        esac

        green "The Server Certificate is ready to be used !"
    ;;
    
    revoke)
        serv_check_env
        case $? in
            0) ;;
            1) err_serv_nexists;;
            2)
                if [ "${CLEAN}" == '1' ]; then
                    serv_clean
                    if [ $? -ne 0 ]; then
                        err_serv_clean
                    fi
                    green "The Server Certificate has been cleaned !"
                fi;;
            *) err_serv_env_conf;;
        esac

        if [ "${FORCE}" != '1' ]; then
            echo -n "Are you sure to revoke the certificate [N/y] ? "; ask_action default_no
            if [ $? -eq 0 ]; then
                green "The certificate has not been revoked !"
                exit 0
            fi
        fi

        serv_revoke
        case $? in
            0) green "The Server Certificate has been revoked !";;
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
    ;;

    infos)
       serv_check_env
       case $? in
            0) ;;
            1) err_serv_nexists;;
            *) err_serv_env_conf;;
       esac

       openssl x509 -in "${SERV_CERT}" ${ARGS_OPENSSL}
       if [ $? -ne 0 ]; then
           err_openssl
       fi
    ;;

    *) err_unknown_arg "${arg}";;
esac

exit $?
