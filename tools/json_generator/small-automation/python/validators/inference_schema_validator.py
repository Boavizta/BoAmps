from pydantic import BaseModel

class ParametersNLP(BaseModel):
    nb_tokens_input: int
    nb_words_input: int
    nb_tokens_output: int
    nb_words_output: int
    context_windows_size: int
    cache: bool


class Query(BaseModel):
    nb_request: float
    parameters_nlp: ParametersNLP = {}


Query.model_rebuild()


