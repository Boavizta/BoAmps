from typing import Optional

from sqlmodel import Field, SQLModel


class AlgorithmRow(SQLModel):
    report_id: str
    training_type: Optional[str] = None
    algorithm_type: Optional[str] = None
    algorithm_name: Optional[str] = None
    algorithm_uri: Optional[str] = None
    foundation_model_name: Optional[str] = None
    foundation_model_uri: Optional[str] = None
    parameters_number: Optional[float] = Field(default=None, ge=0)
    framework: Optional[str] = None
    framework_version: Optional[str] = None
    class_path: Optional[str] = None
    layers_number: Optional[float] = Field(default=None, ge=0)
    epochs_number: Optional[float] = Field(default=None, ge=0)
    optimizer: Optional[str] = None
    quantization: Optional[str] = None
