#!/usr/bin/env bash
#SBATCH --job-name sbatch-bert-small
#SBATCH --array=0-2
#SBATCH --partition A100-80GB
#SBATCH --nodes 1
#SBATCH --gpus 2
#SBATCH --cpus-per-gpu 4
#SBATCH --mem 128G
#SBATCH --time 03-00:00

ATTN_FUNC=$SLURM_ARRAY_TASK_ID
N_PROC=2
MODEL_SIZE=small

# SRUN -START-
IMAGE=/netscratch/$USER/enroot/plpi-dev1.0.1.sqsh
MOUNTS=/netscratch/$USER:/netscratch/$USER,/netscratch/$USER:/ns,"`pwd`":/ws
MOUNTS=$MOUNTS,/home/$USER:/root
MOUNTS=$MOUNTS,"`pwd`/plpi":/opt/plpi

CONTAINER_ARGS="
    --container-image=$IMAGE \
    --container-mounts=$MOUNTS \
    --container-workdir=/ws
"
JOBNAME=plpi_$(date '+%Y%m%d-%H%M%S')
# SRUN -END-

SCORING_FUNCTIONS=(
    vanilla
    symmetric
    pairwise
)
SCORING=${SCORING_FUNCTIONS[$ATTN_FUNC]}


# SCRIPT -START-
WANDB_PROJECT=ACL2024
WANDB_TAGS=bert,${MODEL_SIZE},$SCORING
EXPORT_ARGS="'WANDB_PROJECT=$WANDB_PROJECT','WANDB_TAGS=$WANDB_TAGS'"

SEED=1
RUN_NAME=bert_${MODEL_SIZE}_${SCORING}_$(date '+%Y%m%d-%H%M%S')
CONFIG_ARGS=(
    type_vocab_size=2
    vocab_size=30522
    pad_token_id=0
    attention_probs_dropout_prob=0.1
    hidden_act=gelu
    hidden_dropout_prob=0.1
    hidden_size=512
    initializer_range=0.02
    intermediate_size=2048
    layer_norm_eps=1e-12
    max_position_embeddings=512
    num_attention_heads=8
    num_hidden_layers=4
    position_embedding_type=absolute
    plpi_affinity_function=$SCORING
)
CONFIG_ARGS=$(IFS=,; printf '%s' "${CONFIG_ARGS[*]}")
MODEL_ARGS="
    --model_type plpi/bert \
    --tokenizer_name bert-base-uncased \
    --config_overrides $CONFIG_ARGS
"

SEQ_LENGTH=512
DATA_ARGS="
    --dataset_name mcrts/OSCAR-2301_en_30M \
    --dataset_dir /ns/data/bert-base-uncased_$SEQ_LENGTH/OSCAR-2301_en_30M \
    --data_seed $SEED
"

DATALOADER_WORKER=$((4 * N_PROC))
TRAINING_ARGS="
    --do_train \
    --do_eval \
    --seed $SEED \

    --max_steps 200000 \
    --learning_rate 1e-04 \
    --warmup_steps 10000 \
    --weight_decay 0.01 \
    --adam_beta1 0.9 \
    --adam_beta2 0.999 \
    --adam_epsilon 1e-12 \
    --per_device_train_batch_size 64 \
    --gradient_accumulation_steps 2 \
    --per_device_eval_batch_size 128 \

    --logging_strategy steps \
    --logging_steps 25 \
    --evaluation_strategy steps \
    --eval_steps 250 \
    --save_strategy steps \
    --save_steps 1000 \
    --save_only_model \

    --fp16 \
    --torch_compile \
    --optim adamw_apex_fused \
    --dataloader_num_workers $DATALOADER_WORKER
"

RUN_ARGS="
    --run_name $RUN_NAME \
    --report_to wandb
"
# SCRIPT -END-

srun -K \
    --job-name=$JOBNAME \
    $CONTAINER_ARGS \
    --export=$EXPORT_ARGS \
    torchrun --standalone --nproc-per-node $N_PROC /ws/scripts/train_mlm.py \
        $MODEL_ARGS \
        $DATA_ARGS \
        $TRAINING_ARGS \
        $RUN_ARGS \
        --output_dir /ns/models/$WANDB_PROJECT/$RUN_NAME