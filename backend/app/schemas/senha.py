
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, Literal
from datetime import datetime


class SenhaBase(BaseModel):
    codigo: str = Field(..., min_length=1, max_length=10)
    id_fila: int
    id_paciente: Optional[int] = None


class SenhaCreate(SenhaBase):
    pass


class SenhaAssociarPaciente(BaseModel):
    id_paciente: int


class SenhaResponse(SenhaBase):
    id_senha: int
    data_chegada: datetime
    status: Literal[
        "aguardando",
        "em atendimento",
        "finalizada",
        "cancelada"
    ]

    model_config = ConfigDict(from_attributes=True)
