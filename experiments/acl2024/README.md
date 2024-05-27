
## Run GLUE trials

```console
model=/ns/models/ACL2024/bert_base_pairwise_20240204-093411/
seeds="1 2 3 4 5"
for s in $seeds;
do
    sbatch ./experiments/acl2024/run_glue_batch.sh $model $s;
done;
```

## Run GLUE on Model Checkpoint

```console
model=/ns/models/ACL2024/bert_base_symmetric_20240204-093411/
ckpts="6000 8000 10000 12000 14000 16000 18000 20000 22000 24000 30000 35000 40000 50000 75000 125000 150000 200000"
for c in $ckpts;
do
    sbatch ./experiments/acl2024/run_glue_checkpoint_batch.sh $model $c;
done;
```