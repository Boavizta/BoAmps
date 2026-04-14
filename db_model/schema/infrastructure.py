from typing import Optional

from sqlmodel import Field
from sqlmodel import SQLModel


class InfrastructureRow(SQLModel):
    report_id: str
    component_name: Optional[str] = None
    component_type: Optional[str] = None
    nb_component: Optional[int] = Field(default=None, ge=1)
    memory_size: Optional[float] = Field(default=None, ge=0)
    manufacturer: Optional[str] = None
    family: Optional[str] = None
    series: Optional[str] = None
    share: Optional[float] = Field(default=None, ge=0, le=1)
    component_description: Optional[str] = None
