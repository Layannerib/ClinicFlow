# Modelagem do Banco de Dados — ClinicFlow

## 1. Entidades

O banco de dados do ClinicFlow será composto inicialmente por cinco entidades principais: PACIENTES, FUNCIONARIOS, FILAS, SENHAS e ATENDIMENTOS.

### 1.1 PACIENTES
Armazena os dados dos pacientes cadastrados no sistema.

| Atributo | Descrição | Tipo |
|---|---|---|
| id_paciente (PK) | Identificador do paciente | INT |
| nome | Nome completo | VARCHAR(100) |
| cpf | CPF do paciente | VARCHAR(14) |
| telefone | Telefone para contato | VARCHAR(20) |

### 1.2 FUNCIONARIOS
Armazena os dados dos funcionários da clínica.

| Atributo | Descrição | Tipo |
|---|---|---|
| id_funcionario (PK) | Identificador do funcionário | INT |
| nome | Nome completo | VARCHAR(100) |
| cargo | Cargo do funcionário | VARCHAR(50) |

### 1.3 FILAS
Identifica os tipos de fila disponíveis no sistema.

| Atributo | Descrição | Tipo |
|---|---|---|
| id_fila (PK) | Identificador da fila | INT |
| tipo_fila | Tipo da fila (normal ou prioritária) | VARCHAR(20) |

### 1.4 SENHAS
Armazena as senhas geradas para os pacientes.

| Atributo | Descrição | Tipo |
|---|---|---|
| id_senha (PK) | Identificador da senha | INT |
| codigo | Código da senha | VARCHAR(20) |
| id_paciente (FK) | Paciente associado à senha | INT |
| id_fila (FK) | Fila associada à senha | INT |
| data_chegada | Data e horário de chegada | DATETIME |
| status | Situação atual da senha | VARCHAR(20) |

### 1.5 ATENDIMENTOS
Registra os atendimentos realizados na clínica.

| Atributo | Descrição | Tipo |
|---|---|---|
| id_atendimento (PK) | Identificador do atendimento | INT |
| id_senha (FK) | Senha associada ao atendimento | INT |
| id_funcionario (FK) | Funcionário responsável | INT |
| inicio | Data e horário de início | DATETIME |
| fim | Data e horário de término | DATETIME |

## 2. Relacionamentos

- PACIENTES e SENHAS: um paciente poderá possuir várias senhas, mas cada senha pertencerá a apenas um paciente (1:N).
- FILAS e SENHAS: uma fila poderá possuir várias senhas, mas cada senha pertencerá a apenas uma fila (1:N).
- SENHAS e ATENDIMENTOS: uma senha poderá gerar no máximo um atendimento, e cada atendimento estará associado a uma única senha (1:0..1).
- FUNCIONARIOS e ATENDIMENTOS: um funcionário poderá realizar vários atendimentos, mas cada atendimento será realizado por um único funcionário (1:N).

## 3. Restrições e Observações

- Os atributos identificadores de cada entidade serão definidos como chaves primárias (PK).
- As chaves estrangeiras (FK) serão utilizadas para estabelecer os relacionamentos entre as tabelas.
- O CPF do paciente deverá ser único.
- O código da senha deverá ser único.
- Os campos de data e horário serão utilizados para registrar a chegada e a duração dos atendimentos.
- O status da senha deverá representar sua situação na fila.
- A modelagem poderá ser ajustada durante a implementação, conforme as necessidades identificadas.
