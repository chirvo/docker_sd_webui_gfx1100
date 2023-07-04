FROM rocm5.6_ubuntu22.04

ENV HIP_VISIBLE_DEVICES=0 PYTORCH_ROCM_ARCH="gfx1100" USE_CUDA=0
# RUN pip install cmake ninja mkl mkl-include
# RUN mkdir -p /srv/src
# WORKDIR /srv/src
# RUN wget -nv https://pub-1cbfe09f357e4aa1a82dc7a43cc443ab.r2.dev/wheel/torch-2.0.1+gitd0d0524-cp310-cp310-linux_x86_64.whl \
  # && pip install ./torch-2.0.1+gitd0d0524-cp310-cp310-linux_x86_64.whl
# RUN wget -nv https://pub-1cbfe09f357e4aa1a82dc7a43cc443ab.r2.dev/wheel/torchvision-0.15.2+6770a25-cp310-cp310-linux_x86_64.whl \
  # && pip install ./torchvision-0.15.2+6770a25-cp310-cp310-linux_x86_64.whl
# WORKDIR /
# RUN rm -r /srv/src
RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.5
CMD "/bin/bash"
