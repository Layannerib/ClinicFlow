
from pydantic import BaseModel, Field, ConfigDict
from typing import Literal


class FilaBase(BaseModel):
    nome: str = Field(..., min_length=2, max_length=100)
    prioridade: Literal[1, 2, 3]


class FilaCreate(FilaBase):
    pass


class FilaResponse(FilaBase):
    id_fila: int

    model_config = ConfigDict(from_attributes=True)
