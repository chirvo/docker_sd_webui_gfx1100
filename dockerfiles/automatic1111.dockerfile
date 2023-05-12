FROM pytorch2.0_gfx1100:latest

WORKDIR /srv
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui webui
WORKDIR /srv/webui
RUN git config --global --add safe.directory '*'
RUN sh -c "cat requirements.txt | grep -vw torch > /tmp/requirements.txt && mv /tmp/requirements.txt ./requirements.txt"
EXPOSE 7860/tcp
CMD python3 launch.py --listen
