#!/bin/bash

#CONTAINER_BIN=/usr/bin/docker
CONTAINER_BIN=/usr/bin/podman
IMAGE_ROCM=rocm5.5_ubuntu22.04
IMAGE_PYTORCH=pytorch2.0_gfx1100
IMAGE_AUTOMATIC1111=automatic1111

build_image () {
	$CONTAINER_BIN image build -f ./dockerfiles/${1}.dockerfile -t ${1}:latest
}

clean () {
  for IMAGE in $IMAGE_AUTOMATIC1111 $IMAGE_PYTORCH $IMAGE_ROCM
	do
	echo -n "Removing '$IMAGE': "
		$CONTAINER_BIN image rm $IMAGE
		[ $? -eq 0 ] && echo "done." || "error." 
	done
}

case "$1" in
all) echo "Building all"
      build_image $IMAGE_ROCM
      build_image $IMAGE_PYTORCH
      build_image $IMAGE_AUTOMATIC1111
	;;
rocm)	echo "Building $IMAGE_ROCM"
      build_image $IMAGE_ROCM
        ;;
pytorch)	echo "Building $IMAGE_PYTORCH"
      build_image $IMAGE_PYTORCH
        ;;
a1111)	echo "Building $IMAGE_AUTOMATIC1111"
      build_image $IMAGE_AUTOMATIC1111
        ;;
clean) echo "Cleaning up the mess"
        clean
        ;;
--help|*)	echo "Usage: $0 {all|rocm|pytorch|a1111|clean}"
        exit 2
        ;;
esac
exit 0
