from typing import Optional

from sqlmodel import Field
from sqlmodel import SQLModel

from db_model.schema.enums import DataSource
from db_model.schema.enums import DataType
from db_model.schema.enums import DataUsage


class DatasetRow(SQLModel):
    report_id: str
    data_usage: Optional[DataUsage] = None
    data_type: Optional[DataType] = None
    data_format: Optional[str] = None
    data_size: Optional[float] = Field(default=None, ge=0)
    data_quantity: Optional[float] = Field(default=None, ge=0)
    shape: Optional[str] = None
    source: Optional[DataSource] = None
    source_uri: Optional[str] = None
    owner: Optional[str] = None
    dataset_name: Optional[str] = None
    dataset_description: Optional[str] = None
