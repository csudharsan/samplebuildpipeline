#!/bin/bash

# cinemo_bldscript.sh
# Author: sudharch@cisco.com
#
# The script can be run
# in two ways:-
#
# Dev mode: (USEFUL FOR DEVELOPERS)
#   Eg: ./cinemo_bldscript.sh
#   Running the script without args on dev mode, simply
#   mounts the source code to a container and runs it.
#
#
# Rel mode:( USEFUL FOR Building through jenkins, release public images
#            to dockerhub )
#
#   Eg: ./cinemo_bldscript.sh -l label-1.0.0-001
#



progname=${0##*/}

function usage {
    cat <<EOF
Usage:
    ${progname}
    ${progname} [-l <build_BUILD_LABEL>]
    ${progname} [-l <build_BUILD_LABEL>] [-o <no remove>]
    ${progname} -h

Switches:
   -l <build_BUILD_LABEL>  build BUILD_LABEL. Default: exp-<branch_name>:<$PID>
   -o <no remove>    Dont remove the container on exit. Default: removed
EOF
}


### INIT VARS ###
BUILD_LABEL=
KEEP_CONTAINER=
DOCKER_FILE='Dockerfile'
DOCKER_HUG_REPO_PATH='hub.docker.com/mydocker-hub'
DOCKER_INFRA_TAG=$DOCKER_HUG_REPO_PATH/my-image-1.0.0-001

##################
# MAIN           #
##################

while getopts "hl:o:p:" opt; do

    case $opt in
      l)
	BUILD_LABEL=$OPTARG;
        ;;
      o)
        KEEP_CONTAINER=$OPTARG;
        ;;
      h)
        usage
        exit 1
        ;;
    esac
done



if [ -z "${KEEP_CONTAINER}" ]; then
   CONTAINER_REMOVE="--rm"
else
   CONTAINER_REMOVE=""
fi



# Check to see if we want ports opened

if [ ! -z "${DOCKER_PORTS}" ]; then
   export PORTS=""
   for port in ${DOCKER_PORTS}; do
     echo ${port}
     PORTS="-p ${port} ${PORTS}"
   done
fi


# Check to see if docker infra image exists locally

if [[ "$(docker images -q $DOCKER_INFRA_TAG 2> /dev/null)" == "" ]]; then
   docker pull $DOCKER_INFRA_TAG
fi


DOCKER_START_CMD="docker run -ti ${CONTAINER_REMOVE} ${PORTS} MODE=dev --workdir /opt/cinemoapp -v $(pwd)/src:/opt/cinemoapp --name cinemoapp $DOCKER_INFRA_TAG"


if [ -z $BUILD_LABEL ];then
    echo "Starting cinemoapp docker container ... "
    echo "Run command #./cinemoapp.sh to start cinemoapp app."
    echo ""
    $DOCKER_START_CMD
else
    # Docker build command
    echo "Building new docker image: ${BUILD_LABEL} ..."
    DOCKER_BUILD_CMD="docker build -t $BUILD_LABEL -f ${DOCKER_FILE} ."
    $DOCKER_BUILD_CMD
fi
