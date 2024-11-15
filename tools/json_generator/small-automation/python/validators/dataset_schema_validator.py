from pydantic import BaseModel, constr
from typing import List, Union
#from \model\dataset_schema.json

class Dataset(BaseModel):
    id: str = "https://raw.githubusercontent.com/Boavizta/ai-power-measures-sharing/main/model/dataset_schema.json"
    title : str = "Dataset"
    description: str = "Describe the nature, shape, number of items and other properties of the dataset involved in your task. If you are performing inferences, please indicate the average size of the data sent for a single inference and fill in the number of inferences in the propertiy: inferenceProperties",
    
    dataType: str = constr(regex=r"(tabular|audio|boolean|image|video|object|text|$other)")
    fileType: str = constr(enum=["3gp", "3gpp", ...])  # fill in the enum values from the JSON schema
    volume: int
    volumeUnit: str = constr(enum=["kilobyte", "megabyte", ...])  # fill in the enum values from the JSON schema
    items: int
    shape: List[int]
    inferenceProperties: Union[List[dict], None] = []
    source: str = constr(enum=["public", "private", "$other"])
    sourceUri: str = ""
    owner: str = ""

    class Config:
        schema_extra = {
            "example": {"dataType": "tabular", ...}  # fill in the example values from the JSON schema
        }