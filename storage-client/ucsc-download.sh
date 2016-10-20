#!/bin/bash

#
# Usage: icgc-download.sh object-id output-dir
#

# get accessToken
accessToken=`cat accessToken`

# config
metadata_server_url=https://storage.ucsc-cgl.org:8444
storage_server_url=https://storage.ucsc-cgl.org:5431
trust_store_path=../ssl/artifacts/cacerts
trust_store_pass=changeit

# setup
object=$1
download=$2

# perform download
java -Djavax.net.ssl.trustStore=${trust_store_path} -Djavax.net.ssl.trustStorePassword=${trust_store_pass} -Dmetadata.url=${metadata_server_url} -Dmetadata.ssl.enabled=true -Dclient.ssl.custom=false -Dstorage.url=${storage_server_url} -DaccessToken=${accessToken} -jar icgc-storage-client-1.0.14-SNAPSHOT/lib/icgc-storage-client.jar download --output-dir ${download} --object-id ${object} --output-layout bundle
