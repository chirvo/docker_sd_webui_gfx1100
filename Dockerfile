FROM ubuntu/jammy

ENV UBSAN_OPTIONS=print_stacktrace=1
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV ROCMVERSION=5.5
ENV DEB_ROCM_REPO=http://repo.radeon.com/rocm/apt/.apt_5.5/
ENV AMDGPU_NONFREE_DRIVER=https://repo.radeon.com/amdgpu-install/22.40.3/ubuntu/jammy/amdgpu-install_5.4.50403-1_all.deb
RUN set -xe
RUN useradd -rm -d /home/jenkins -s /bin/bash -u 1004 jenkins
RUN apt-get update
RUN apt-get install -y wget gnupg curl
RUN if [ "$ROCMVERSION" != "5.5"]; then wget -qO - http://repo.radeon.com/rocm/rocm.gpg.key | apt-key add -; else sh -c "wget $AMDGPU_NONFREE_DRIVER"  \
	&& apt update  \
	&& apt-get install -y ./$(basename ${AMDGPU_NONFREE_DRIVER})  \
	&& DEBIAN_FRONTEND=noninteractive amdgpu-install -y --usecase=rocm; fi
RUN sh -c "echo deb [arch=amd64] $DEB_ROCM_REPO $(lsb_release -cs) main > /etc/apt/sources.list.d/rocm.list"
RUN sh -c "echo deb http://mirrors.kernel.org/ubuntu $(lsb_release -cs) main universe | tee -a /etc/apt/sources.list"
RUN wget -O - https://repo.radeon.com/rocm/rocm.gpg.key 2> /dev/null | gpg --dearmor -o /etc/apt/trusted.gpg.d/rocm-keyring.gpg
RUN apt-get update  \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated apt-utils build-essential ccache cmake git hip-rocclr jq libelf-dev \
     libncurses5-dev libnuma-dev libpthread-stubs0-dev llvm-amdgpu pkg-config python python3 python-dev python3-dev python3-pip sshpass \
     software-properties-common rocm-dev rocm-device-libs rocm-cmake vim nano zlib1g-dev openssh-server clang-format-10 kmod  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/*
RUN apt purge --auto-remove -y cmake
RUN apt update
RUN apt install -y software-properties-common lsb-release
RUN apt clean all
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor -o /etc/apt/trusted.gpg.d/kitware.gpg
RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
RUN apt install -y kitware-archive-keyring
RUN rm /etc/apt/trusted.gpg.d/kitware.gpg
RUN apt install -y cmake
RUN ln -s /usr/bin/llvm-symbolizer-3.8 /usr/local/bin/llvm-symbolizer
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb
RUN dpkg -i dumb-init_*.deb  \
	&& rm dumb-init_*.deb

ENV PREFIX=/opt/rocm
RUN pip3 install --upgrade pip
RUN pip3 install sqlalchemy==1.4.46
RUN pip3 install pymysql
RUN pip3 install pandas
RUN pip3 install setuptools-rust
RUN pip3 install sshtunnel
RUN groupadd -f render
RUN git clone -b master https://github.com/RadeonOpenCompute/rocm-cmake.git  \
	&& cd rocm-cmake  \
	&& mkdir build  \
	&& cd build  \
	&& cmake ..  \
	&& cmake --build .  \
	&& cmake --build . --target install

WORKDIR /
ENV compiler_version=rc5
ENV compiler_commit=
RUN sh -c "echo compiler version = '$compiler_version'"
RUN sh -c "echo compiler commit = '$compiler_commit'"
RUN if [ "$compiler_version" != "release" ]  \
	&& [ "$compiler_version" !=~ ^"rc" ]  \
	&& [ "$compiler_commit" = "" ]; then git clone -b "$compiler_version" https://github.com/RadeonOpenCompute/llvm-project.git  \
	&& cd llvm-project  \
	&& mkdir build  \
	&& cd build  \
	&& cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=1 -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86" -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" ../llvm  \
	&& make -j 8 ; else echo "using the release compiler"; fi
RUN if [ "$compiler_version" != "release" ]  \
	&& [ "$compiler_version" !=~ ^"rc" ]  \
	&& [ "$compiler_commit" != "" ]; then git clone -b "$compiler_version" https://github.com/RadeonOpenCompute/llvm-project.git  \
	&& cd llvm-project  \
	&& git checkout "$compiler_commit"  \
	&& echo "checking out commit $compiler_commit"  \
	&& mkdir build  \
	&& cd build  \
	&& cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=1 -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86" -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" ../llvm  \
	&& make -j 8 ; else echo "using the release compiler"; fi
RUN apt-get update  \
	&& apt-get full-upgrade -y  \
	&& rm -r /var/lib/apt/lists/*
RUN  rm /etc/apt/sources.list.d/rocm-build.list  \
	&& rm /etc/apt/sources.list.d/amdgpu-build.list  \
	&& rm /etc/apt/sources.list.d/amdgpu.list
VOLUME [/app]

WORKDIR /app
RUN apt-get update  \
	&& apt-get install -y libjpeg-turbo8 libpng16-16 libz3-4 liblcms2-2  \
	&& rm -r /var/lib/apt/lists/*
COPY /venv /venv

ENV VIRTUAL_ENV=/venv PATH=/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN RUN pip install fastai==2.7.12 tensorboard

CMD ["/bin/bash"]
