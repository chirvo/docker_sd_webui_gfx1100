FROM ubuntu:jammy

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y dist-upgrade \
    && apt install -y apt-utils gnupg software-properties-common wget
RUN wget https://apt.kitware.com/keys/kitware-archive-latest.asc \
    && gpg --batch -o /etc/apt/trusted.gpg.d/kitware.gpg --dearmor ./kitware-archive-latest.asc \
    && rm ./kitware-archive-latest.asc \
    && apt-add-repository "deb https://apt.kitware.com/ubuntu/ jammy main"
RUN wget https://repo.radeon.com/amdgpu-install/5.5/ubuntu/jammy/amdgpu-install_5.5.50500-1_all.deb \
    && apt install -y ./amdgpu-install_5.5.50500-1_all.deb \
    && amdgpu-install -y --no-dkms --usecase=rocm \
    && rm ./amdgpu-install_5.5.50500-1_all.deb
RUN apt update && apt -y dist-upgrade && apt install -y \
    ccache cmake dumb-init ffmpeg git hipcub-dev hipfft-dev hip-rocclr hipsparse-dev jq \
    libjpeg-dev liblcms2-2 libncurses5-dev libnuma-dev libpng-dev libz3-4 \
    libavutil-dev libavcodec-dev libavformat-dev libavdevice-dev libavfilter-dev libswscale-dev \
    libswresample-dev libswresample-dev libpostproc-dev \
    libtcmalloc-minimal4 \
    llvm-amdgpu miopen-hip-dev pkg-config python3-dev python3-pip python3-venv rccl-dev rocblas-dev \
    rocprim-dev rocrand-dev rocthrust-dev \
    && apt clean

CMD "/bin/bash"
