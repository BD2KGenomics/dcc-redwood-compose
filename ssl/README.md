# cgl-ssl


## Overview
This project contains the SSL workspace for CGL's storage system. The `Makefile` controls the generation of an SSL certificate for use is the storage service, outputting the certificate and private key in PEM, PKCS12, and JKS. It also generates a java truststore that trusts the newly generated certificate.

The certificate is generated using the x509v3 _subjectAltNames_ extension to accept requests from within the Docker network to host aliases such as _ucsc-auth-server_ as well as external requests sent to our public domain, _storage.ucsc-cgl.org_.

In order to generate a private key and certificate in all the required formats, just run `make`.


## Usage
On a secure computer not publicly accessible from the internet:
- Clone the project
- Edit the makefile to contain the production passwords-to-be
  - You can also specify additional subjectAltNames in _openssl-cgl.cfg_.
- run `make` to generate the following:
  - _artifacts/serverssl.tar.gz_ - bundle containing ssl certificate/key in JKS and PKCS12 as well as a JVM truststore for use in the Redwood servers
  - _artifacts/clientssl.tar.gz_ - bundle containing JVM truststore for use in the Redwood client


## Resources
These may prove useful.
- O'Reilly's _Network Security with OpenSSL_
- [https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs]()
