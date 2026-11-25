
CREATE DATABASE IF NOT EXISTS clinic_flow
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE clinic_flow;


-- Tabela: pacientes
CREATE TABLE pacientes (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    telefone VARCHAR(20),

    UNIQUE KEY uq_pacientes_cpf (cpf)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


-- Tabela: atendente
CREATE TABLE atendente (
    id_atendente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    dia_atendimento VARCHAR(20) NOT NULL,

    UNIQUE KEY uq_atendente_nome_dia (nome, dia_atendimento)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


-- Tabela: filas
CREATE TABLE filas (
    id_fila INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    prioridade TINYINT UNSIGNED NOT NULL,

    UNIQUE KEY uq_filas_nome (nome),

    CONSTRAINT chk_filas_prioridade
        CHECK (prioridade IN (1, 2, 3))
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


-- Tabela: senhas
CREATE TABLE senhas (
    id_senha INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL,
    id_paciente INT NULL,
    id_fila INT NOT NULL,
    data_chegada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM(
        'aguardando',
        'em atendimento',
        'finalizada',
        'cancelada'
    ) NOT NULL DEFAULT 'aguardando',

    UNIQUE KEY uq_senhas_codigo (codigo),
    INDEX idx_senhas_status_chegada (status, data_chegada),

    CONSTRAINT fk_senhas_pacientes
        FOREIGN KEY (id_paciente)
        REFERENCES pacientes (id_paciente)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_senhas_filas
        FOREIGN KEY (id_fila)
        REFERENCES filas (id_fila)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


-- Tabela: atendimentos
CREATE TABLE atendimentos (
    id_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    id_senha INT NOT NULL,
    id_atendente INT NOT NULL,
    inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fim DATETIME NULL,

    UNIQUE KEY uq_atendimentos_senha (id_senha),

    CONSTRAINT fk_atendimentos_senhas
        FOREIGN KEY (id_senha)
        REFERENCES senhas (id_senha)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_atendimentos_atendente
        FOREIGN KEY (id_atendente)
        REFERENCES atendente (id_atendente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


-- Verificação das tabelas criadas
SELECT
    TABLE_NAME,
    ENGINE,
    TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'clinic_flow'
AND TABLE_TYPE = 'BASE TABLE';
