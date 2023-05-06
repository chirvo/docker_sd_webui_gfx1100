FROM rocm5.5_ubuntu22.04

ENV HIP_VISIBLE_DEVICES=0 PYTORCH_ROCM_ARCH="gfx1100" USE_CUDA=0
RUN mkdir -p /srv/src
RUN pip install cmake ninja mkl mkl-include
WORKDIR /srv/src
RUN wget -nv https://github.com/pytorch/pytorch/releases/download/v2.0.0/pytorch-v2.0.0.tar.gz \
    && tar zxf pytorch-v2.0.0.tar.gz \
    && cd pytorch-v2.0.0 \
    && sh -c 'echo 2.0.0 > version.txt' \
    && pip install -r requirements.txt \
    && python3 tools/amd_build/build_amd.py \
    && python3 setup.py install \
    && cd ..
RUN wget -nv https://github.com/pytorch/vision/archive/refs/tags/v0.15.1.tar.gz \
    && tar zxf v0.15.1.tar.gz \
    && cd vision-0.15.1 \
    && python3 setup.py install \
    && cd ..

WORKDIR /
# RUN rm -r /srv/src

CMD "/bin/bash"  
