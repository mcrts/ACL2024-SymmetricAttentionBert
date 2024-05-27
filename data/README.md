# Data Processing OSCAR-2301

## Download a subset of OSCAR-2301
First download a subset of OSCAR-2301 from HuggingFace

```console
git lfs install
GIT_LFS_SKIP_SMUDGE=1 git clone git@hf.co:datasets/oscar-corpus/OSCAR-2301

cd OSCAR-2301
```

Parallel is not interactive, so make sure you don't have a passphrase or that it is cached.

Download the first 300 parts of the english set running 3 jobs in parallel.
```console
for d in {1..300}; do echo "en_meta/en_meta_part_$d.jsonl.zst"; done | parallel -j3 --progress "git lfs fetch --include={}"
```

Then checkout to load the fetched files to the index tree.
```
git lfs checkout en_meta/*
```

Restrict the checksum file to the downloaded files
First back it up.
```console
cp en_meta/checksum.sha256 en_meta/checksum.sha256.orig
```
```console
awk -F"[_]|[.]" '{ if($4 <= 900) {print}}' en_meta/checksum.sha256.orig > en_meta/checksum.sha256
```

Finally,
Run the sha256check.
```console
sha256sum -c checksum.sha256 | grep FAILED
```
If you see failed part, you may need to check them out again (git lfs checkout) or fetch them again (git lfs fetch).

## Filter OSCAR
Run the scipt 
```
python data/oscar_filter.py src_part.jsonl.zst dst_part.jsonl.zst
```
Tips: run in parallel.

```console
find ~/ns/data/oscar-corpus/OSCAR-2301/en_meta -name "*.jsonl.zst" \
    | awk '{src=$0; sub(/oscar-corpus/, "mcrts", $0); print src " " $0}' \
    | parallel -j4 --colsep " " --progress \
    "python data/oscar_filter.py {1} {2}"
```

Remove un checked out files
```
ls | awk -F"[_]|[.]" '{ if($4 > 900) {print}}' | xargs -rd '\n' rm --
```

Generate checksum
```
ls *.jsonl.zst | parallel -j 64 sha256sum > checksum.sha256
```

Sanity check
```
sha256sum -c checksum.sha256 | grep FAILED
```

## Generate the Splits

```console
./data/oscar_split.py \
    --dataset_path /ns/data/mcrts/OSCAR-2301 \
    --dataset_conf en \
    --max_sample_size 40000000 \
    --validation_size 1000 \
    --num_proc 128 \
    --dst /ns/data/mcrts/OSCAR-2301_en_40M
```
You probably want to run this on a lot of cpu.