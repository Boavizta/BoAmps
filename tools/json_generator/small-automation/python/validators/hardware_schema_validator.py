from pydantic import BaseModel, Field
from typing import Annotated

class Hardware(BaseModel):
    componentName: str
    nbComponent: int
    memorySize: int
    manufacturer: str
    family: str
    series: str
    share: Annotated[float, Field(ge=0.0, le=1.0)]
