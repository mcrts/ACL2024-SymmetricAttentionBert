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
    --partition batch \
    --nodes 1 \
    --ntasks 1 \
    --gpus-per-task 0 \
    --cpus-per-task 32 \
    --mem 128G \
    --time 03-00:00
"
JOBNAME=plpi_$(date '+%Y%m%d-%H%M%S')
# SRUN -END-

srun \
    --job-name=$JOBNAME \
    $RESOURCES_ARGS \
    $CONTAINER_ARGS \
    --pty /bin/bash



find ~/ns/data/oscar-corpus/OSCAR-2301/en_meta -name "*.jsonl.zst" \
    | awk '{src=$0; sub(/oscar-corpus/, "mcrts", $0); print src " " $0}' \
    | parallel -j4 --colsep " " --progress \
    "python data/oscar_filter.py {1} {2}"