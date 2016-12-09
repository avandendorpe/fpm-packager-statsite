#! /bin/bash
set -eux

docker build -t statsite-packager .
CONTAINER=$(docker create statsite-packager)
if [ ! -d ./artifacts ]; then
    mkdir ./artifacts
fi
docker cp $CONTAINER:/build/statsite_0.8.0-amd64.deb ./artifacts/
docker rm $CONTAINER
