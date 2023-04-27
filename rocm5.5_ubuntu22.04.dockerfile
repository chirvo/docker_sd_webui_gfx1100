FROM ubuntu:jammy

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt -y dist-upgrade
RUN apt install -y wget gnupg
RUN wget https://repo.radeon.com/amdgpu-install/22.40.3/ubuntu/jammy/amdgpu-install_5.4.50403-1_all.deb \
    && apt install -y ./amdgpu-install_5.4.50403-1_all.deb \
    && amdgpu-install -y --no-dkms --usecase=rocm \
    && rm ./amdgpu-install_5.4.50403-1_all.deb
RUN sh -c "echo deb [arch=amd64] http://repo.radeon.com/rocm/apt/.apt_5.5/ jammy main > /etc/apt/sources.list.d/rocm.list"
RUN sh -c "echo deb http://mirrors.kernel.org/ubuntu jammy main universe >> /etc/apt/sources.list"
RUN apt update && apt -y dist-upgrade
RUN apt install -y --allow-unauthenticated apt-utils build-essential dumb-init ccache cmake git hip-rocclr jq libelf-dev \
    libncurses5-dev libjpeg-turbo8 libpng16-16 libz3-4 liblcms2-2 libnuma-dev libpthread-stubs0-dev llvm-amdgpu pkg-config \
    python3 python3-dev python3-venv python3-pip sshpass software-properties-common rocm-dev rocm-device-libs rocm-cmake \
    vim nano zlib1g-dev openssh-server kmod
RUN apt purge -y --auto-remove cmake
RUN wget https://apt.kitware.com/keys/kitware-archive-latest.asc \
    && gpg --batch -o /etc/apt/trusted.gpg.d/kitware.gpg --dearmor ./kitware-archive-latest.asc \
    && rm ./kitware-archive-latest.asc
RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ jammy main"
RUN apt install -y cmake
RUN ln -s /usr/bin/llvm-symbolizer-3.8 /usr/local/bin/llvm-symbolizer

CMD "/bin/bash"
