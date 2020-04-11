
warn() {
    yellow "Warning: $1"
}

##
# Warning related to Root CA
##
warn_ca_key_bad_permissions() {
    warn "The Root CA Key file does not have the right permissions !"
}

warn_ca_cert_bad_permissions() {
    warn "The Root CA Certificate file does not have the right permissions !"
}

##
# Warning related to Intermediate CA
##
warn_cai_key_bad_permissions() {
    warn "The Intermediate CA Key file does not have the right permissions !"
}

warn_cai_cert_bad_permissions() {
    warn "The Intermediate CA Certificate file does not have the right permissions !"
}

warn_cai_chain_bad_permissions() {
    warn "The Root Chain file does not have the right permissions !"
}

warn_cai_already_revoked() {
    warn "The Intermediate CA is already revoked !"
}

##
# Warning related to Server Certificate
##
warn_serv_key_bad_permissions() {
    warn "The Server Certificate Key file does not have the right permissions !"
}

warn_serv_cert_bad_permissions() {
    warn "The Server Certificate file does not have the right permissions !"
}

warn_serv_chain_bad_permissions() {
    warn "The Server Certificate Chain file does not have the right permissions !"
}

warn_serv_already_revoked() {
    warn "The Server Certificate is already revoked !"
}
