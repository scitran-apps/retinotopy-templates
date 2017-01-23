#!/bin/bash
# Exports the container in the cwd.
# The container can be exported once it's started with
repo=scitran
gear=retinotopy-templates
version=0.1.0
outname=../export/$gear-$version.tar
container=$gear
image=$repo/$gear

# Check if input was passed in.
if [[ -n $1 ]]; then
    outname=$1
fi

docker create --name=$container $image
docker export $container | gzip > $outname.gz
docker rm $container
openssl dgst -sha384 $outname.gz
