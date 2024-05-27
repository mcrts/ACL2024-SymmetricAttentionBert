#!/usr/bin/env bash

# SRUN -START-
IMAGE=/netscratch/$USER/enroot/plpi-dev1.0.0.sqsh
MOUNTS=/netscratch/$USER:/netscratch/$USER,/netscratch/$USER:/ns,"`pwd`":/ws
MOUNTS=$MOUNTS,/home/$USER:/root
MOUNTS=$MOUNTS,"`pwd`/plpi":/opt/plpi

CONTAINER_ARGS="
    --container-image=$IMAGE \
    --container-mounts=$MOUNTS \
    --container-workdir=/ws
"
RESOURCES_ARGS="
    --partition A100-80GB \
    --nodes 1 \
    --ntasks 1 \
    --gpus-per-task 0 \
    --cpus-per-task 128 \
    --mem 128G \
    --time 01-00:00
"
JOBNAME=plpi_$(date '+%Y%m%d-%H%M%S')
# SRUN -END-

srun \
    --job-name=$JOBNAME \
    $RESOURCES_ARGS \
    $CONTAINER_ARGS \
    /ws/data/oscar_split.py \
        --dataset_path /ns/data/mcrts/OSCAR-2301 \
        --dataset_conf en \
        --max_sample_size 40000000 \
        --validation_size 1000 \
        --num_proc 128 \
        --dst /ns/data/mcrts/OSCAR-2301_en_40M