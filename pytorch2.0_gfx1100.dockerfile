FROM localhost/ubuntu22.04_rocm5.5:latest

ENV LC_ALL=C.UTF-8                                                                                                                            
ENV LANG=C.UTF-8                                                                                                                              

WORKDIR /svr
# Activate VENV
RUN python3 -m venv venv
ENV VIRTUAL_ENV=/svr/venv
RUN python3 -m venv $VIRTUAL_ENV
RUN python3 -m pip install --upgrade pip wheel
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Setup src folder & compile dependencies 
ENV HIP_VISIBLE_DEVICES=0
ENV PYTORCH_ROCM_ARCH="gfx1100"
ENV CMAKE_PREFIX_PATH=/svr/venv/
ENV USE_CUDA=0
RUN pip install -y cmake ninja
RUN pip uninstall -y torch torchvision
RUN mkdir -p /svr/src
WORKDIR /svr/src

# Build pytorch
RUN wget https://github.com/pytorch/pytorch/releases/download/v2.0.0/pytorch-v2.0.0.tar.gz
RUN tar -xzvf pytorch-v2.0.0.tar.gz
WORKDIR /svr/src/pytorch-v2.0.0
RUN pip install -r requirements.txt
RUN pip install mkl mkl-include
RUN python3 tools/amd_build/build_amd.py
RUN python3 setup.py install

# Build vision
WORKDIR /svr/src/
RUN wget https://github.com/pytorch/vision/archive/refs/tags/v0.15.1.tar.gz
RUN tar -xzvf v0.15.1.tar.gz
WORKDIR /svr/src/vision-0.15.1
RUN python3 setup.py install

# Cleanup
WORKDIR /svr/src/
RUN rm -r *

CMD "/bin/bash"  
