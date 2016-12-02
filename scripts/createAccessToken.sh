#!/bin/bash

user=beni

docker exec -it ucsc-auth-server curl -k -XPUT https://localhost:8543/admin/scopes/$user -u admin:secret -d"s3.upload s3.download"
curl -k https://localhost:8443/oauth/token -H "Accept: application/json" -dgrant_type=password -dusername=$user -dscope="s3.upload s3.download" -ddesc="test access token" -u mgmt:pass
