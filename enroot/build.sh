#!/usr/bin/env bash
COMMIT=$1

CONTAINER_IMAGE=/netscratch/enroot/nvcr.io_nvidia_pytorch_23.05-py3.sqsh
CONTAINER_SAVE=/netscratch/$USER/enroot/plpi-$COMMIT.sqsh
MOUNTS="`pwd`":/ws,/home/$USER/tmp:/tmp

PLPI_REPO=git@github.com:mcrts/plpi.git
git clone --depth 1 --branch $COMMIT --single-branch $PLPI_REPO /home/$USER/tmp/plpirepo
cp -r /home/$USER/tmp/plpirepo/plpi /home/$USER/tmp/plpi

CONTAINER_ARGS="
    --container-image=$CONTAINER_IMAGE \
    --container-save=$CONTAINER_SAVE \
    --container-mounts=$MOUNTS
"

RESOURCES_ARGS="
    --partition V100-16GB \
    --mem=80G
"

INSTALL_FILE=./install.sh
if [ -f "$INSTALL_FILE" ];  then
    echo "$INSTALL_FILE exists."
else 
    echo "$INSTALL_FILE does not exist."
    echo "It seems you are not in the installation folder" 1>&2
    exit 1
fi

JOBNAME="build_PLPI_$(date '+%Y%m%d-%H%M%S')"
srun -K \
    --job-name=$JOBNAME \
    $RESOURCES_ARGS \
    $CONTAINER_ARGS \
    /ws/install.sh

rm -rf /home/$USER/tmp/plpirepo