# Stable-Diffusion WebUI for AMD RADEON 7900XTX (gfx1100) 
A set of Dockerfiles for images that support Standard Diffusion on AMD 7900XTX Cards (gfx1100)

## TL;DR
- `git clone` this repo
- `cd` into it
- Build the images with `./build.sh all`
- _wait a lot of time..._
- Run it: `./run.sh`
- Open it in your browser: http://localhost:7860/


## Software these images are based/built on

- Ubuntu 22.04
- ROCm 5.5 RC
- Python 3.10
- Pytorch 2.0.0a0 (compiled from sources)
- torchvision 0.15 (compiled from sources)
- AUTOMATIC1111/stable-diffusion-webui

## How to use

- Install podman, and podman-compose
```bash
$ sudo apt install podman
```
```bash
$ pip3 install podman-compose
```
  > **_Note:_** You can use `docker`, and `docker-compose` instead. However, the use of `podman` is recommended since it's way so much easier since you don't deal with permissions, groups, etc. If you still want to go the docker way, you may have to adjust these files to suit your needs.

- Clone this repository
```bash
$ git clone https://github.com/bigchirv/docker_sd_webui_gfx1100.git
```
- Build the images
```bash
$ cd docker_sd_webui_gfx1100
./build.sh all
```
>**_Note:_** This process can take a long, long time, since we are building software from scratch. So, sit back and relax. Or go watch a movie. Or walk your dog out. Or vacuum the carpet. You get the gist.

- Verify that your images are created
```bash
$ podman images
REPOSITORY                                          TAG         IMAGE ID      CREATED       SIZE
localhost/stable_diffusion_automatic1111            latest      ed93014a7725  4 hours ago   26.1 GB
localhost/pytorch2.0_gfx1100                        latest      cd7a75ca8c84  4 hours ago   24.6 GB
localhost/rocm5.5_ubuntu22.04                       latest      6c2e56614f6b  5 hours ago   16.9 GB
docker.io/library/ubuntu                            jammy       08d22c0ceb15  7 weeks ago   80.3 MB
```

## Other similar work
- Alik Aslanyan's GitHub Gist: https://gist.github.com/In-line/c1225f05d5164a4be9b39de68e99ee2b
