from pydantic import BaseModel, Field
from typing import Annotated, List, Optional
from algorithm_schema_validator import Algorithm
from dataset_schema_validator import Dataset
from measure_schema_validator import Measure
from hardware_schema_validator import Hardware
#from \model\report_schema.json


class Publisher(BaseModel):
    name : Optional[str] = None
    division : Optional[str] = None
    projectname : Optional[str] = None
    confidentialityLevel : Optional[Annotated[str, Field(pattern=r"(public|internal|confidential|secret)")]]
    publicKey : Optional[str] = None


class Header(BaseModel):
    licensing : Optional[str] = None
    formatVersion : Optional[str] = None
    formatVersionSpecificationUri : Optional[str] = None
    reportId : Optional[str] = None
    reportDatetime : Optional[str] = None
    reportStatus : Optional[Annotated[str, Field(pattern=r"(draft|final|corrective|$other)")]]
    publisher : Optional[Publisher] = None


class Task(BaseModel):
    taskType : Optional[str] = None
    taskFamily : Optional[str] = None
    taskStage : Optional[str] = None
    algorithms : Optional[List[Algorithm]] = None
    datasets : Optional[List[Dataset]] = None
    measuredAccuracy : Optional[Annotated[float, Field(ge=0.0, le=1.0)]] = 0.0
    estimatedAccuracy : Optional[Annotated[str, Field(pattern=r"(veryPoor|poor|average|good|veryGood)")]]


class System(BaseModel):
    os : Optional[str] = None
    distribution : Optional[str] = None
    distributionVersion : Optional[str] = None


class Software(BaseModel):
    language : Optional[str] = None
    version : Optional[str] = None


class Infrastructure(BaseModel):
    infraType : Optional[Annotated[str, Field(pattern=r"(publicCloud|privateCloud|onPremise|$other)")]]
    cloudProvider : Optional[str] = None
    cloudInstance : Optional[str] = None
    components : Optional[List[Hardware]] = None


class Environment(BaseModel):
    country : Optional[str] = None
    latitude : Optional[float] = None
    longitude : Optional[float] = None
    location : Optional[str] = None
    powerSupplierType : Optional[Annotated[str, Field(pattern=r"(public|private|internal|$other)")]]
    powerSource : Optional[Annotated[str, Field(pattern=r"(solar|wind|nuclear|hydroelectric|gas|coal|$other)")]]
    powerSourceCarbonIntensity : Optional[float] = None


class Hash(BaseModel):
    hashAlgorithm: Optional[Annotated[str, Field(pattern=r"(MD5|RIPEMD-128|RIPEMD-160|RIPEMD-256|RIPEMD-320|SHA-1|SHA-224|SHA-256|SHA-384|SHA-512)")]]
    cryptographicAlgorithm : Optional[Annotated[str, Field(pattern=r"(RSA|DSA|ECDSA|EDDSA)")]]
    country : Optional[str] = None


class Report(BaseModel):
    header : Optional[Header] = None
    model : Optional[Task] = None
    measures : Optional[List[Measure]] = None
    system : Optional[System] = None
    software : Optional[Software] = None
    infrastructure : Optional[Infrastructure] = None
    quality : Optional[Annotated[str, Field(pattern=r"(high|medium|low)")]]
    hash : Optional[Hash] = None


Report.model_rebuild()