#!/bin/bash
# You can change COMPOSE_BIN to docker if you like
COMPOSE_BIN=podman-compose
#Add to the list below any other directory you want to export
SUBDIRS="embeddings extensions models outputs repositories"
# You can change the tcp port
PORT=7860

###################
# Here be dragons
#
run () {
  # $1: GIT_CLONE

COMPOSE_YAML=$(cat << EOF
services:
  webui:
    build:
      context: .
      dockerfile: ./dockerfiles/automatic1111.dockerfile
    ports:
      - "$PORT:7860"
    devices:
      - '/dev/kfd:/dev/kfd'
      - '/dev/dri:/dev/dri'
    security_opt:
      - seccomp:unconfined
    group_add:
      - __STUB_GROUP__
    volumes:
      - ./webui:/srv/webui
EOF
)
  CONFIG_FILE="config/automatic1111.config.sh"
  source $CONFIG_FILE

  COMPOSE_YAML="$(echo "$COMPOSE_YAML" | sed -e 's/__STUB_GROUP__/keep-groups/')"
  if [ "$COMPOSE_BIN" == "/usr/bin/docker" ]; then
    COMPOSE_YAML="$(echo "$COMPOSE_YAML" | sed -e 's/__STUB_GROUP__/video/')"
  fi

  if [ "$1" == "git_clone" ]; then
    # Let's clone the app repo
    git clone "https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" webui
  fi
  # Prepare sub directories
  for VOLUME in "${VOLUMES[@]}"
  do
    VOLNAME=${VOLUME%%:*}
    MOUNTPOINT=${VOLUME#*:}
    echo "$VOLNAME -> $MOUNTPOINT"
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
  done

  echo "$COMPOSE_YAML" > ./compose.yml
  echo "$ALL_VOLUMES" >> ./compose.yml
  COMPOSE_YAML="$(cat ./compose.yml)"

  COMMAND="$COMPOSE_BIN up $COMPOSE_OPTIONS"

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
  $COMMAND
  exit
}

case "$1" in
# $1:
# $2: Options
  --help)	echo "Usage: $0 {--help|--git-clone}"
    cat << EOF

    Running this script with will run the "automatic1111" container.
    The container has to be built previously before running this script.

EOF
  ;;
  *)	echo "Running container"
    [ "$1" == "--git-clone" ] || [ "$2" == "--git-clone" ] && CLONE="git_clone"
    run $CLONE
  ;;
esac
exit 0

