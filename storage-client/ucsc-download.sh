#!/bin/bash

#
# Usage: icgc-download.sh object-id output-dir
#

# get accessToken
accessToken=`cat accessToken`

# setup
object=$1
download=$2

# perform download
java -Djavax.net.ssl.trustStore=ssl/cacerts -Djavax.net.ssl.trustStorePassword=changeit -Dmetadata.url=https://storage.ucsc-cgl.org:8444 -Dmetadata.ssl.enabled=true -Dclient.ssl.custom=false -Dstorage.url=https://storage.ucsc-cgl.org:5431 -DaccessToken=${accessToken} -jar icgc-storage-client-1.0.14-SNAPSHOT/lib/icgc-storage-client.jar download --output-dir ${download} --object-id ${object} --output-layout bundle
