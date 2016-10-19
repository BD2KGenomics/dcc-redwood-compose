# cgl-ssl


## Overview
This project contains the SSL workspace for CGL's storage system. The `Makefile` controls the generation of an SSL certificate for use is the storage service, outputting the certificate and private key in PEM, PKCS12, and JKS. It also generates a java truststore that trusts the newly generated certificate.

In order to generate a private key and certificate in all the required formats, just run `make`.


## Passwords
The existing setup uses the passwords specified in the Makefile to non-interactively generate all certificate variants.


## Resources
These may prove useful.
- O'Reilly's _Network Security with OpenSSL_
- [https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs]()
