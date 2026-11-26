
from sqlalchemy import Column, Integer, String, CheckConstraint

from app.database import Base


class Fila(Base):
    __tablename__ = "filas"

    id_fila = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nome = Column(String(100), nullable=False)
    prioridade = Column(Integer, nullable=False)

    __table_args__ = (
        CheckConstraint(
            "prioridade IN (1, 2, 3)",
            name="ck_filas_prioridade"
        ),
    )
