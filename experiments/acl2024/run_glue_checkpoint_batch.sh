#!/usr/bin/env bash
#SBATCH --array=0-8%2
#SBATCH --partition V100-16GB
#SBATCH --nodes 1
#SBATCH --gpus 1
#SBATCH --cpus-per-gpu 4
#SBATCH --mem 128G
#SBATCH --time 01-00:00

MODEL=$1
MODELNAME=$(basename ${MODEL})
CHECKPOINT=$2
MODELPATH=$MODEL/checkpoint-$CHECKPOINT
TASKS=(cola mnli mrpc qnli qqp rte sst2 stsb wnli)
TASK=${TASKS[$SLURM_ARRAY_TASK_ID]}

JOBNAME=plpi_${MODELNAME}-ckpt${CHECKPOINT}_${TASK}_$(date '+%Y%m%d-%H%M%S')

# SRUN -START-
IMAGE=/netscratch/$USER/enroot/plpi-1.0.1.sqsh
MOUNTS=/netscratch/$USER:/netscratch/$USER,/netscratch/$USER:/ns,"`pwd`":/ws
MOUNTS=$MOUNTS,/home/$USER:/root
MOUNTS=$MOUNTS,"`pwd`/plpi":/opt/plpi

CONTAINER_ARGS="
    --container-image=$IMAGE \
    --container-mounts=$MOUNTS \
    --container-workdir=/ws
"
# SRUN -END-

# SCRIPT -START-
WANDB_PROJECT=ACL2024-GLUE-CHECKPOINT-dev
WANDB_TAGS=glue,$TASK,$MODEL
EXPORT_ARGS="'WANDB_PROJECT=$WANDB_PROJECT','WANDB_TAGS=$WANDB_TAGS'"
RUN_NAME=${MODELNAME}-ckpt${CHECKPOINT}_${TASK}_$(date '+%Y%m%d-%H%M%S')

SEQ_LENGTH=128
TASK_ARGS="
    --model_name_or_path $MODELPATH \
    --max_seq_length $SEQ_LENGTH \
    --task_name $TASK
"

SEED=1
TRAINING_ARGS="
    --do_train \
    --do_eval \
    --seed $SEED \

    --num_train_epochs 5 \
    --learning_rate 1e-5 \
    --warmup_ratio 0.1 \
    --per_device_train_batch_size 16 \
    --per_device_eval_batch_size 128 \

    --logging_strategy steps \
    --logging_steps 0.001 \
    --evaluation_strategy steps \
    --eval_steps 0.005 \
    --save_strategy epoch \
    --save_total_limit 1 \
    --save_only_model \

    --fp16 \
    --torch_compile \
    --optim adamw_apex_fused
"
RUN_ARGS="
    --run_name $RUN_NAME \
    --report_to wandb
"
# SCRIPT -END-

srun \
    --job-name=$JOBNAME \
    $CONTAINER_ARGS \
    --export=$EXPORT_ARGS \
    /ws/scripts/run_glue.py \
        $TASK_ARGS \
        $TRAINING_ARGS \
        $RUN_ARGS \
        --output_dir /ns/models/$WANDB_PROJECT/$RUN_NAME