
ARGS=( "$@" )
ARGS_POS=( "$@" )

for i in "${!ARGS_POS[@]}"; do
    case "${ARGS_POS[i]}" in
        ''|-|--) ;;
        --CAname)
            if [[ "${ARGS_POS[i+1]:0:1}" != '-' ]]; then
                CA_NAME="${ARGS_POS[i+1]}"
                unset 'ARGS_POS[i+1]'
            fi;;
        --CAIname)
            if [[ "${ARGS_POS[i+1]:0:1}" != '-' ]]; then
                CAI_NAME="${ARGS_POS[i+1]}"
                unset 'ARGS_POS[i+1]'
            fi;;
        --servername)
            if [[ "${ARGS_POS}" != '-' ]]; then
                SERV_NAME="${ARGS_POS[i+1]}"
                unset 'ARGS_POS[i+1]'
            fi;;
        -f|--force)
            FORCE=1;;
        -s|--safe)
            FORCE=0;;
        -c|--clean)
            CLEAN=1;;
        -n|--noclean)
            CLEAN=0;;
        -noout|-text|-dates|-startdate|-enddate)
            ARGS_OPENSSL="${ARGS_OPENSSL}${ARGS_POS[i]} ";;
        *) continue;;
    esac
    unset 'ARGS_POS[i]'
done
