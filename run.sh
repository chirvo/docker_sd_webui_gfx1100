#!/bin/bash

# You can change CONTAINER_BIN to docker if you like
CONTAINER_BIN=/usr/bin/podman
#Add to the list below any other directory you want to export
SUBDIRS="embeddings extensions models outputs repositories"
# Any extra option you wanna set, e.g. -v /mnt/sd-checkpoint-collection:/srv/webui/models/Stable-diffusion
EXTRA_OPTIONS="-it --rm --name temporary-sd-webui"
# You can change the tcp port
PORT=7860


# Here be dragons
#
run () {
  # $1: BASEDIR
  # $2: IMAGE

  # Prepare sub directories
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

  # Generate container options
  CONTAINER_OPTIONS="--security-opt seccomp=unconfined --device /dev/kfd:/dev/kfd --device /dev/dri:/dev/dri"

  if [ "$CONTAINER_BIN" == "/usr/bin/podman" ]; then
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS --group-add keep-groups"
  else
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS --group-add video"
  fi

  for SUBDIR in $SUBDIRS
  do
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS -v ./$1/$SUBDIR:/srv/webui/$SUBDIR"
  done

  CONTAINER_OPTIONS="$CONTAINER_OPTIONS -p $PORT:7860"

  #run the command
  $CONTAINER_BIN run $CONTAINER_OPTIONS $EXTRA_OPTIONS $2
}

IMAGE_AUTOMATIC1111=localhost/chirvo_sd/stable_diffusion_automatic1111:latest
IMAGE_VLADMANDIC=localhost/chirvo_sd/stable_diffusion_vladmandic:latest

case "$1" in
vladmandic)	echo "Running $IMAGE_VLADMANDIC"
      cat << EOF

  Note: The "vladmandic" container is BROKEN and exists for TESTING PURPOSES ONLY.
        If you feel you can help making the vladmandic/automatic webui run with
        this image, you are more than welcome to help.

EOF
      run vlad $IMAGE_VLADMANDIC
        ;;
--help)	echo "Usage: $0 <{vladmandic|--help}>"
      cat << EOF
  Running this script with no arguments will run the "automatic1111" container.
  The container has to be built previously before running this script.

  Note: The "vladmandic" container is BROKEN and exists for TESTING PURPOSES ONLY.
        If you feel you can help making the vladmandic/automatic webui run with
        this image, you are more than welcome to help.

EOF
        ;;
*)	echo "Running $IMAGE_AUTOMATIC1111"
      run webui $IMAGE_AUTOMATIC1111
        ;;
esac
exit 0




