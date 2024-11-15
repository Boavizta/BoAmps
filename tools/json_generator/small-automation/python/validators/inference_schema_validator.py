from pydantic import BaseModel
from typing import Optional

class ParametersNLP(BaseModel):
    nb_tokens_input: Optional[int] = 0
    nb_words_input: Optional[int] = 0
    nb_tokens_output: Optional[int] = 0
    nb_words_output: Optional[int] = 0
    context_windows_size: Optional[int] = 0
    cache: Optional[bool] = None


class Query(BaseModel):
    nb_request: Optional[float] = 0.0
    parameters_nlp: Optional[ParametersNLP] = {}


Query.model_rebuild()


