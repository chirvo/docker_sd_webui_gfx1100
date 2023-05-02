FROM rocm5.5_ubuntu22.04

ENV HIP_VISIBLE_DEVICES=0 PYTORCH_ROCM_ARCH="gfx1100" USE_CUDA=0
RUN mkdir -p /srv/src
RUN pip install cmake ninja mkl mkl-include
WORKDIR /srv/src
RUN wget -nv https://github.com/pytorch/pytorch/releases/download/v2.0.0/pytorch-v2.0.0.tar.gz \
    && echo "Decompressing pytorch-v2.0.0.tar.gz" \
    && tar zxf pytorch-v2.0.0.tar.gz
RUN wget -nv https://github.com/pytorch/vision/archive/refs/tags/v0.15.1.tar.gz \
    && echo "Decompressing v0.15.1.tar.gz" \
    && tar zxf v0.15.1.tar.gz

# Build pytorch, vision
WORKDIR /srv/src/pytorch-v2.0.0
RUN sh -c 'echo 2.0.0 > version.txt' \
    && pip install -r requirements.txt \
    && python3 tools/amd_build/build_amd.py \
    && python3 setup.py install
WORKDIR /srv/src/vision-0.15.1
RUN python3 setup.py install

# Cleanup
WORKDIR /
RUN rm -r /srv/src

CMD "/bin/bash"  
