# Deploy Guide

## Overview
This is a guide for deploying Redwood to production.

### From Scratch
Create buckets, ec2, encryption key, etc. in the same region.
- Region: Oregon (us-west-2)

Create the storage system S3 bucket (with logging enabled). This will hold the storage system data.
- Bucket Name: redwood-2.0.1
- Region: Oregon
- Logging Enabled: true
- Logging Target Bucket: redwood-2.0.1
- Logging Target Prefix: logs/

Create an IAM user to use on the storage service ec2.
- User Name: redwood-2.0.1-server

Create a IAM KMS Encryption Key to encrypt S3 data.
- Key Alias: redwood-2-0-1-master-key
- Key Administrators: you
- Key Users: redwood-2.0.1-server
  - This is the user just created

Create the storage service EC2.
- AMI: Amazon Linux AMI 2016.09.0 (PV) - ami-3c3b632b
- Instance Type: m1.xlarge
- IAM Role: redwood-2.0.1-server
- Security Group Name: redwood-2.0.1-security-group
- SSH Key Pair: <your key pair>

Create an elastic IP and point your domain towards it.
- We used domain _storage.ucsc-cgl.org_
- Allocate the IP to the storage service EC2

Connect to the EC2.
- `ssh -i beranucscedu.pem ec2-user@storage.ucsc-cgl.org`

Prepare the system.
- `mkdir -p ~/redwood/dcc-auth && mkdir ~/redwood/dcc-metadata && mkdir ~/redwood/dcc-storage`
- add `export REDWOOD_HOME=~/redwood` to your ~/.bash_profile (and `source ~/.bash_profile`).
- Install docker and docker-compose

Push the ssl certificate/key (in PKCS2 and JKS) and truststore to the EC2. Try to get existing ones from an administrator. Otherwise clone BD2KGenomics/dcc-redwood-storage on a computer not exposed to the internet and follow the directions in the README. Then scp the bundle to the ec2.
- `scp serverssl.tar.gz ec2-user@35.162.230.56:~/redwood/`

Push the Dockerfiles and dcc archives for the storage-, metadata-, and auth-server to the EC2.
- `cd dcc-auth/dcc-auth-server && scp Dockerfile target/dcc-*-dist.tar.gz ec2-user@35.161.26.142:~/redwood/dcc-auth`
- etc. for dcc-metadata and dcc-storage

Build the ucsc-auth-server, ucsc-metadata-server, and ucsc-storage-server images.
- `cd ~/redwood/dcc-auth && docker build -t ucsc-auth-server .`

Push the storage-service docker-compose setup to the EC2.
- `cd dcc-redwood-storage && scp -r storage-service ec2-user@35.161.26.142:~/redwood/`

Edit _storage-service/.env_ and _~/redwood/storage-service/docker-compose.yml_ to specify production configuration.
- In the compose file:
  - remove remote debug ports (800[0|1|2]:8000)
  - remove db exposure (all port forwarding settings for the 2 dbs)
  - set UCSC_STORAGE_S3_BUCKET to the storage system bucket name (in this case _redwood-2.0.1_)
- Edit or create _storage-service/.env_ to contain the relevant passwords (see this project's root README).

Run the system.
- `docker-compose up -d`

Update the auth database with correct user/client credentials and scope availability.
- `docker exec -it ucsc-auth-db psql -U postgres -d dcc`
  - `update oauth_client_details set client_secret='secretpassword' where client_id='storage';`
    - etc. for metadata and mgmt
  - `update users set password='othersecretpassword' where username='mgmt';`
  - `update oauth_client_details set scope='s3.upload,s3.download,read/ckcc,write/ckcc,read/wcdt,write/wcdt' where client_id='mgmt';`

Expose ports 8444 and 5431 of the EC2 to the public, or at least to all users of the storage system.

The storage system should now be ready to authorize users for certain scopes, generate access tokens for users with sufficient
permission, and perform upload/download.