#! /usr/bin/env bash

usage() {
    echo "Usage: $0 {create|revoke|infos}"
}

ROOT_PROJECT_DIR=$(dirname "$(dirname "`readlink -f "$0"`")")
source "${ROOT_PROJECT_DIR}/include/base-function.sh"

source "${ROOT_PROJECT_DIR}/conf/global.conf"
source "${ROOT_PROJECT_DIR}/include/arg-parser.sh"
source "${ROOT_PROJECT_DIR}/conf/config.conf"

source "${ROOT_PROJECT_DIR}/include/msg-error.sh"
source "${ROOT_PROJECT_DIR}/include/msg-warning.sh"

source "${ROOT_PROJECT_DIR}/include/ca-root-function.sh"

if [ $# -lt 1 ]; then
    red "Missing argument. Need at least one argument !"
    err_usage
fi

arg="$1"; shift
case "${arg}" in
    create)
        ca_prepare_env
        case $? in
            0) ;;
            1) err_ca_exists;;
            2) err_ca_env_conf;;
            *) ca_clean; err_ca_env;;
        esac

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
    ;;

    revoke)
        ca_check_env
        case $? in
            0) ;;
            1) err_ca_nexists;;
            2)
                if [ "${CLEAN}" == '1' ]; then
                    ca_clean
                    if [ $? -ne 0 ]; then
                        err_ca_clean
                    fi
                    green "The Root CA has been cleaned !"
                fi;;
            *) err_ca_env_conf;;
        esac

        if [ "${FORCE}" != '1' ]; then
            echo -n "Are you sure to revoke the certificate [N/y] ?"; ask_action default_no
            if [ $? -eq 0 ]; then
                green "The certificate has not been revoked !"
                exit 0
            fi
        fi

        if [ "${CLEAN}" != '1' ]; then
            err_ca_revoke
        else
            ca_clean
            if [ $? -ne 0 ]; then
                err_ca_clean
            fi
            green "The Root CA has been cleaned !"
        fi
    ;;

    infos)
        ca_check_env
        case $? in
            0) ;;
            1) err_ca_nexists;;
            *) err_ca_env_conf;;
        esac

        openssl x509 -in "${CA_CERT}" ${ARGS_OPENSSL}
        res=$?
        if [ ${res} -ne 0 ]; then
            err_openssl ${res}
        fi
    ;;

    *) err_unknown_arg "${arg}"
esac

exit 0
