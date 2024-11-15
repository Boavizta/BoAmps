from pydantic import BaseModel, Field
from typing import Annotated

class Measure(BaseModel):
    measurementMethod: str
    manufacturer: str
    version : str
    cpuTrackingMode : str
    gpuTrackingMode : str
    averageUtilizationCpu : Annotated[float, Field(ge=0.0, le=1.0)]
    averageUtilizationGpu : Annotated[float, Field(ge=0.0, le=1.0)]
    serverSideInference : Annotated[str, Field(regex=r"(modelServer|inferenceServer|both)")]
    unit : Annotated[str, Field(regex=r"(mWh|Wh|kWh|MWh|GWh|kJoule|MJoule|GJoule|TJoule|PJoule|BTU|kiloFLOPS|megaFLOPS|gigaFLOPS|teraFLOPS|petaFLOPS|exaFLOPS|zettaFLOPS|yottaFLOPS")]
    powerCalibrationMeasurement : float
    durationCalibrationMeasurement : float
    powerConsumption : float
    measurementDuration : float
    measurementDateTime : int
    share: Annotated[float, Field(ge=0.0, le=1.0)]
