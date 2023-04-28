#!/bin/bash

#CONTAINER_BIN=/usr/bin/docker
CONTAINER_BIN=/usr/bin/podman
IMAGE_ROCM=rocm5.5_ubuntu22.04
IMAGE_PYTORCH=pytorch2.0_gfx1100
IMAGE_AUTOMATIC1111=stable_diffusion_automatic1111
IMAGE_VLADMANDIC=stable_diffusion_vladmandic

build_image () {
	$CONTAINER_BIN image build -f ${1}.dockerfile -t chirvo_sd/${1}:latest
}

clean () {
  for IMAGE in $($CONTAINER_BIN images | grep 'chirvo_sd' | awk '{print $3}' | grep -v IMAGE)
	do
	echo -n "Removing '$IMAGE': "
		echo $CONTAINER_BIN image rm $IMAGE 2>&1 > /dev/null 
		[ $? -eq 0 ] && echo "done." || "error." 
	done
}

case "$1" in
all) echo "Building all"
      build_image $IMAGE_ROCM
      build_image $IMAGE_PYTORCH
      build_image $IMAGE_AUTOMATIC1111
      build_image $IMAGE_VLADMANDIC
	;;
rocm)	echo "Building $IMAGE_ROCM"
      build_image $IMAGE_ROCM
        ;;
pytorch)	echo "Building $IMAGE_PYTORCH"
      build_image $IMAGE_PYTORCH
        ;;
automatic1111)	echo "Building $IMAGE_AUTOMATIC1111"
      build_image $IMAGE_AUTOMATIC1111
        ;;
vladmandic)	echo "Building $IMAGE_VLADMANDIC"
      build_image $IMAGE_VLADMANDIC
        ;;
clean) echo "Cleaning up the mess"
        clean
        ;;
*)	echo "Usage: $0 {all|rocm|pytorch|automatic111|vladmandic|clean}"
        exit 2
        ;;
esac
exit 0
