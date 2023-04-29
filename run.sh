#!/bin/bash

# You can change CONTAINER_BIN to docker if you like
CONTAINER_BIN=/usr/bin/podman
#Add to the list below any other directory you want to export
# NOTE: This won't work if you pass --with-local-git-clone
SUBDIRS="embeddings extensions models outputs repositories"
# Any extra option you wanna set, e.g. -v /mnt/sd-checkpoint-collection:/srv/webui/models/Stable-diffusion
EXTRA_OPTIONS="-it --rm --name temporary-sd-webui"
# You can change the tcp port
PORT=7860

###################
# Here be dragons
#
run () {
  # $1: BASEDIR
  # $2: IMAGE
  # $3: GIT_CLONE

  # Generate container's base options
  CONTAINER_OPTIONS="--security-opt seccomp=unconfined --device /dev/kfd:/dev/kfd --device /dev/dri:/dev/dri"
  CONTAINER_OPTIONS="$CONTAINER_OPTIONS -p $PORT:7860"

  if [ "$CONTAINER_BIN" == "/usr/bin/podman" ]; then
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS --group-add keep-groups"
  else
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS --group-add video"
  fi

  if [ "$3" == "--with-local-git-clone" ]; then
    # Let's clone the app repo
    REPO=AUTOMATIC1111/stable-diffusion-webui
    if [ "$2" == "$IMAGE_VLADMANDIC" ]; then
      REPO=vladmandic/automatic
    fi
    git clone https://github.com/$REPO.git $1
    # Mount the cloned repo over
    CONTAINER_OPTIONS="$CONTAINER_OPTIONS -v ./$1:/srv/webui"
  else
    # We won't clone
    # Prepare sub directories
    for SUBDIR in $SUBDIRS
    do
      if [ ! -d "./$1/$SUBDIR" ]; then
        mkdir -p ./$1/$SUBDIR
      fi
      CONTAINER_OPTIONS="$CONTAINER_OPTIONS -v ./$1/$SUBDIR:/srv/webui/$SUBDIR"
    done
    if [ ! -f "./$1/models/VAE-approx/model.pt" ]; then
      mkdir -p ./$1/models/VAE-approx
      cd ./$1/models/VAE-approx
      wget https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/models/VAE-approx/model.pt
      cd -
    fi
  fi

  #run the command
  $CONTAINER_BIN run $CONTAINER_OPTIONS $EXTRA_OPTIONS $2
}

IMAGE_AUTOMATIC1111=localhost/chirvo_sd/stable_diffusion_automatic1111:latest
IMAGE_VLADMANDIC=localhost/chirvo_sd/stable_diffusion_vladmandic:latest

case "$1" in
# $1:
# $2: Options
  vladmandic)	echo "Running container $IMAGE_VLADMANDIC"
    cat << EOF

    Note: The "vladmandic" container is BROKEN and exists for TESTING PURPOSES ONLY.
    If you feel you can help making the vladmandic/automatic webui run with
    this image, you are more than welcome to help.

EOF
    read -p "Do you want to proceed? (yes/no) " yn

    case $yn in
      yes) echo Ok, here be dragons
        ;;
      *) echo Aborting.;
        exit
        ;;
    esac
    run vlad $IMAGE_VLADMANDIC $2
      ;;
  --help)	echo "Usage: $0 <{automatic1111|vladmandic|--help}> <--with-local-git-clone>"
    cat << EOF

    Running this script with no arguments will run the "automatic1111" container.
    The container has to be built previously before running this script.

    Note: The "vladmandic" container is BROKEN and exists for TESTING PURPOSES ONLY.
    If you feel you can help making the vladmandic/automatic webui run with
    this image, you are more than welcome to help.

EOF
  ;;
  automatic1111|*)	echo "Running container $IMAGE_AUTOMATIC1111"
    [ "$1" == "--with-local-git-clone" ] || [ "$2" == "--with-local-git-clone" ] && CLONE="--with-local-git-clone"
    run webui $IMAGE_AUTOMATIC1111 $CLONE
  ;;
esac
exit 0

