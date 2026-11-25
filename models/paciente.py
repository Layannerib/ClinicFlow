
from sqlalchemy import Column, Integer, String

from app.database import Base


class Paciente(Base):
    __tablename__ = "pacientes"

    id_paciente = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nome = Column(String(100), nullable=False)
    cpf = Column(String(14), nullable=False, unique=True)
    telefone = Column(String(20), nullable=True)
