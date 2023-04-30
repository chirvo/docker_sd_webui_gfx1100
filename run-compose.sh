#!/bin/bash
# You can change COMPOSE_BIN to docker if you like
COMPOSE_BIN=/usr/bin/podman-compose
#Add to the list below any other directory you want to export
SUBDIRS="embeddings extensions models outputs repositories"
# You can change the tcp port
PORT=7860

###################
# Here be dragons
#
run () {
  # $1: BASEDIR
  # $3: GIT_CLONE

COMPOSE_YAML=$(cat << EOF
services:
  webui:
    build:
      context: .
      dockerfile: ./dockerfiles/stable_diffusion_automatic1111.dockerfile
    ports:
      - "$PORT:7860"
    volumes:
      - ./webui:/srv/webui
__STUB_VOLUMES__
    devices:
      - '/dev/kfd:/dev/kfd'
      - '/dev/dri:/dev/dri'
    security_opt:
      - seccomp:unconfined
    group_add:
      - __STUB_GROUP__
EOF
)
  # Let's clone the app repo
  CONFIG_FILE="automatic1111.config.sh"
  source $CONFIG_FILE

  COMPOSE_YAML="$(echo "$COMPOSE_YAML" | sed -e 's/__STUB_GROUP__/keep-groups/')"
  if [ "$COMPOSE_BIN" == "/usr/bin/docker" ]; then
    COMPOSE_YAML="$(echo "$COMPOSE_YAML" | sed -e 's/__STUB_GROUP__/video/')"
  fi

  if [ "$2" == "no_git_clone" ]; then
    # We won't clone
    # Prepare sub directories
    for VOLUME in "${VOLUMES[@]}"
    do
      VOLNAME=${VOLUME%%:*}
      MOUNTPOINT=${VOLUME#*:}
      if [ ! -d "$VOLNAME" ]; then
        echo "$VOLNAME does not exist. Creating it."
        mkdir -p "$VOLNAME"
      fi

      # Little quirk to avoid a possible error
      if [ "$MOUNTPOINT" == "/srv/webui/models" ] && [ ! -f "$VOLNAME/VAE-approx/model.pt" ]; then
        OLDPWD=$(pwd)
        mkdir -p $VOLNAME/VAE-approx
        cd $VOLNAME/VAE-approx
        wget https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/models/VAE-approx/model.pt
        cd -
      fi

      ALL_VOLUMES=$([ "$ALL_VOLUMES" == "" ] || echo "$ALL_VOLUMES"; echo "      - $VOLUME");
      CONTAINER_OPTIONS="$CONTAINER_OPTIONS -v ./$1/$SUBDIR:/srv/webui/$SUBDIR"
    done
    COMPOSE_YAML=$(echo "$COMPOSE_YAML" | sed -e "s/__STUB_VOLUMES__/$CONTAINER_OPTIONS/")

  echo "$COMPOSE_YAML"
  exit

  else
    # Let's clone the app repo
    REPO=AUTOMATIC1111/stable-diffusion-webui
    git clone "https://github.com/$REPO.git" $1
    cd $1
    git checkout dev
    cd ..
  fi

  COMMAND="$COMPOSE_BIN run $CONTAINER_OPTIONS $2"

  cat << EOF
#
#####################################################################
Compose YAML:
$COMPOSE_YAML
#####################################################################
#Command:
$COMMAND
#####################################################################
#
EOF

  #run the command
  exit
  $COMMAND
}

case "$1" in
# $1:
# $2: Options
  --help)	echo "Usage: $0 {--help|--no-git-clone}"
    cat << EOF

    Running this script with will run the "automatic1111" container.
    The container has to be built previously before running this script.

EOF
  ;;
  *)	echo "Running container"
    [ "$1" == "--no-git-clone" ] || [ "$2" == "--no-git-clone" ] && CLONE="no_git_clone"
    run $CLONE
  ;;
esac
exit 0

