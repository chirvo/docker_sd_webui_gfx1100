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
ENV CODEFORMER_COMMIT_HASH="f730388013967c7ae468a86d39dbede31bdb4360"
EXPOSE 7860/tcp
#CMD python3 launch.py --listen --skip-requirements
CMD /bin/bash
