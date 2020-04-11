#! /usr/bin/env bash

usage() {
    echo "Usage: $0 {created|revoke|infos}"
}

ROOT_PROJECT_DIR=$(dirname "$(dirname "`readlink -f "$0"`")")
source "${ROOT_PROJECT_DIR}/include/base-function.sh"
source "${ROOT_PROJECT_DIR}/include/msg-error.sh"

if [ $# -lt 1 ]; then
    red "Missing argument. Need at least one argument !"
    err_usage
fi

arg="$1"; shift
case "${arg}" in
    create) bash "${ROOT_PROJECT_DIR}/scripts/ca-intermediate-create.sh" $@;;
    revoke) bash "${ROOT_PROJECT_DIR}/scripts/ca-intermediate-revoke.sh" $@;;
    infos) bash "${ROOT_PROJECT_DIR}/scripts/ca-intermediate-infos.sh" $@;;
    *) err_unknown_arg "${arg}";;
esac

exit $?
