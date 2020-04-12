# Self Certification

## Purpose

The objective of this project is to make it possible to encrypt communications in an internal network not connected to the Internet.
The project allows the automation of self-signed certificates creation using the *openssl* tool.

## Security Warning

**Beware**, a self-signed certificate must not be used without knowing the risks.

A self-signed certificate :
1. does not guarantee the integrity of the server using it.
2. does not hide the identity of the server or client.
3. generates warnings (there is no chain of trust with a third party).

A self-signed certificate only encrypts communication over networks between the client and the server.

More information [here](https://security.stackexchange.com/questions/8110/what-are-the-risks-of-self-signing-a-certificate-for-ssl) and [there](https://developer.okta.com/blog/2019/10/23/dangers-of-self-signed-certs).

## This project is for

- Encrypt communications in a local network.
- Use of certificates in a local network with private domain names.
- Use SSL encryption for a web server in a local network with private domain name (apache2 or nginx).

## This project is not for

- Use of certificates directly on the Internet.

## Usage

#### 1 - Create the Root Authority Certificate
```
$ bash manager-cert.sh root create
```
You can find the Root CA certificate at :

*ca/{root_ca}/certs/ca.cert.pem*.

#### 2 - Create the Intermediate Authority Certificate
```
$ bash manager-cert.sh intermediate create
```
You can find the Intermediate CA certificate at :

*ca/{root_ca}/intermediate/{intermediate_ca}/certs/ca.cert.pem*.

#### 3 - Create the Server Certificate
```
$ bash manager-cert.sh server create --servername example.local
```
You can find the Intermediate CA certificate at :

*ca/{root_ca}/intermediate/{intermediate_ca}/server/{servername}/certs/server.cert.pem*.

### Others commands

- Revoke a server certificate :
```
bash manager-cert.sh server revoke --force --clean --servername servername
```

- Get informations about server certificate :
```
bash manager-cert.sh server info -noout -text
```

## Credits
I would like to thank the author of the [jamielinux.com](https://jamielinux.com/docs/openssl-certificate-authority/) website for the technical part of creating the different certificates.
