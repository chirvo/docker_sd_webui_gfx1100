#!/bin/bash

CONTAINER_BIN=/usr/bin/podman
#Add to the list below any other directory you want to export
SUBDIRS="embeddings extensions models outputs repositories"
CONTAINER_OPTIONS="-it --rm --security-opt seccomp=unconfined --device /dev/kfd:/dev/kfd --device /dev/dri:/dev/dri"
# Any extra option you wanna set, e.g. -v /mnt/sd-checkpoint-collection:/srv/webui/models/Stable-diffusion
EXTRA_OPTIONS=""
PORT=3000
IMAGE_AUTOMATIC1111=localhost/chirvo_sd/stable_diffusion_automatic1111:latest
IMAGE_VLADMANDIC=localhost/chirvo_sd/stable_diffusion_vladmandic:latest

prepare_subdirs () {
  #: $1 BASEDIR
  for SUBDIR in $SUBDIRS
  do
    if [ ! -d "./$1/$SUBDIR" ]; then
      mkdir -p ./$1/$SUBDIR
    fi
  done
  if [ ! -f "./$1/models/VAE-approx/model.pt" ]; then
    mkdir -p ./$1/models/VAE-approx
    cd ./$1/models/VAE-approx
    wget https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/models/VAE-approx/model.pt
    cd -
  fi
}

generate_options () {
  #: $1 BASEDIR
  if [ "$CONTAINER_BIN" == "/usr/bin/podman" ]; then
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS --group-add keep-groups"
  else
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS --group-add video"
  fi

  for SUBDIR in $SUBDIRS
  do
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS -v ./$1/$SUBDIR:/srv/webui/$SUBDIR"
  done
}

run () {
  # $1: BASEDIR
  # $2: IMAGE
  prepare_subdirs $1
  generate_options $1
  $CONTAINER_BIN run $CONTAINER_OPTIONS $EXTRA_OPTIONS $2
}

case "$1" in
vladmandic)	echo "Running $IMAGE_VLADMANDIC"
      $CONTAINER_BIN run $CONTAINER_OPTIONS $IMAGE
        ;;
--help)	echo "Usage: $0 <{vladmandic|--help}>"
      cat << EOF
  Running this script with no arguments will run the "automatic1111" container.
  The container has to be built previously before running this script.

  Note: The "vladmandic" container is BROKEN and exists for TESTING PURPOSES ONLY.
        If you feel you can help making the vladmandic/automatic webui run with
        this image, you are more than welcome to help.

EOF
automatic1111)	echo "Running $IMAGE_AUTOMATIC1111"
      $CONTAINER_BIN run $CONTAINER_OPTIONS $IMAGE
        ;;
        exit 2
        ;;
esac
exit 0




