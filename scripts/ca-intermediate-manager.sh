#! /usr/bin/env bash

usage() {
    echo "Usage: $0 {created|revoke|infos}"
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

if [ $# -lt 1 ]; then
    red "Missing argument. Need at least one argument !"
    err_usage
fi

ca_check_env
case $? in
    0) ;;
    1) err_ca_nexists;;
    *) err_ca_env_conf;;
esac

arg="$1"; shift
case "${arg}" in
    create)
        cai_prepare_env
        case $? in
            0) ;;
            1) err_cai_exists;;
            2) err_cai_env_conf;;
            *) cai_clean; err_cai_env;;
        esac

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

        green "The Intermediate CA Cerificate is ready to be used !"
    ;;

    revoke)
        cai_check_env
        case $? in
            0) ;;
            1) err_cai_nexists
                if [ "${CLEAN}" == '1' ]; then
                    cai_clean
                    if [ $? -ne 0 ]; then
                        err_cai_clean
                    fi
                    green "The Intermediate CA has been cleaned !"
                fi;;
            *) err_cai_env_conf;;
        esac

        if [ "${FORCE}" != '1' ]; then
            echo -n "Are you sur to revoke the certificate [N/y] ? "; ask_action default_no
            if [ $? -eq 0 ]; then
                green "The certificate has not been revoked !"
                exit 0
            fi
        fi

        cai_revoke
        case $? in
            0) green "The Intermediate CA has been revoked !";;
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
    ;;

    infos)
        cai_check_env
        case $? in
            0) ;;
            1) err_cai_nexists;;
            *) err_cai_env_conf;;
        esac

        openssl x509 -in "${CAI_CERT}" ${ARGS_OPENSSL}
        if [ $? -ne 0 ]; then
            err_openssl
        fi
    ;;

    *) err_unknown_arg "${arg}";;
esac

exit 0
