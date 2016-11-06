#!/bin/bash
# Exports the container in the cwd.
# The container can be exported once it's started with
repo=scitran
gear=retinotopy-templates
version=0.0.2
outname=export/$gear-$version.tar
container=$gear
image=$repo/$gear

# Check if input was passed in.
if [[ -n $1 ]]; then
    outname=$1
fi

docker run --name=$container --entrypoint=/bin/true $image
docker export -o $outname $container
docker rm $container
gzip $outname
openssl dgst -sha384 $outname.gz
