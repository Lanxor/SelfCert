##
# Check the Intermediate CA environment
# 0     : certificate exists (ready)
# 1     : certificate does not exists (not ready)
# 2     : environment is not properly configured (not ready)
##
cai_check_env() {
    if [ ! -d "${CAI_DIR}" ]; then
        return 1
    fi
    cd "${CAI_DIR}"
    
    if [ ! -f "${CAI_CONF}" -o ! -f "${CAI_KEY}" -o ! -f "${CAI_CERT}" -o ! -f "${CAI_DB}" -o ! -f "${CAI_SERIAL}" ]; then
        return 2
    fi
    
    return 0
}

##
# Prepare the Intermediate CA environment
# 0     : environment configured (ready)
# 1     : intermediate ca already exists
# 2     : not ready (not properly configured)
# 3+    : not ready
##
cai_prepare_env() {
    if [ -d "${CAI_DIR}" ]; then
        cd "${CAI_DIR}"
        
        if [ -f "${CAI_CONF}" -a -f "${CAI_KEY}" -a -f "${CAI_CERT}" -a -f "${CAI_DB}" -a -f "${CAI_SERIAL}" -a -f "${CAI_CERT_CHAIN}" ]; then
            return 1
        fi

        if [ ! -f "${CAI_CONF}" -o ! -f "${CAI_KEY}" -o ! -f "${CAI_CERT}" -o -f "${CAI_DB}" -o -f "${CAI_SERIAL}" -o -f "${CAI_CERT_CHAIN}"]; then
            return 2
        fi
    fi

    mkdir -p "${CAI_DIR}"
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 3
    fi

    cd "${CAI_DIR}"

    mkdir -p certs crl csr newcerts private
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 4
    fi

    chmod 700 private
    check_cmd

    touch "${CAI_DB}"
    check_cmd

    echo 1000 > "${CAI_SERIAL}"
    check_cmd

    echo 100 > "${CAI_CRLNUMBER}"
    check_cmd

    cp "${OPENSSL_CONF}" "${CAI_CONF}"
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 5
    fi

    sed -i "s,%%CA_DIR%%,${CAI_DIR},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_DB%%,${CAI_DB},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_SERIAL%%,${CAI_SERIAL},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_KEY%%,${CAI_KEY},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_CERT%%,${CAI_CERT},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_CRLNUMBER%%,${CAI_CRLNUMBER},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_CRL%%,${CAI_CRL},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_POLICY%%,${CAI_POLICY},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_DAYS%%,${CAI_DAYS},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_O%%,${CAI_DEFAULT_O},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_OU%%,${CAI_DEFAULT_OU},g" "${CAI_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_CN%%,${CAI_DEFAULT_CN},g" "${CAI_CONF}"; check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 6
    fi

    return 0
}

##
# Create the Intermediate CA key
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
cai_create_key() {
    openssl genrsa \
        -out "${CAI_KEY}" \
        2048
    if [ $? -ne 0 ]; then
        return 1
    fi

    chmod 400 "${CAI_KEY}"
    if [ $? -ne 0 ]; then
        return 2
    fi

    return 0
}

##
# Create the Intermediate CA (CSR) certificate signing request
# 0     : created
# 1     : not created (openssl error)
##
cai_create_csr() {
    openssl req \
        -batch \
        --config ${CAI_CONF} \
	    -new \
        -sha256 \
	    -key "${CAI_KEY}" \
	    -out "${CAI_CSR}"
    if [ $? -ne 0 ]; then
	    return 1
    fi

    return 0
}

##
# Create the Intermediate CA certificate
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
cai_create_cert() {
    openssl ca \
        -batch \
        --config "../../${CA_CONF}" \
	    -extensions v3_intermediate_ca \
	    -days 32 \
        -notext \
        -md sha256 \
	    -in "${CAI_CSR}" \
	    -out "${CAI_CERT}"
    if [ $? -ne 0 ]; then
	    return 1
    fi
    
    chmod 444 "${CAI_CERT}"
    if [ $? -ne 0 ]; then
        return 2
    fi

    return 0
}

##
# Create the Certificate Chain File
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
cai_create_chain() {
    cat "${CAI_CERT}" ../../${CA_CERT} > "${CAI_CERT_CHAIN}"
    if [ $? -ne 0 ]; then
	    return 1
    fi
    
    chmod 444 "${CAI_CERT_CHAIN}"
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
cai_valid() {
    if [ ! -f "../../${CA_CERT}" -o ! -f "${CAI_CERT}" ]; then
        return 1
    fi
    
    openssl verify \
        -CAfile "../../${CA_CERT}" \
        "${CAI_CERT}"
    if [ $? -ne 0 ]; then
        return 2
    fi

    return 0
}

##
# Revoke the Intermediate CA by the Root CA
# 0     : revoked or not valid
# 1     : certificate file or openssl configuration file not found
# 2     : already revoked
# 3     : not revoked (openssl error)
##
cai_revoke() {
    if [ ! -f "../../${CA_CONF}" -o ! -f "${CAI_CERT}" ]; then
        return 1
    fi

    openssl ca \
        -config "../../${CA_CONF}" \
        -revoke "${CAI_CERT}"
    case $? in 
        0);;
        1) return 2;;
        *) return 3;;
    esac

    return 0
}

##
# Clean the Intermediate CA files
# 0     : cleaned
# 1     : not cleaned
##
cai_clean() {
    if [ -d "${CAI_DIR}" ]; then
        rm -rf "${CAI_DIR}"
        if [ $? -ne 0 ]; then
            return 2
        fi
    fi
    
    return 0
}
