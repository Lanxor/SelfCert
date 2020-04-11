
err() {
    red "$2"
    exit $1
}

##
# Common error
##
err_usage() {
    usage
    exit 1
}

err_unknown_arg() {
    err 2 "Unknow argument '$1'"
}

err_openssl() {
    err 3 "Error with the command 'openssl'. Please report this glitch !"
}

##
# Error related to Root CA
##
err_ca_exists() {
    err 10 "The Root CA Certificate already exists !"
}

err_ca_nexists() {
    err 11 "The Root CA Certificate does not exists !"
}

err_ca_env_prepare() {
    err 12 "The Root CA environment is not ready !"
}

err_ca_env_conf() {
    err 13 "The Root CA environment is not properly configured !"
}

err_ca_create_key() {
    err 14 "The Root CA Key file has not been created !"
}

err_ca_create_cert() {
    err 15 "The Root CA Certificate file has not been created !"
}

err_ca_revoke() {
    err 16 "The only way to revoke the Root CA is to clean it ! Use '--clean' option."
}

err_ca_clean() {
    err 17 "The Root CA has not been cleaned !"
}


##
# Error related to Intermediate CA
##
err_cai_exists() {
    err 30 "The Intermediate CA Certificate already exists !"
}

err_cai_nexists() {
    err 31 "The Intermediate CA Certificate does not exists !"
}

err_cai_env_prepare() {
    err 32 "The Intermediate environment is not ready !"
}

err_cai_env_conf() {
    err 33 "The Intermediate environment is not properly configured !"
}

err_cai_create_key() {
    err 34 "The Intermediate CA Key file has not been created !"
}

err_cai_create_csr() {
    err 35 "The Intermediate CA CSR file has not been created !"
}

err_cai_create_cert() {
    err 36 "The Intermediate CA Certificate file has not been created !"
}

err_cai_create_chain() {
    err 37 "The Root Chain file has not been created !"
}

err_cai_revoke() {
    err 38 "The Intermediate CA has not been revoked !"
}

err_cai_clean() {
    err 39 "The Intermediate CA has not been cleaned !"
}

##
# Error related to Server Certificate
##
err_serv_exists() {
    err 50 "The Server Certificate already exists !"
}

err_serv_nexists() {
    err 51 "The Server Certificate does not exists !"
}

err_serv_env_prepare() {
    err 52 "The Server Certificate environment is not ready !"
}

err_serv_env_conf() {
    err 53 "The Server Certificate environment is not properly configured !"
}

err_serv_create_key() {
    err 54 "The Server Certificate Key file has not been created !"
}

err_serv_create_csr() {
    err 55 "The Server Certificate CSR file has not been created !"
}

err_serv_create_cert() {
    err 56 "The Server Certificate file has not been created !"
}

err_serv_create_chain() {
    err 57 "The Server Chain file has not been created !"
}

err_serv_revoke() {
    err 58 "The Server Certificate has not been revoked !"
}

err_serv_clean() {
    err 59 "The Server Certificate has not been cleaned !"
}
