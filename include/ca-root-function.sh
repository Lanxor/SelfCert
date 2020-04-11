##
# Check the Root CA environment
# 0     : certificate exists (ready)
# 1     : certificate does not exists (not ready)
# 2     : environment is not properly configured (not ready)
##
ca_check_env() {
    if [ ! -d "${CA_DIR}" ]; then
        return 1
    fi
    cd "${CA_DIR}"
    
    if [ ! -f "${CA_CONF}" -o ! -f "${CA_KEY}" -o ! -f "${CA_CERT}" -o ! -f "${CA_DB}" -o ! -f "${CA_SERIAL}" ]; then
        return 2
    fi

    return 0
}

##
# Prepare the Root CA environment
# 0     : environment configurded (ready)
# 1     : root ca already exists (ready)
# 2     : not ready (not properly configured)
# 3+    : not ready
##
ca_prepare_env() {
    if [ -d "${CA_DIR}" ]; then
        cd "${CA_DIR}"
        
        if [ -f "${CA_CONF}" -a -f "${CA_KEY}" -a -f "${CA_CERT}" -a -f "${CA_DB}" -a -f "${CA_SERIAL}" ]; then
            return 1
        fi

        if [ -f "${CA_CONF}" -o -f "${CA_KEY}" -o -f "${CA_CERT}" -o -f "${CA_DB}" -o -f "${CA_SERIAL}" ]; then
            return 2
        fi
    fi

    mkdir -p "${CA_DIR}"
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 3
    fi
    cd "${CA_DIR}"

    mkdir -p certs crl newcerts private
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 3
    fi

    chmod 700 private

    touch "${CA_DB}"
    check_cmd

    echo 1000 > "${CA_SERIAL}"
    check_cmd

    cp "${OPENSSL_CONF}" "${CA_CONF}"
    check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 3
    fi

    sed -i "s,%%CA_DIR%%,${CA_DIR},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_DB%%,${CA_DB},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_SERIAL%%,${CA_SERIAL},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_KEY%%,${CA_KEY},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_CERT%%,${CA_CERT},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_CRLNUMBER%%,${CA_CRLNUMBER},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_CRL%%,${CA_CRL},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_POLICY%%,${CA_POLICY},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_DAYS%%,${CA_DAYS},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_O%%,${CA_DEFAULT_O},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_OU%%,${CA_DEFAULT_OU},g" "${CA_CONF}"; check_cmd
    sed -i "s,%%CA_DEFAULT_CN%%,${CA_DEFAULT_CN},g" "${CA_CONF}"; check_cmd
    check_err
    if [ $? -ne 0 ]; then
        return 3
    fi

    return 0
}

##
# Create the Root CA key
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
ca_create_key() {
    openssl genrsa \
        -out "private/ca.key.pem" \
        4096
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    chmod 400 "${CA_KEY}"
    if [ $? -ne 0 ]; then
        return 2
    fi
    
    return 0
}
 
##
# Create the Root CA certificate
# 0     : created
# 1     : not created (openssl error)
# 2     : created but wrong permissions (warning)
##
ca_create_cert() {
    openssl req \
        -batch \
        --config "${CA_CONF}" \
	    -key "${CA_KEY}" \
	    -new \
        -x509 \
        -days 7300 \
        -sha256 \
        -extensions v3_ca \
	    -out "${CA_CERT}"
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    chmod 444 "${CA_CERT}"
    if [ $? -ne 0 ]; then
        return 2
    fi

    return 0
}

##
# Clean the Root CA files
# 0     : cleaned
# 1     : not cleaned
##
ca_clean() {
    if [ -d "${CA_DIR}" ]; then
        rm -rf "${CA_DIR}"
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    return 0
}
