#!/bin/bash

PODMAN_BIN=/usr/bin/podman
IMAGE_ROCM=rocm5.5_ubuntu22.04
IMAGE_PYTORCH=pytorch2.0_gfx1100
IMAGE_WEBUI=stabe_diffusion_webui

build_image () {
	echo ${PODMAN_BIN} image build -f ${$1}.dockerfile -t chirvo_sd/${$1}:latest
}


pytorch : | _setimage_pytorch build_image 

webui : | _setimage_webui build_image 
	
all : rocm pytorch webui

clean () {
	for IMG in {${PODMAN} images | grep 'chirvo_sd' | awk '{print $3}' | grep -v IMAGE }
	do
	echo -n "Removing '${IMG}': "
		echo ${PODMAN_BIN} image rm ${IMG} 2>&1 > /dev/null 
		[ $? -eq 0 ] && echo "done." || "error." 
	done
}

case "$1" in
all) echo "Building all"
      build_image IMAGE_ROCM
      build_image IMAGE_PYTORCH
      build_image IMAGE_WEBUI
	;;
rocm)	echo "Building ${IMAGE_ROCM}"
      build_image IMAGE_ROCM
        ;;
pytorch)	echo "Building ${IMAGE_PYTORCH}"
      build_image IMAGE_PYTORCH
        ;;
webui)	echo "Building ${IMAGE_WEBUI}"
      build_image IMAGE_WEBUI
        ;;
clean) echo "Cleaning the mess"
        clean
        ;;
*)	echo "Usage: $0 {all|rocm|pytorch|webui|clean}"
        exit 2
        ;;
esac
exit 0
