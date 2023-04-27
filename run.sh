#!/bin/bash

/usr/bin/podman run \
  --security-opt seccomp=unconfined \
  --group-add keep-groups \
  --device /dev/kfd:/dev/kfd \
  --device /dev/dri:/dev/dri \
  -v /home/chirvo/src/docker_sd_webui/webui/models:/srv/webui/models/ \
  -v /home/chirvo/src/docker_sd_webui/webui/repositories:/srv/webui/repositories/ \
  -v /home/chirvo/src/docker_sd_webui/webui/extensions:/srv/webui/extensions/ \
  -v /home/chirvo/src/docker_sd_webui/webui/outputs:/srv/webui/outputs/ \
  -p 3000:7860 \
  -it \
  --rm \
  localhost/chirvo_sd/stable_diffusion_webui:latest

