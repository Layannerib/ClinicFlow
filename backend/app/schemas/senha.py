
from pydantic import BaseModel, Field, ConfigDict
from typing import Literal
from datetime import datetime


class SenhaBase(BaseModel):
    codigo: str = Field(..., min_length=1, max_length=10)
    id_fila: int


class SenhaCreate(SenhaBase):
    pass


class SenhaAssociarPaciente(BaseModel):
    id_paciente: int


class SenhaResponse(BaseModel):
    id_senha: int
    codigo: str
    id_paciente: int | None = None
    id_fila: int
    data_chegada: datetime
    status: Literal[
        "aguardando",
        "em atendimento",
        "finalizada",
        "cancelada"
    ]

    model_config = ConfigDict(from_attributes=True)
