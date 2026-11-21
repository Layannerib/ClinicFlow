
from sqlalchemy import text
from app.database import engine

try:
    with engine.connect() as connection:
        resultado = connection.execute(text("SELECT DATABASE()"))
        banco = resultado.scalar()

        print("Conexão realizada com sucesso!")
        print(f"Banco conectado: {banco}")

except Exception as erro:
    print("Erro ao conectar com o banco:")
    print(erro)
