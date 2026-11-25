-- Consultas SQL | Clinic Flow

USE clinic_flow;


-- 1-4 Consultas basicas
SELECT * FROM pacientes;

SELECT * FROM atendente;

SELECT * FROM filas;

SELECT * FROM senhas;


-- 5-8 WHERE
SELECT *
FROM pacientes
WHERE nome = 'Ana Silva';

SELECT *
FROM pacientes
WHERE cpf = '111.111.111-11';

SELECT *
FROM senhas
WHERE status = 'aguardando';

SELECT *
FROM atendente
WHERE dia_atendimento = 'Quarta-feira';


-- 9-10 ORDER BY
SELECT *
FROM pacientes
ORDER BY nome ASC;

SELECT *
FROM senhas
ORDER BY data_chegada ASC;


-- 11-14 JOIN
SELECT
    p.nome AS paciente,
    s.codigo AS senha,
    s.status,
    s.data_chegada
FROM pacientes p
JOIN senhas s
    ON s.id_paciente = p.id_paciente;


SELECT
    s.codigo AS senha,
    f.nome AS nome_fila,
    s.status
FROM senhas s
JOIN filas f
    ON f.id_fila = s.id_fila;


SELECT
    atd.id_atendimento,
    a.nome AS atendente,
    atd.inicio,
    atd.fim
FROM atendimentos atd
JOIN atendente a
    ON a.id_atendente = atd.id_atendente;


SELECT
    p.nome AS paciente,
    s.codigo AS senha,
    a.nome AS atendente,
    atd.inicio,
    atd.fim
FROM atendimentos atd
JOIN senhas s
    ON s.id_senha = atd.id_senha
LEFT JOIN pacientes p
    ON p.id_paciente = s.id_paciente
JOIN atendente a
    ON a.id_atendente = atd.id_atendente;


-- 15-17 Agregacoes
SELECT
    COUNT(*) AS total_pacientes
FROM pacientes;


SELECT
    status,
    COUNT(*) AS quantidade
FROM senhas
GROUP BY status;


SELECT
    a.nome,
    COUNT(atd.id_atendimento) AS total_atendimentos
FROM atendente a
LEFT JOIN atendimentos atd
    ON atd.id_atendente = a.id_atendente
GROUP BY a.id_atendente, a.nome;


-- 18-23 Tempo, HAVING e subconsultas
SELECT
    id_atendimento,
    TIMESTAMPDIFF(MINUTE, inicio, fim) AS tempo_minutos
FROM atendimentos
WHERE fim IS NOT NULL;


SELECT
    a.nome,
    COUNT(*) AS total_atendimentos
FROM atendente a
JOIN atendimentos atd
    ON atd.id_atendente = a.id_atendente
GROUP BY a.id_atendente, a.nome
HAVING COUNT(*) >= 1;


SELECT
    id_atendimento,
    inicio,
    fim,
    TIMESTAMPDIFF(MINUTE, inicio, fim) AS tempo_minutos
FROM atendimentos
WHERE fim IS NOT NULL
AND TIMESTAMPDIFF(MINUTE, inicio, fim) > (
    SELECT AVG(TIMESTAMPDIFF(MINUTE, inicio, fim))
    FROM atendimentos
    WHERE fim IS NOT NULL
);


SELECT
    p.id_paciente,
    p.nome
FROM pacientes p
WHERE EXISTS (
    SELECT 1
    FROM senhas s
    WHERE s.id_paciente = p.id_paciente
);


SELECT
    p.id_paciente,
    p.nome
FROM pacientes p
WHERE NOT EXISTS (
    SELECT 1
    FROM senhas s
    WHERE s.id_paciente = p.id_paciente
);


SELECT
    f.nome AS fila,
    COUNT(s.id_senha) AS total_senhas
FROM filas f
JOIN senhas s
    ON s.id_fila = f.id_fila
GROUP BY f.id_fila, f.nome
HAVING COUNT(s.id_senha) > 1;


-- 24-25 CASE e LIMIT
SELECT
    codigo,
    status,
    CASE status
        WHEN 'aguardando' THEN 'Aguardando atendimento'
        WHEN 'em atendimento' THEN 'Atendimento em andamento'
        WHEN 'finalizada' THEN 'Atendimento concluido'
        WHEN 'cancelada' THEN 'Senha cancelada'
        ELSE 'Status nao identificado'
    END AS descricao_status
FROM senhas;


SELECT
    codigo,
    id_paciente,
    id_fila,
    data_chegada,
    status
FROM senhas
ORDER BY data_chegada DESC
LIMIT 5;


-- 26-28 EXPLAIN
EXPLAIN
SELECT
    id_paciente,
    nome,
    cpf
FROM pacientes
WHERE cpf = '111.111.111-11';


EXPLAIN
SELECT
    codigo,
    status,
    data_chegada
FROM senhas
WHERE status = 'aguardando'
ORDER BY data_chegada;


EXPLAIN
SELECT
    p.nome AS paciente,
    s.codigo AS senha,
    a.nome AS atendente,
    atd.inicio,
    atd.fim
FROM atendimentos atd
JOIN senhas s
    ON s.id_senha = atd.id_senha
LEFT JOIN pacientes p
    ON p.id_paciente = s.id_paciente
JOIN atendente a
    ON a.id_atendente = atd.id_atendente;