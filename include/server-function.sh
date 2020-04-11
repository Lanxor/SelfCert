##
# Check the Server Certificate environment
# 0     : certificate exists (ready)
# 1     : certificate does not exists (not ready)
# 2     : environment is not properly configured (not ready)
##
serv_check_env() {
    if [ ! -d "${SERV_DIR}" ]; then
        return 1
    fi
    cd "${SERV_DIR}"

    if [ ! -f "${SERV_CONF}" -o ! -f "${SERV_KEY}" -o ! -f "${SERV_CERT}" -o ! -f "${SERV_CSR}" ]; then
        return 2
    fi

    return 0
}

##
# Prepare the Server environment
# 0     : environment configured (ready)
# 1     : server certificate already exists
# 2     : not ready (not properly configured)
# 3+    : not ready
##
serv_prepare_env() {
    if [ -d "${SERV_DIR}" ]; then
        cd "${SERV_DIR}"
        
        if [ -f "${SERV_CONF}" -a -f "${SERV_KEY}" -a -f "${SERV_CERT}" -a -f "${SERV_CERT_CHAIN}" ]; then
            return 1
        fi
        if [ ! -f "${SERV_CONF}" -o ! -f "${SERV_KEY}" -o ! -f "${SERV_CERT}" -o ! -f "${SERV_CERT_CHAIN}" ]; then
            return 2
        fi
    fi

    mkdir -p "${SERV_DIR}"
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 3
    fi
    cd "${SERV_DIR}"

    mkdir -p certs csr private
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 4
    fi

    cp "../../${CAI_CONF}" "${SERV_CONF}"
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 5
    fi

    sed -i "s,commonName_default.*,commonName_default\t\t= ${SERV_DEFAULT_CN},g" "${SERV_CONF}"
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 6
    fi

    return 0
}

##
# Create the Server key
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
serv_create_key() {
    openssl genrsa \
        -out "${SERV_KEY}" \
        2048
    if [ $? -ne 0 ]; then
	    return 1
    fi

    chmod 400 "${SERV_KEY}"
    if [ $? -ne 0 ]; then
        return 2
    fi

    return 0
}

##
# Create the Server (CSR) certificate signing request
# 0     : created
# 1     : not created (openssle error)
##
serv_create_csr() {
    openssl req \
        -batch \
        --config "${SERV_CONF}" \
	    -new \
        -sha256 \
	    -key "${SERV_KEY}" \
	    -out "${SERV_CSR}"
    if [ $? -ne 0 ]; then
	    return 1
    fi

    return 0
}

##
# Create the Server certificate
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
serv_create_cert() {
    openssl ca \
        -batch \
        --config "${SERV_CONF}" \
	    -extensions server_cert \
	    -days 32 \
        -notext \
        -md sha256 \
	    -in "${SERV_CSR}" \
	    -out "${SERV_CERT}"
    if [ $? -ne 0 ]; then
	    return 1
    fi
    
    chmod 444 "${SERV_CERT}"
    if [ $? -ne 0 ]; then
        return 2
    fi
    
    return 0
}

##
# Create the Server Certificate Chain File
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
serv_create_chain() {
    cat "${SERV_CERT}" "../../${CAI_CERT}" > "${SERV_CERT_CHAIN}"
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    chmod 444 "${SERV_CERT_CHAIN}"
    if [ $? -ne 0 ]; then
        return 2
    fi

    return 0
}

##
# Check if the certificate is valid.
# 0     : valid
# 1     : certificate not exists
# 2     : not valid
##
serv_valid() {
    if [ ! -f "../../${CAI_CERT_CHAIN}" -o ! -f "${SERV_CERT}" ]; then
        return 1
    fi

    openssl verify \
        -CAfile "../../${CAI_CERT_CHAIN}" \
        "${SERV_CERT}"
    if [ $? -ne 0 ]; then
        return 2
    fi
    
    return 0
}

##
# Revoke the Server Certificate by the Intermediate CA
# 0     : revoked
# 1     : certificate file or openssl configuration file not found
# 2     : already revoked
# 3     : not revoked (openssl error)
##
serv_revoke() {
    if [ ! -f "../../${CAI_CONF}" -o ! -f "${SERV_CERT}" ]; then
        return 1
    fi

    openssl ca \
        -config "../../${CAI_CONF}" \
        -revoke "${SERV_CERT}"
    case $? in
        0);;
        1) return 2;;
        *) return 3;;
    esac

    return 0
}

##
# Clean the Server Certificate files
# 0     : cleaned
# 1     : not cleaned
##
serv_clean() {
    if [ -d "${SERV_DIR}" ]; then
        rm -rf "${SERV_DIR}"
        if [ $? -ne 0 ]; then
            return 2
        fi
    fi

    return 0
}
