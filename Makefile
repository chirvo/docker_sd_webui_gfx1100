all: rocm55_ub2204 pytorch2_gfx1100 sd_webui

rocm55_ub2204:
	podman image build -f ubuntu22.04_rocm5.5.dockerfile -t ubuntu22.04_rocm5.5:latest

pytorch2_gfx1100:
	podman image build -f pytorch2.0_gfx1100.dockerfile -t pytorch2.0_gfx1100:latest

sd_webui:
	podman image build -f stable_diffusion_webui.dockerfile -t stabe_diffusion_webui:latest

clean:
	for IMG in stabe_diffusion_webui:latest pytorch2.0_gfx1100:latest ubuntu22.04_rocm5.5:latest;
	do
	echo -n "Removing '${IMG}': "
		podman image rm $IMG
		[ $? =eq 0 ] && echo "done." || "error." 
	done

