
from pydantic import BaseModel, Field, ConfigDict


class AtendenteBase(BaseModel):
    nome: str = Field(..., min_length=2, max_length=100)
    dia_atendimento: str = Field(..., min_length=3, max_length=20)


class AtendenteCreate(AtendenteBase):
    pass


class AtendenteResponse(AtendenteBase):
    id_atendente: int

    model_config = ConfigDict(from_attributes=True)
