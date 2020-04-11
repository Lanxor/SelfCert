#! /usr/bin/env bash

usage() {
    echo "Usage: $0 {root|intermediate|server}"
}

ROOT_PROJECT_DIR="$(dirname "`readlink -f "$0"`")"
source "${ROOT_PROJECT_DIR}/include/base-function.sh"
source "${ROOT_PROJECT_DIR}/include/msg-error.sh"

if [ $# -lt 1 ]; then
    red "Missing argument. Need at least one argument !"
    err_usage
fi

arg="$1"; shift
case "${arg}" in
    root) bash "${ROOT_PROJECT_DIR}/scripts/ca-root-manager.sh" $@;;
    int|intermediate) bash "${ROOT_PROJECT_DIR}/scripts/ca-intermediate-manager.sh" $@;;
    serv|server) bash "${ROOT_PROJECT_DIR}/scripts/server-manager.sh" $@;;
    *) err_unknow_arg "${arg}";;
esac

exit $?
