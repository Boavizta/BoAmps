from pydantic import BaseModel

class ParametersNLP(BaseModel):
    nb_tokens_input: int
    nb_words_input: int
    nb_tokens_output: int
    nb_words_output: int
    context_windows_size: float
    cache: bool

class Query(BaseModel):
    id: str = "https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/inference_schema.json"
    title: str = "query"
    description: str = "the type of query sent to the algorithm"
    
    nb_request: int
    parameters_nlp: ParametersNLP = {}

Query.model_rebuild()


