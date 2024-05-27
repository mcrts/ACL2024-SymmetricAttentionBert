#!/usr/bin/env python
# coding=utf-8

"""
Prepare dataset for pre-training masked language modeling models (BERT, ALBERT, RoBERTa...).
The dataset is a filtered subset of OSCAR-2301.
"""

from datasets import load_dataset, Dataset
from functools import partial
import fire
import warnings

def main(dataset_path, dataset_conf, dst, split="train", num_proc=16, max_sample_size=1_000_000, validation_size=1_000, push_to_hub=False, hub_repo=None):
    if push_to_hub and not hub_repo:
        raise ValueError(f"--push_to_hub is set, but --hub_repo is not.")
    if hub_repo and not push_to_hub:
        raise ValueError("--hub_repo is set, but --push_to_hub is not.")
    
    ds = load_dataset(
        dataset_path,
        dataset_conf,
        split=split,
        num_proc=num_proc,
    )
    if max_sample_size > ds.num_rows:
        print(f"{max_sample_size=} > {ds.num_rows=}, no downsampling.")
    else:
        ds = ds.select(range(max_sample_size))
    ds = ds.train_test_split(test_size=validation_size, shuffle=True)
    ds['validation'] = ds['test']
    ds.pop('test')
    ds.save_to_disk(dst, num_proc=num_proc)

    if push_to_hub and hub_repo:
        ds.push_to_hub(hub_repo, private=True)

if __name__ == "__main__":
    fire.Fire(main)