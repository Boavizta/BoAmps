from pydantic import BaseModel
from typing import Optional
#from \model\algorithm_schema.json

class Hyperparameter(BaseModel):
    hyperparameterName: Optional[str] = None
    hyperparameterValue: Optional[str] = None


class Hyperparameters(BaseModel):
    tuningMethod: Optional[str] = None
    values: Optional[list[Hyperparameter]] = []


class Algorithm(BaseModel):
    algorithmName: Optional[str] = None
    framework: Optional[str] = None
    frameworkVersion: Optional[str] = None
    classPath: Optional[str] = None
    quantization: Optional[int] = 0
    hyperparameters: Optional[Hyperparameters] = {}


Algorithm.model_rebuild()