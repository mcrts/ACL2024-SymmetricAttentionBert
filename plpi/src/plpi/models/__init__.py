from transformers import AutoConfig, AutoModel, AutoModelForMaskedLM, AutoModelForSequenceClassification

from .bert.modeling_bert import BertModel, BertForMaskedLM, BertForSequenceClassification
from .bert.configuration_bert import BertConfig

from .roberta.modeling_roberta import RobertaModel, RobertaForMaskedLM, RobertaForSequenceClassification
from .roberta.configuration_roberta import RobertaConfig


AutoConfig.register('plpi/roberta', RobertaConfig)
AutoModel.register(RobertaConfig, RobertaModel, exist_ok=True)
AutoModelForMaskedLM.register(RobertaConfig, RobertaForMaskedLM, exist_ok=True)
AutoModelForSequenceClassification.register(RobertaConfig, RobertaForSequenceClassification, exist_ok=True)

AutoConfig.register('plpi/bert', BertConfig)
AutoModel.register(BertConfig, BertModel, exist_ok=True)
AutoModelForMaskedLM.register(BertConfig, BertForMaskedLM, exist_ok=True)
AutoModelForSequenceClassification.register(BertConfig, BertForSequenceClassification, exist_ok=True)