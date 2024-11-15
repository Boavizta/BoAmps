from pydantic import BaseModel, Field
from typing import Annotated
from typing import Optional

class Hardware(BaseModel):
    componentName: Optional[str] = None
    nbComponent: Optional[int] = 0
    memorySize: Optional[int] = 0
    manufacturer: Optional[str] = None
    family: Optional[str] = None
    series: Optional[str] = None
    share: Optional[Annotated[float, Field(ge=0.0, le=1.0)]] = 0.0
