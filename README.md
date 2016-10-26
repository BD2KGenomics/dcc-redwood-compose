# ucsc-storage
ICGC Storage System Adapted for UCSC in Docker Compose

## Overview
This project runs the _ucsc-storage-server_, _ucsc-metadata-server_, and _ucsc-auth-server_ (closely based off if ICGC's storage system servers) as well as the MongoDB and PostgreSQL instances that the servers require.

## Running
This project expects that `ucsc-storage-server`, `ucsc-metadata-server`, and `ucsc-auth-server` Docker images will already be available on the current machine. To build these, run `docker built -t ucsc-storage-server dcc-storage/dcc-storage-server` and the equivalent commands for _dcc-auth/dcc-auth-server_ and _dcc-metadata/dcc-metadata-server_. 

You'll also want to make a `.env` file in the `storage-service` directory with contents like the following:

```
TRUSTSTORE_PASSWORD=<your_truststore_password>
KEYSTORE_PASSWORD=<your_keystore_password>
METADATA_CLIENT_SECRET=<your_metadata_server_client_secret>
STORAGE_CLIENT_SECRET=<your_storage_server_client_secret>
AUTH_DB_PASSWORD=<your_postgres_password>
AWS_SECRET_KEY=<your_aws_secret_key>
```

Also, look through the environment variables defined in `docker-compose.yml` and update values where necessary.

Then you can start the system with: `docker-compose up` and stop it with `docker-compose down`.

## Configuration
Environment variables are set on the Docker containers to specify credentials and URIs to the other servers.

## SSL
The servers only listen for https connections and expect requests to come via on of the following URLs:
- _storage.ucsc-cgl.org:*_
- _ucsc-auth-server:*_
- _ucsc-metadata-server:*_

The self-signed SSL certificate they all use has common name _storage.ucsc-cgl.org_. The rest of the URLs are listed as SubjectAltNames.

To generate new ssl certificates:
```
openssl req -x509 -newkey rsa:2048 -nodes -subj '/C=US/ST=CA/L=Santa Cruz/O=UCSC/OU=Genomics/CN=storage.ucsc-cgl.org/emailAddress=genomics-group@ucsc.edu/subjectAltName=DNS.1=ucsc-auth-server,DNS.2=ucsc-metadata-server' -days 1000 -keyout storage.ucsc-cgl.org.key -out storage.ucsc-cgl.org.crt
openssl pkcs12 -inkey storage.ucsc-cgl.org.key -in storage.ucsc-cgl.org.crt -export -out storage.ucsc-cgl.org.p12
# enter password to use for outputted pkcs keystore
keytool -delete -keystore cacerts -storepass changeit -alias storage.ucsc-cgl.org
keytool -importkeystore -srckeystore storage.ucsc-cgl.org.p12 -srcstoretype pkcs12 -destkeystore storage.ucsc-cgl.org.jks -deststoretype jks -deststorepass password
```
