#!/bin/bash
for SUBDIR in models/VAE-approx repositories extensions outputs
do
  if [ ! -d "./vlad/$SUBDIR" ]; then
    mkdir -p ./vlad/$SUBDIR
  fi
done

if [ ! -f "./vlad/models/VAE-approx/model.pt" ]; then
  cd ./vlad/models/VAE-approx
  wget https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/models/VAE-approx/model.pt
  cd -
fi

/usr/bin/podman run \
  --security-opt seccomp=unconfined \
  --group-add keep-groups \
  --device /dev/kfd:/dev/kfd \
  --device /dev/dri:/dev/dri \
  -v ./vlad/models:/srv/webui/models \
  -v ./vlad/repositories:/srv/webui/repositories \
  -v ./vlad/extensions:/srv/webui/extensions \
  -v ./vlad/outputs:/srv/webui/outputs \
  -p 3000:7860 \
  -it \
  --rm \
  localhost/chirvo_sd/stable_diffusion_vladmandic:latest

