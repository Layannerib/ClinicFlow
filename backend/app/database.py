
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import declarative_base, sessionmaker

# Carrega as configurações do arquivo .env
load_dotenv()

# Monta a URL de conexão com o MySQL
DATABASE_URL = URL.create(
    drivername="mysql+pymysql",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT", 3306)),
    database=os.getenv("DB_NAME"),
)

# Cria o mecanismo de conexão
engine = create_engine(DATABASE_URL, echo=True)

# Cria as sessões do banco
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Base para os modelos do banco
Base = declarative_base()


# Disponibiliza uma sessão para as rotas
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
