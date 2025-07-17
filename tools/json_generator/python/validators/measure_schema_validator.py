from pydantic import BaseModel, Field
from typing import Annotated
from typing import Optional
#from \model\measure_schema.json


class Measure(BaseModel):
    measurementMethod: Optional[str] = None
    manufacturer: Optional[str] = None
    version : Optional[str] = None
    cpuTrackingMode : Optional[str] = None
    gpuTrackingMode : Optional[str] = None
    averageUtilizationCpu : Annotated[float, Field(ge=0.0, le=1.0)]
    averageUtilizationGpu : Annotated[float, Field(ge=0.0, le=1.0)]
    serverSideInference : Annotated[str, Field(pattern=r"(modelServer|inferenceServer|both)")]
    unit : Annotated[str, Field(pattern=r"(mWh|Wh|kWh|MWh|GWh|kJoule|MJoule|GJoule|TJoule|PJoule|BTU|kiloFLOPS|megaFLOPS|gigaFLOPS|teraFLOPS|petaFLOPS|exaFLOPS|zettaFLOPS|yottaFLOPS)")]
    powerCalibrationMeasurement : Optional[float] = 0.0
    durationCalibrationMeasurement : Optional[float] = 0.0
    powerConsumption : Optional[float] = 0.0
    measurementDuration : Optional[float] = 0.0
    measurementDateTime : Optional[int] = 0
    share: Optional[Annotated[float, Field(ge=0.0, le=1.0)]] = 0.0
