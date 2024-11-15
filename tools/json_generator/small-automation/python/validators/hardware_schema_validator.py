# from pydantic import BaseModel, constr

# class Hardware(BaseModel):
#     componentName: str = constr(min_length=1)
#     nbComponent: int
#     memorySize: int
#     manufacturer: str
#     family: str
#     series: str
#     share: float = constr(ge=0.0, le=1.0)