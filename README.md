# ACL2024-SymmetricAttentionBert

# 1. Dataset
In the `/data` folder are scripts and instruction to re-generate the dataset from OSCAR-2301 dumps available on Hugging Face https://huggingface.co/datasets/oscar-corpus/OSCAR-2301.

# 2. The PLPI package
The PLPI package contains source code for the implementation of symmetric and pairwise dot-product attention BERT models.

```console
pip install ./plpi
```

```python
from plpi.models import BertConfig, BertForMaskedLM

config = BertConfig(...)
model = BertForMaskedLM(config)
```
For convenience, when imported `plpi` will also patch the `transformers` model registry to give `AutoModel` and `AutoConfig` the ability to load `plpi` models, like `plpi/bert` or `plpi/roberta`.

# 3. Scripts
Training scripts and benchmark scripts are ported from the Hugging Face `transformers` library to use the `plpi` library, they are available in the `/scripts` folder.

# 4. Experiments scripts
Under `/experiments/acl2024` you will find slurm scripts to run the pre-training, the glue benchmark, and the checkpoint benchmark experiments.
