CREATE DATABASE clinic_flow;
use clinic_flow;
SHOW databases;
CREATE TABLE pacientes (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20)
);
CREATE TABLE atendente (
    id_atendente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    dia_atendimento VARCHAR(20) NOT NULL
);
CREATE TABLE filas (
    id_fila INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    prioridade INT NOT NULL
);
CREATE TABLE senhas (
    id_senha INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL,
    id_paciente INT NOT NULL,
    id_fila INT NOT NULL,
    data_chegada DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,

    FOREIGN KEY (id_paciente)
        REFERENCES pacientes(id_paciente),

    FOREIGN KEY (id_fila)
        REFERENCES filas(id_fila)
);
CREATE TABLE atendimentos (
    id_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    id_senha INT NOT NULL UNIQUE,
    id_atendente INT NOT NULL,
    inicio DATETIME NOT NULL,
    fim DATETIME,

    FOREIGN KEY (id_senha)
        REFERENCES senhas(id_senha),

    FOREIGN KEY (id_atendente)
        REFERENCES atendentes(id_atendente)
);
