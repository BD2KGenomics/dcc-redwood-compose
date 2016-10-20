#!/bin/bash

#
# Usage: ucsc-upload.sh dataFile...
#

# setup
uuid=`uuidgen`
echo using tmp dir $uuid
upload=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`/upload/${uuid}
manifest=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`/manifest/${uuid}
mkdir -p ${upload}
mkdir -p ${manifest}
cp $* ${upload}

# config
metadata_server_url=https://storage.ucsc-cgl.org:8444
storage_server_url=https://storage.ucsc-cgl.org:5431
trust_store_path=../ssl/artifacts/cacerts
trust_store_pass=changeit

# get accessToken
accessToken=`cat accessToken`

# register upload
echo Registering upload:
java -Djavax.net.ssl.trustStore=${trust_store_path} -Djavax.net.ssl.trustStorePassword=${trust_store_pass} -Dserver.baseUrl=${metadata_server_url} -DaccessToken=${accessToken} -jar dcc-metadata-client-0.0.16-SNAPSHOT/lib/dcc-metadata-client.jar -i ${upload} -o ${manifest} -m manifest.txt

# perform upload
echo Performing upload:
java -Djavax.net.ssl.trustStore=${trust_store_path} -Djavax.net.ssl.trustStorePassword=${trust_store_pass} -Dmetadata.url=${metadata_server_url} -Dmetadata.ssl.enabled=true -Dclient.ssl.custom=false -Dstorage.url=${storage_server_url} -DaccessToken=${accessToken} -jar icgc-storage-client-1.0.14-SNAPSHOT/lib/icgc-storage-client.jar upload --manifest ${manifest}/manifest.txt

# cleanup
rm -r ${upload}
rm -r ${manifest}
