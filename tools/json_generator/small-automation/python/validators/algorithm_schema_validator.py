from pydantic import BaseModel, conint, constr
#from \model\algorithm_schema.json

class Hyperparameter(BaseModel):
    hyperparameterName: str
    hyperparameterValue: str


class Hyperparameters(BaseModel):
    tuningMethod: str
    values: list[Hyperparameter] = []


class Algorithm(BaseModel):
    id: str = "https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/algorithm_schema.json"
    title: str = "Algorithm"
    description: str = "The type of algorithm used by the computing task"

    class Properties(BaseModel):
        algorithmName: str
        framework: str
        frameworkVersion: str
        classPath: str
        quantization: int
        hyperparameters: Hyperparameters = {}

    properties: Properties

Algorithm.model_rebuild()