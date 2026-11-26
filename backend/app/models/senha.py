
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship

from app.database import Base


class Senha(Base):
    __tablename__ = "senhas"

    id_senha = Column(Integer, primary_key=True, index=True, autoincrement=True)
    codigo = Column(String(10), nullable=False, unique=True)
    id_paciente = Column(Integer, ForeignKey("pacientes.id_paciente"), nullable=True)
    id_fila = Column(Integer, ForeignKey("filas.id_fila"), nullable=False)
    data_chegada = Column(DateTime, nullable=False)
    status = Column(
        String(20),
        nullable=False,
        default="aguardando"
    )

    paciente = relationship("Paciente", backref="senhas")
    fila = relationship("Fila", backref="senhas")

    __table_args__ = (
        CheckConstraint(
            "status IN ('aguardando', 'em atendimento', 'finalizada', 'cancelada')",
            name="ck_senhas_status"
        ),
    )
