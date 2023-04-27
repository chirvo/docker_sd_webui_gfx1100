FROM localhost/chirvo_sd/pytorch2.0_gfx1100:latest

ARG CLONE_REPO=vladmandic/automatic
WORKDIR /srv
RUN echo Cloning $CLONE_REPO && git clone https://github.com/$CLONE_REPO webui
WORKDIR /srv/webui
RUN git config --global --add safe.directory '*'
RUN pip install -r requirements.txt

# Run the app
ENV TORCH_COMMAND=none
ENV XFORMERS_PACKAGE=none
EXPOSE 7860/tcp
CMD python3 launch.py --listen --skip-requirements
