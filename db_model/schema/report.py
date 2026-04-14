from datetime import datetime
from typing import Optional

from pydantic import field_validator
from sqlmodel import Field
from sqlmodel import SQLModel

from db_model.schema.enums import ConfidentialityLevel
from db_model.schema.enums import InfraType
from db_model.schema.enums import PowerSource
from db_model.schema.enums import PowerSupplierType
from db_model.schema.enums import Quality
from db_model.schema.enums import ReportStatus

DATETIME_FORMATS = [
    '%Y-%m-%dT%H:%M:%S.%f',
    '%Y-%m-%dT%H:%M:%S',
    '%Y-%m-%d %H:%M:%S',
    '%Y-%m-%d',
]


def _parse_datetime(value: str) -> datetime:
    for fmt in DATETIME_FORMATS:
        try:
            return datetime.strptime(value, fmt)
        except ValueError:
            continue
    raise ValueError(f"Unrecognised datetime format: {value!r}")


class ReportRow(SQLModel):
    report_id: str
    licensing: Optional[str] = None
    format_version: Optional[str] = None
    format_version_specification_uri: Optional[str] = None
    report_datetime: Optional[datetime] = None

    @field_validator('report_datetime', mode='before')
    @classmethod
    def coerce_datetime(cls, v):
        if v is None or isinstance(v, datetime):
            return v
        return _parse_datetime(str(v))
    report_status: Optional[ReportStatus] = None
    publisher_name: Optional[str] = None
    publisher_division: Optional[str] = None
    publisher_project_name: Optional[str] = None
    confidentiality_level: Optional[ConfidentialityLevel] = None
    task_stage: Optional[str] = None
    task_family: Optional[str] = None
    nb_request: Optional[float] = None
    measured_accuracy: Optional[float] = Field(default=None, ge=0, le=1)
    estimated_accuracy: Optional[str] = None
    task_description: Optional[str] = None
    os: Optional[str] = None
    distribution: Optional[str] = None
    distribution_version: Optional[str] = None
    language: Optional[str] = None
    software_version: Optional[str] = None
    infra_type: Optional[InfraType] = None
    cloud_provider: Optional[str] = None
    cloud_instance: Optional[str] = None
    cloud_service: Optional[str] = None
    country: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location: Optional[str] = None
    power_supplier_type: Optional[PowerSupplierType] = None
    power_source: Optional[PowerSource] = None
    power_source_carbon_intensity: Optional[float] = Field(default=None, ge=0)
    quality: Optional[Quality] = None
