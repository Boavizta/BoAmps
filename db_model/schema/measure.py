from typing import Optional

from sqlmodel import Field, SQLModel


class MeasureRow(SQLModel):
    report_id: str
    measurement_method: Optional[str] = None
    manufacturer: Optional[str] = None
    version: Optional[str] = None
    cpu_tracking_mode: Optional[str] = None
    gpu_tracking_mode: Optional[str] = None
    average_utilization_cpu: Optional[float] = Field(default=None, ge=0, le=1)
    average_utilization_gpu: Optional[float] = Field(default=None, ge=0, le=1)
    power_calibration_measurement: Optional[float] = Field(default=None, ge=0)
    duration_calibration_measurement: Optional[float] = Field(default=None, ge=0)
    power_consumption: Optional[float] = None
    measurement_duration: Optional[float] = Field(default=None, ge=0)
    measurement_datetime: Optional[str] = None
