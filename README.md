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

To generate new ssl certificates, see the `ssl` directory.