FROM localhost/chirvo_sd/pytorch2.0_gfx1100:latest

# ENV LC_ALL=C.UTF-8                                                                                                                            
# ENV LANG=C.UTF-8                                                                                                                              
# ENV VIRTUAL_ENV=/srv/venv

# Choose one of these repositories by uncommenting them; comment the rest:
#ARG CLONE_URL=https://github.com/vladmandic/automatic
ARG CLONE_URL=https://github.com/AUTOMATIC1111/stable-diffusion-webui

WORKDIR /srv
RUN echo Cloning $CLONE_URL && git clone $CLONE_URL webui
WORKDIR /srv/webui
RUN git config --global --add safe.directory '*'
RUN pip install -r requirements.txt
RUN mkdir -p models/VAE-approx
WORKDIR /srv/webui/models/VAE-approx
RUN wget https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/models/VAE-approx/model.pt
WORKDIR /srv/webui


# Run the app
EXPOSE 7860/tcp
# RUN python3 launch.py --listen --disable-safe-unpickle &
CMD /bin/bash
