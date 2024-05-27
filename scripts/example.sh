#!/usr/bin/env bash

RUN_NAME=bert_small_vanilla_b64_$(date '+%Y%m%d-%H%M%S')
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
)
CONFIG_ARGS=$(IFS=,; printf '%s' "${CONFIG_ARGS[*]}")
MODEL_ARGS="
    --model_type bert \
    --tokenizer_name bert-base-uncased \
    --config_overrides $CONFIG_ARGS
"

DATA_ARGS="
    --dataset_dir ./data/bert-base-uncased_wikitext-2-v1 \
    --force_preprocess \
    --dataset_name wikitext
    --dataset_config_name wikitext-2-v1
"
# SCRIPT -END-

python ./train_mlm.py \
    $MODEL_ARGS \
    $DATA_ARGS \
    --output_dir ./models/$RUN_NAME






