
from sqlalchemy import Column, Integer, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class Atendimento(Base):
    __tablename__ = "atendimentos"

    id_atendimento = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_senha = Column(
        Integer,
        ForeignKey("senhas.id_senha"),
        nullable=False,
        unique=True
    )
    id_atendente = Column(
        Integer,
        ForeignKey("atendente.id_atendente"),
        nullable=False
    )
    inicio = Column(DateTime, nullable=False)
    fim = Column(DateTime, nullable=True)

    senha = relationship("Senha", backref="atendimento")
    atendente = relationship("Atendente", backref="atendimentos")
