

USE clinic_flow;

-- 1. Listar todos os pacientes cadastrados
SELECT * FROM pacientes;

-- 2. Listar todos os atendentes
SELECT * FROM atendentes;

-- 3. Listar todas as filas cadastradas
SELECT * FROM filas;

-- 4. Listar todas as senhas geradas
SELECT * FROM senhas;



-- 2. CONSULTAS COM WHERE
-- 5. Buscar um paciente pelo nome
SELECT *
FROM pacientes
WHERE nome = 'Ana Silva';

-- 6. Buscar um paciente pelo CPF
SELECT *
FROM pacientes
WHERE cpf = '111.111.111-11';

-- 7. Listar somente as senhas que estão aguardando
SELECT *
FROM senhas
WHERE status = 'Aguardando';

-- 8. Listar os atendentes que trabalham na quarta-feira
SELECT *
FROM atendentes
WHERE dia_atendimento = 'Quarta-feira';

-- 3. CONSULTAS COM ORDER BY

-- 9. Listar pacientes em ordem alfabética
SELECT *
FROM pacientes
ORDER BY nome ASC;

-- 10. Listar senhas pela ordem de chegada
SELECT *
FROM senhas
ORDER BY data_chegada ASC;


-- 4. CONSULTAS COM JOIN

-- 11. Mostrar os pacientes e suas respectivas senhas
SELECT
    pacientes.nome,
    senhas.codigo,
    senhas.status,
    senhas.data_chegada
FROM pacientes
INNER JOIN senhas
    ON pacientes.id_paciente = senhas.id_paciente;

-- 12. Mostrar as senhas e seus respectivos tipos de fila
SELECT
    senhas.codigo,
    filas.nome AS nome_fila,
    senhas.status
FROM senhas
INNER JOIN filas
    ON senhas.id_fila = filas.id_fila;

-- 13. Mostrar os atendimentos e os atendentes responsáveis
SELECT
    atendimentos.id_atendimento,
    atendentes.nome AS atendente,
    atendimentos.inicio,
    atendimentos.fim
FROM atendimentos
INNER JOIN atendentes
    ON atendimentos.id_atendente = atendentes.id_atendente;

-- 14. Mostrar o histórico de atendimento dos pacientes
SELECT
    pacientes.nome AS paciente,
    senhas.codigo,
    atendentes.nome AS atendente,
    atendimentos.inicio,
    atendimentos.fim
FROM atendimentos
INNER JOIN senhas
    ON atendimentos.id_senha = senhas.id_senha
INNER JOIN pacientes
    ON senhas.id_paciente = pacientes.id_paciente
INNER JOIN atendentes
    ON atendimentos.id_atendente = atendentes.id_atendente;


-- 5. FUNÇÕES DE AGREGAÇÃO

-- 15. Contar a quantidade total de pacientes cadastrados
SELECT COUNT(*) AS total_pacientes
FROM pacientes;

-- 16. Contar quantas senhas existem em cada status
SELECT
    status,
    COUNT(*) AS quantidade
FROM senhas
GROUP BY status;

-- 17. Contar quantos atendimentos cada atendente realizou
SELECT
    atendentes.nome,
    COUNT(atendimentos.id_atendimento) AS total_atendimentos
FROM atendentes
LEFT JOIN atendimentos
    ON atendentes.id_atendente = atendimentos.id_atendente
GROUP BY
    atendentes.id_atendente,
    atendentes.nome;


-- 6. CÁLCULO DO TEMPO DE ATENDIMENTO

-- 18. Calcular o tempo de cada atendimento em minutos
-- Considera somente atendimentos já finalizados

SELECT
    id_atendimento,
    TIMESTAMPDIFF(MINUTE, inicio, fim) AS tempo_minutos
FROM atendimentos
WHERE fim IS NOT NULL;



