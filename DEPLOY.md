# Deploy Guide

## Overview
This is a guide for deploying Redwood to production. Italicized names should be substituted as appropriate.

### From Scratch
Create buckets, ec2, encryption key, etc. in the same region.
- Region: Oregon (us-west-2)

Create the storage system S3 bucket (with logging enabled). This will hold the storage system data.
- Bucket Name: redwood-2.0.1
- Region: Oregon
- Logging Enabled: true
- Logging Target Bucket: redwood-2.0.1
- Logging Target Prefix: logs/

Create an IAM role to grant to the storage service ec2.
- Role Name: redwood-2.0.1-server
- Role Type: EC2
- Add Policy: AmazonS3FullAccess

Create a IAM KMS Encryption Key to encrypt S3 data.
- Key Alias: redwood-2-0-1-master-key
- Key Administrators: you
- Key Users: redwood-2.0.1-server
- This is the role just created

Create the storage service EC2.
- AMI: Amazon Linux AMI 2016.09.0 (PV) - ami-3c3b632b
- Instance Type: m1.xlarge
- IAM Role: redwood-2.0.1-server
- Security Group Name: redwood-2.0.1-security-group
- SSH Key Pair: <your key pair>

Set the bucket policy to restrict access to the IAM role, root AWS account, and specific users. The following example is
based on [this article](https://aws.amazon.com/blogs/security/how-to-restrict-amazon-s3-bucket-access-to-a-specific-iam-role/).
```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Deny",
			"Principal": "*",
			"Action": [
				"s3:GetObject",
				"s3:DeleteObject",
				"s3:PutObject"
			],
			"Resource": [
				"arn:aws:s3:::redwood-2.0.1",
				"arn:aws:s3:::redwood-2.0.1/*"
			],
			"Condition": {
				"StringNotLike": {
					"aws:userId": [
						"AROAJECLC5JG6SW3H26DO:*",
						"111111111111"
					]
				}
			}
		}
	]
}
```
The "aws:userId" entry starting with "AROA..." is the userid of the IAM role. It can be retrieved by running `aws iam get-role --role-name redwood-2.0.1-server` with the aws cli.
"111111111111" is the user id of the root user of the AWS account.

Confirm this worked.
- You can try `aws s3 ls s3://redwood-2.0.1` from both the ec2 and another environment that has s3 access but doesn't have the role. Access should be denied to the latter.

Create an elastic IP.
- Allocate it to the storage service EC2

Connect to the EC2.
- ssh -i beranucscedu.pem ec2-user@35.162.230.56

Configure aws to use the IAM role by editing ~/.aws/config to contain:
```
[profile redwood]
role_arn = arn:aws:iam::862902209576:role/redwood-2.0.1-server
source_profile = default
role_arn should be set to the ARN of your IAM role
```

Prepare the system.
- `mkdir -p ~/redwood/dcc-auth && mkdir ~/redwood/dcc-metadata && mkdir ~/redwood/dcc-storage`
- add `export REDWOOD_HOME=~/redwood` to your ~/.bash_profile (and `source ~/.bash_profile`).
- Install docker and docker-compose

Push the ssl certificate/key (in PKCS2 and JKS) and truststore to the EC2. Try to get existing ones from an administrator. Otherwise clone BD2KGenomics/dcc-redwood-storage on a computer not exposed to the internet and follow the directions in the README. Then scp the bundle to the ec2.
- `scp artifacts.tar.gz ec2-user@35.162.230.56:~/redwood/`

Push the Dockerfiles, dcc archives to the EC2.
- `cd dcc-auth/dcc-auth-server && scp Dockerfile target/dcc-*-dist.tar.gz ec2-user@35.161.26.142:~/redwood/dcc-auth`
- etc. for dcc-metadata and dcc-storage

Build the ucsc-auth-server, ucsc-metadata-server, and ucsc-storage-server images.
- `cd ~/redwood/dcc-auth && docker build -t ucsc-auth`

Push the storage-service docker-compose setup to the EC2.
- `cd dcc-redwood-storage && scp -r storage-service ec2-user@35.161.26.142:~/redwood/`

Edit _~/redwood/storage-service/docker-compose.yml_ to remove remote debug ports (800[0|1|2]:8000) and db exposure (all
port settings for the 2 dbs). Edit or create _~/redwood/storage-service/.env_ to contain the relevant passwords (see this project's root README).

Run the system.
- `docker-compose up -d`

Update the auth database with correct user/client credentials and scope availability.
- `docker exec -it ucsc-auth-db psql -U postgres -d dcc`
  - `update oauth_client_details set client_secret='secretpassword' where client_id='storage';`
    - etc. for metadata and mgmt
  - `update users set password='othersecretpassword' where username='mgmt';`
  - `update oauth_client_details set scope='s3.upload,s3.download,read/ckcc,write/ckcc,read/wcdt,write/wcdt' where client_id='mgmt';`
