#!/bin/bash

if [ ! -d "./webui/models/VAE-approx" ]; then
  mkdir -p ./webui/models/VAE-approx
fi

if [ ! -f "./webui/models/VAE-approx/model.pt" ]; then
  cd ./webui/models/VAE-approx
  wget https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/models/VAE-approx/model.pt
  cd -
fi

/usr/bin/podman run \
  --security-opt seccomp=unconfined \
  --group-add keep-groups \
  --device /dev/kfd:/dev/kfd \
  --device /dev/dri:/dev/dri \
  -v ./webui/models:/srv/webui/models/ \
  -v ./webui/repositories:/srv/webui/repositories/ \
  -v ./webui/extensions:/srv/webui/extensions/ \
  -v ./webui/outputs:/srv/webui/outputs/ \
  -p 3000:7860 \
  -it \
  --rm \
  localhost/chirvo_sd/stable_diffusion_webui:latest

