from pydantic import BaseModel
#from \model\algorithm_schema.json

class Hyperparameter(BaseModel):
    hyperparameterName: str
    hyperparameterValue: str


class Hyperparameters(BaseModel):
    tuningMethod: str
    values: list[Hyperparameter] = []


class Algorithm(BaseModel):
    algorithmName: str
    framework: str
    frameworkVersion: str
    classPath: str
    quantization: int
    hyperparameters: Hyperparameters = {}


Algorithm.model_rebuild()