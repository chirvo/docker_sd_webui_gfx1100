#!/bin/bash
for SUBDIR in models/VAE-approx repositories extensions outputs
do
  if [ ! -d "./sd/$SUBDIR" ]; then
    mkdir -p ./sd/$SUBDIR
  fi
done

if [ ! -f "./sd/models/VAE-approx/model.pt" ]; then
  cd ./sd/models/VAE-approx
  wget https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/models/VAE-approx/model.pt
  cd -
fi

/usr/bin/podman run \
  --security-opt seccomp=unconfined \
  --group-add keep-groups \
  --device /dev/kfd:/dev/kfd \
  --device /dev/dri:/dev/dri \
  -v ./sd/models:/srv/webui/models \
  -v ./sd/repositories:/srv/webui/repositories \
  -v ./sd/extensions:/srv/webui/extensions \
  -v ./sd/outputs:/srv/webui/outputs \
  -p 3000:7860 \
  -it \
  --rm \
  localhost/chirvo_sd/stable_diffusion_automatic1111:latest

