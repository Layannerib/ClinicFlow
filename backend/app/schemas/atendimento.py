from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

class AtendimentoCreate(BaseModel):
    id_senha: int
    id_atendente: int

class AtendimentoResponse(BaseModel):
    id_atendimento: int
    id_senha: int
    id_atendente: int
    inicio: datetime
    fim: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
