#!/bin/bash

docker exec -it ucsc-auth-server curl -k -XPUT https://localhost:8543/admin/scopes/beni -u admin:secret -d"s3.upload s3.download"
curl -k https://localhost:8443/oauth/token -H "Accept: application/json" -dgrant_type=password -dusername=beni -dscope="s3.upload s3.download" -ddesc="access token for benjaminran2@gmail.com" -u mgmt:pass
