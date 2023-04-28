FROM localhost/chirvo_sd/rocm5.5_ubuntu22.04

ENV LC_ALL=C.UTF-8                                                                                                                            
ENV LANG=C.UTF-8                                                                                                                              

WORKDIR /srv
# Activate VENV
# RUN python3 -m venv venv
# ENV VIRTUAL_ENV=/srv/venv
# RUN python3 -m venv $VIRTUAL_ENV
# RUN python3 -m pip install --upgrade pip wheel
# ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Setup src folder & install dependencies 
ENV HIP_VISIBLE_DEVICES=0
ENV PYTORCH_ROCM_ARCH="gfx1100"
# ENV CMAKE_PREFIX_PATH=/srv/venv/
ENV USE_CUDA=0
RUN pip install cmake ninja mkl mkl-include
RUN mkdir -p /srv/src
WORKDIR /srv/src
RUN wget -nv https://github.com/pytorch/pytorch/releases/download/v2.0.0/pytorch-v2.0.0.tar.gz
RUN echo "Decompressing pytorch-v2.0.0.tar.gz" && tar zxf pytorch-v2.0.0.tar.gz
RUN wget -nv https://github.com/pytorch/vision/archive/refs/tags/v0.15.1.tar.gz
RUN echo "Decompressing v0.15.1.tar.gz" && tar zxf v0.15.1.tar.gz

# Build pytorch, vision
WORKDIR /srv/src/pytorch-v2.0.0
RUN pip install -r requirements.txt
RUN python3 tools/amd_build/build_amd.py
RUN python3 setup.py install
WORKDIR /srv/src/vision-0.15.1
RUN python3 setup.py install

# Cleanup
WORKDIR /
RUN rm -r /srv/src

CMD "/bin/bash"  
