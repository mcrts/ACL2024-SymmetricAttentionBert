#!/usr/bin/env bash

IMAGE=/netscratch/$USER/enroot/plpi-dev1.0.0.sqsh
MOUNTS=/netscratch/$USER:/netscratch/$USER,/netscratch/$USER:/ns,"`pwd`":/ws
MOUNTS=$MOUNTS,/home/$USER:/root

# Optionally override the plpi python package installed in /opt for custom development purposes.
# additional dependencies will not be installed.
MOUNTS=$MOUNTS,"`pwd`/plpi":/opt/plpi

CONTAINER_ARGS="
    --container-image=$IMAGE \
    --container-mounts=$MOUNTS \
    --container-workdir=/ws
"
RESOURCES_ARGS="
    --partition batch \
    --nodes 1 \
    --ntasks 1 \
    --gpus-per-task 0 \
    --cpus-per-task 32 \
    --mem 128G \
    --time 02:00:00
"

JOBNAME=bash_$(date '+%Y%m%d-%H%M%S')
srun \
    --job-name=$JOBNAME \
    $RESOURCES_ARGS \
    $CONTAINER_ARGS \
    --pty /bin/bash