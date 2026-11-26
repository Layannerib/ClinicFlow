
from sqlalchemy import Column, Integer, String

from app.database import Base


class Atendente(Base):
    __tablename__ = "atendente"

    id_atendente = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nome = Column(String(100), nullable=False)
    dia_atendimento = Column(String(20), nullable=False)
