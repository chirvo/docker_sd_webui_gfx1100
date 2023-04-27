PODMAN_BIN = podman
IMAGE_ROCM = rocm5.5_ubuntu22.04
IMAGE_PYTORCH = pytorch2.0_gfx1100
IMAGE_WEBUI = stabe_diffusion_webui
all: rocm55_ub2204 pytorch2_gfx1100 sd_webui

rocm55_ub2204:
	IMAGE_NAME = ${IMAGE_ROCM}
	build_image

pytorch2_gfx1100:
	IMAGE_NAME = ${IMAGE_ROCM}
	build_image

sd_webui:
	IMAGE_NAME = ${IMAGE_ROCM}
	build_image

build_image:
	echo ${PODMAN_BIN} image build -f ${IMAGE_NAME}.dockerfile -t chirvo_sd/${IMAGE_NAME}:latest


clean:
	for IMG in (podman images | grep 'chirvo_sd' | awk '{print $3}' | grep -v IMAGE )
	do
	echo -n "Removing '${IMG}': "
		echo ${PODMAN_BIN} image rm ${IMG} 2>&1 > /dev/null 
		[ $? -eq 0 ] && echo "done." || "error." 
	done

