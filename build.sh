#!/usr/bin/env bash
if [ $# -eq 0 ]
  then
    tag='latest'
  else
    tag=$1
fi

podman image build -f ubuntu22.04_rocm5.5.dockerfile -t ubuntu22.04_rocm5.5:$tag .
