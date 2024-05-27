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
    --partition A100-40GB \
    --nodes 1 \
    --ntasks 1 \
    --gpus-per-task 0 \
    --cpus-per-task 128 \
    --mem 256G \
    --time 01-00:00
"
JOBNAME=plpi_$(date '+%Y%m%d-%H%M%S')
# SRUN -END-

# SCRIPT -START-
SEED=1
RUN_NAME=tokenize_$(date '+%Y%m%d-%H%M%S')
MODEL_ARGS="
    --model_name_or_path bert-base-uncased \
    --tokenizer_name bert-base-uncased
"
SEQ_LENGTH=512
DATA_ARGS="
    --dataset_name /ns/data/mcrts/OSCAR-2301_en_30M \
    --dataset_config_name en \
    --dataset_dir /ns/data/bert-base-uncased_$SEQ_LENGTH/OSCAR-2301_en_30M \
    --preprocessing_num_workers 128 \
    --max_seq_length $SEQ_LENGTH \
    --overwrite_cache \
    --data_seed $SEED
"

RUN_ARGS="
    --run_name $RUN_NAME
"
# SCRIPT -END-

srun -K \
    --job-name=$JOBNAME \
    $RESOURCES_ARGS \
    $CONTAINER_ARGS \
    /ws/scripts/train_mlm.py \
        $MODEL_ARGS \
        $DATA_ARGS \
        $RUN_ARGS \
        --output_dir /ns/models/$RUN_NAME