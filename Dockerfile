FROM ubuntu:jammy

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

CMD ["/bin/bash"]

ARG DEBIAN_FRONTEND=noninteractive
RUN set -xe
RUN useradd -rm -d /home/jenkins -s /bin/bash -u 1004 jenkins
RUN apt update \
    && apt -y dist-upgrade
RUN apt install -y wget gnupg
RUN wget https://repo.radeon.com/amdgpu-install/22.40.3/ubuntu/jammy/amdgpu-install_5.4.50403-1_all.deb \
    && apt install -y ./amdgpu-install_5.4.50403-1_all.deb \
    && amdgpu-install -y --no-dkms --usecase=rocm
RUN sh -c "echo deb [arch=amd64] http://repo.radeon.com/rocm/apt/.apt_5.5/ jammy main > /etc/apt/sources.list.d/rocm.list"
RUN sh -c "echo deb http://mirrors.kernel.org/ubuntu jammy main universe >> /etc/apt/sources.list"
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb \
    && apt install -y ./dumb-init_1.2.5_amd64.deb \
    && rm ./dumb-init_1.2.5_amd64.deb
RUN apt update && apt -y dist-upgrade
RUN apt install -y --allow-unauthenticated apt-utils build-essential ccache cmake git hip-rocclr jq libelf-dev libncurses5-dev \
    libjpeg-turbo8 libpng16-16 libz3-4 liblcms2-2 libnuma-dev libpthread-stubs0-dev llvm-amdgpu pkg-config python3 python3-dev \
    python3-pip sshpass software-properties-common rocm-dev rocm-device-libs rocm-cmake vim nano zlib1g-dev openssh-server kmod
RUN apt purge -y --auto-remove cmake
RUN wget https://apt.kitware.com/keys/kitware-archive-latest.asc \
    && gpg --batch -o /etc/apt/trusted.gpg.d/kitware.gpg --dearmor ./kitware-archive-latest.asc \
    && rm ./kitware-archive-latest.asc
RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ jammy main"
RUN apt install -y kitware-archive-keyring
RUN apt install -y cmake
RUN ln -s /usr/bin/llvm-symbolizer-3.8 /usr/local/bin/llvm-symbolizer

ARG PREFIX=/opt/rocm
ARG UBSAN_OPTIONS=print_stacktrace=1
RUN pip3 install --upgrade pip
RUN pip3 install sqlalchemy==1.4.46 pymysql pandas setuptools-rust sshtunnel fastai==2.7.12 tensorboard
RUN groupadd -f render
RUN git clone -b master https://github.com/RadeonOpenCompute/rocm-cmake.git  \
    && cd rocm-cmake  \
    && mkdir build  \
    && cd build  \
    && cmake ..  \
    && cmake --build .  \
    && cmake --build . --target install

WORKDIR /
ARG compiler_version=rc5
ARG compiler_commit=
RUN sh -c "echo compiler version = '$compiler_version'"
RUN sh -c "echo compiler commit = '$compiler_commit'"
RUN if [ "$compiler_version" != "release" ] && [ "$compiler_version" !=~ ^"rc" ] && [ "$compiler_commit" = "" ]; then \
    git clone -b "$compiler_version" https://github.com/RadeonOpenCompute/llvm-project.git  \
    && cd llvm-project  \
    && mkdir build  \
    && cd build  \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=1 -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86" -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" ../llvm  \
    && sh -c "make -j $(nproc)"; \
    else echo "using the release compiler"; fi
RUN if [ "$compiler_version" != "release" ] && [ "$compiler_version" !=~ ^"rc" ] && [ "$compiler_commit" != "" ]; then \
    git clone -b "$compiler_version" https://github.com/RadeonOpenCompute/llvm-project.git  \
    && cd llvm-project  \
    && git checkout "$compiler_commit"  \
    && echo "checking out commit $compiler_commit"  \
    && mkdir build  \
    && cd build  \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=1 -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86" -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" ../llvm  \
    && sh -c "make -j $(nproc)"; \
    else echo "using the release compiler"; fi
RUN apt update && apt -y dist-upgrade && apt -y --purge autoremove && apt clean all
RUN rm -r /var/lib/apt/lists/*

VOLUME [/app]
WORKDIR /app
ENV VIRTUAL_ENV=/venv PATH=/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
