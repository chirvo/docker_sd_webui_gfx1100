FROM localhost/chirvo_sd/pytorch2.0_gfx1100:latest

ENV LC_ALL=C.UTF-8                                                                                                                            
ENV LANG=C.UTF-8                                                                                                                              
ENV VIRTUAL_ENV=/svr/venv

# Choose one of these repositories by uncommenting them; comment the rest:
#ARG CLONE_URL=https://github.com/vladmandic/automatic
ARG CLONE_URL=https://github.com/AUTOMATIC1111/stable-diffusion-webui

WORKDIR /svr
RUN echo Cloning $CLONE_URL && git clone $CLONE_URL webui
WORKDIR /svr/webui
RUN git config --global --add safe.directory '*'

# Remove torch from requirements.txt, it was compiled already in the base container
# RUN sed '/torch/d' requirements.txt
RUN pip install -r requirements.txt


# Run the app
EXPOSE 7860/tcp
CMD python3 launch.py --listen --disable-safe-unpickle 
