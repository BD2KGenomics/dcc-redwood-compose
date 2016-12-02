# ucsc-storage
ICGC Storage System Adapted for UCSC in Docker Compose

## Overview
This project runs the _ucsc-storage-server_, _ucsc-metadata-server_, and _ucsc-auth-server_ (closely based off if ICGC's storage system servers) as well as the MongoDB and PostgreSQL instances that the servers require.

## Run the System for Development
You'll need maven (3.2.5), docker, and docker-compose installed.

This project composes the two requisite databases and the `ucsc-storage-server`, `ucsc-metadata-server`, and `ucsc-auth-server` Docker images into a 5-container docker-compose setup.The _ucsc-*-server_ mages should be built on the current machine. To build them, clone the _dcc-storage_, _dcc-metadata_, and _dcc-auth_ repositories and run the following from a directory containing _dcc-storage_, _dcc-metadata_, and _dcc-auth_:

```
cd dcc-storage-server && mvn &&tar xvf dcc-storage/dcc-storage-server/target/*-dist.tar.gz && docker build -t ucsc-storage-server dcc-storage-server-*-SNAPSHOT; rm -r dcc-storage-*-SNAPSHOT && cd ..
cd dcc-metadata && tar xvf dcc-metadata-server/target/*-dist.tar.gz && docker build -t ucsc-metadata-server dcc-metadata-server-*-SNAPSHOT; rm -r dcc-metadata-*-SNAPSHOT && cd ..
cd dcc-auth && tar xvf dcc-auth-server/target/*-dist.tar.gz && docker build -t ucsc-auth-server dcc-auth-server-*-SNAPSHOT; rm -r dcc-auth-*-SNAPSHOT && cd ..
```

You'll also want to make a `.env` file in this directory (same directory as docker-compose.yml)  with contents like the following:

```
TRUSTSTORE_PASSWORD=changeit
KEYSTORE_PASSWORD=password
METADATA_CLIENT_SECRET=pass
STORAGE_CLIENT_SECRET=pass
AUTH_DB_PASSWORD=password
AUTH_ADMIN_PASSWORD=secret
AWS_ACCESS_KEY=<your_aws_access_key_here>
AWS_SECRET_KEY=<your_aws_secret_key_here>
```

Then you can start the system with: `docker-compose up` and stop it with `docker-compose down`.
