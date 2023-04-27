FROM localhost/chirvo_sd/pytorch2.0_gfx1100:latest

# Choose one of these repositories by uncommenting them; comment the rest:
#ARG CLONE_URL=https://github.com/vladmandic/automatic
ARG CLONE_URL=https://github.com/AUTOMATIC1111/stable-diffusion-webui

WORKDIR /srv
RUN echo Cloning $CLONE_URL && git clone $CLONE_URL webui
WORKDIR /srv/webui
RUN git reset --hard 22bcc7be428c94e9408f589966c2040187245d81
RUN git config --global --add safe.directory '*'
RUN pip install -r requirements.txt

# Run the app
EXPOSE 7860/tcp
# RUN python3 launch.py --listen --disable-safe-unpickle &
CMD /bin/bash
