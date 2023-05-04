FROM pytorch2.0_gfx1100:latest

ARG CLONE_REPO=AUTOMATIC1111/stable-diffusion-webui
WORKDIR /srv
RUN echo Cloning $CLONE_REPO && git clone https://github.com/$CLONE_REPO webui
WORKDIR /srv/webui
RUN git config --global --add safe.directory '*' \
    && pip install -r requirements.txt

# Run the app
EXPOSE 7860/tcp
# CMD python3 launch.py --listen
CMD "/bin/bash"
