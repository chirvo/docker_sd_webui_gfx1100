FROM localhost/chirvo_sd/pytorch2.0_gfx1100:latest

# Choose one of these repositories by uncommenting them; comment the rest:
#FIXME: Make it work with vladmandic/automatic
#ARG CLONE_REPO=vladmandic/automatic
ARG CLONE_REPO=AUTOMATIC1111/stable-diffusion-webui

WORKDIR /srv
RUN echo Cloning $CLONE_REPO && git clone https://github.com/$CLONE_REPO webui
WORKDIR /srv/webui
RUN git reset --hard 22bcc7be428c94e9408f589966c2040187245d81
RUN git config --global --add safe.directory '*'
RUN pip install -r requirements.txt

# Run the app
EXPOSE 7860/tcp
CMD python3 launch.py --listen
