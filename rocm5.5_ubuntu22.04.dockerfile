FROM ubuntu:jammy

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y dist-upgrade
RUN apt install -y wget gnupg apt-utils software-properties-common build-essential
RUN wget https://apt.kitware.com/keys/kitware-archive-latest.asc \
    && gpg --batch -o /etc/apt/trusted.gpg.d/kitware.gpg --dearmor ./kitware-archive-latest.asc \
    && rm ./kitware-archive-latest.asc
RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ jammy main"
RUN apt install -y dumb-init ccache cmake git jq sshpass openssh-server kmod pkg-config \
    libelf-dev libncurses5-dev libz3-4 liblcms2-2 libnuma-dev libpthread-stubs0-dev zlib1g-dev \
    python3-dev python3-venv python3-pip
RUN wget https://repo.radeon.com/amdgpu-install/22.40.3/ubuntu/jammy/amdgpu-install_5.4.50403-1_all.deb \
    && apt install -y ./amdgpu-install_5.4.50403-1_all.deb \
    && amdgpu-install -y --no-dkms --usecase=rocm \
    && rm ./amdgpu-install_5.4.50403-1_all.deb
RUN sh -c "echo deb [arch=amd64] http://repo.radeon.com/rocm/apt/.apt_5.5/ jammy main > /etc/apt/sources.list.d/rocm.list"
RUN apt update && apt -y dist-upgrade
RUN apt install -y hip-rocclr llvm-amdgpu \
    rocm-dev rocm-device-libs rocm-cmake rocrand-dev rocblas-dev miopen-hip-dev hipfft-dev
RUN apt install -y hipsparse-dev rocprim-dev hipcub-dev rocthrust-dev rccl-dev

CMD "/bin/bash"
