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

Set the bucket policy to restrict access to the IAM role, root AWS account, and specific users.
```
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Effect": "Deny",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": [
      "arn:aws:s3:::redwood-2.0.1",
      "arn:aws:s3:::redwood-2.0.1/*"
    ],
    "Condition": {
      "StringNotLike": {
        "aws:userId": [
          "AROAJECLC5JG6SW3H26DO:*",
          "AIDAJZCDUUUUYJNM7BUYA",
          "111111111111"
        ]
      }
    }
  }
  ]
}
```
The "aws:userId" entry starting with "AROA..." is the userid of the IAM role. It can be retrieved by running `aws iam get-role --role-name redwood-2.0.1-server` with the aws cli.
The "aws:userId" entry starting with "AIDA..." is the userid of an IAM user. It can be retrieved by running `aws iam get-user --user-name beran@ucsc.edu`.
"111111111111" is the user id of the root user of the AWS account.

Confirm this worked.
- TODO

Create the storage service EC2.
- AMI: Amazon Linux AMI 2016.09.0 (PV) - ami-3c3b632b
- Instance Type: m1.xlarge
- IAM Role: redwood-2.0.1-server
- Security Group Name: redwood-2.0.1-security-group
- SSH Key Pair: <your key pair>

Connect to the EC2.
- ssh -i beranucscedu.pem ec2-user@35.162.230.56

Configure aws to use the IAM role by editing ~/.aws/config to contain:
```
[profile redwood]
role_arn = arn:aws:iam::862902209576:role/redwood-2.0.1-server
source_profile = default
role_arn should be set to the ARN of your IAM role
```

If available, get the existing storage system ssl certificates (JKS and PKCS12) from an administrator. Otherwise clone BD2KGenomics/dcc-redwood-storage on a computer not exposed to the internet and follow the directions in the README. Then scp the certificates to the ec2.
- `scp artifacts.tar.gz ec2-user@35.162.230.56:~/redwood/`

Prepare the system.
- `mkdir -p ~/redwood/dcc-auth && mkdir ~/redwood/dcc-metadata && mkdir ~/redwood/dcc-storage`
- add `export DCC_HOME=~/redwood` to your ~/.bash_profile (and `source ~/.bash_profile`).
- Install docker and docker-compose

