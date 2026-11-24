USE clinic_flow;

-- =========================================================
-- CONSULTAS SQL - CLINIC FLOW
-- Consultas básicas, relacionamentos, agregações,
-- subconsultas e análise de desempenho.
-- =========================================================


-- 1. CONSULTAS BÁSICAS

-- 1. Listar todos os pacientes cadastrados
SELECT *
FROM pacientes;

-- 2. Listar todos os atendentes
SELECT *
FROM atendentes;

-- 3. Listar todas as filas cadastradas
SELECT *
FROM filas;

-- 4. Listar todas as senhas geradas
SELECT *
FROM senhas;


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
    pacientes.nome AS paciente,
    senhas.codigo AS senha,
    senhas.status,
    senhas.data_chegada
FROM pacientes
INNER JOIN senhas
    ON pacientes.id_paciente = senhas.id_paciente;

-- 12. Mostrar as senhas e seus respectivos tipos de fila
SELECT
    senhas.codigo AS senha,
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
    senhas.codigo AS senha,
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
-- LEFT JOIN também apresenta atendentes que ainda não atenderam.
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

-- 18. Calcular o tempo de cada atendimento em minutos.
-- Considera somente atendimentos já finalizados.
SELECT
    id_atendimento,
    TIMESTAMPDIFF(MINUTE, inicio, fim) AS tempo_minutos
FROM atendimentos
WHERE fim IS NOT NULL;


-- =========================================================
-- 7. CONSULTAS AVANÇADAS: HAVING E SUBCONSULTAS
-- =========================================================

-- 19. Mostrar somente os atendentes que realizaram
-- pelo menos um atendimento.
-- HAVING filtra os grupos depois do GROUP BY.
SELECT
    atendentes.nome AS atendente,
    COUNT(atendimentos.id_atendimento) AS total_atendimentos
FROM atendentes
INNER JOIN atendimentos
    ON atendentes.id_atendente = atendimentos.id_atendente
GROUP BY
    atendentes.id_atendente,
    atendentes.nome
HAVING COUNT(atendimentos.id_atendimento) >= 1;

-- 20. Mostrar os atendimentos cuja duração é maior
-- que a duração média de todos os atendimentos finalizados.
-- A subconsulta calcula a média geral.
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

-- 21. Listar pacientes que possuem pelo menos uma senha.
-- EXISTS verifica se a subconsulta encontra algum registro relacionado.
SELECT
    pacientes.id_paciente,
    pacientes.nome
FROM pacientes
WHERE EXISTS (
    SELECT 1
    FROM senhas
    WHERE senhas.id_paciente = pacientes.id_paciente
);

-- 22. Listar pacientes que ainda não possuem nenhuma senha.
-- NOT EXISTS identifica a ausência de registros relacionados.
SELECT
    pacientes.id_paciente,
    pacientes.nome
FROM pacientes
WHERE NOT EXISTS (
    SELECT 1
    FROM senhas
    WHERE senhas.id_paciente = pacientes.id_paciente
);

-- 23. Mostrar as filas que possuem mais de uma senha.
SELECT
    filas.nome AS fila,
    COUNT(senhas.id_senha) AS total_senhas
FROM filas
INNER JOIN senhas
    ON filas.id_fila = senhas.id_fila
GROUP BY
    filas.id_fila,
    filas.nome
HAVING COUNT(senhas.id_senha) > 1;


-- =========================================================
-- 8. CONSULTAS COM CASE E LIMIT
-- =========================================================

-- 24. Exibir as senhas com uma descrição textual do status.
SELECT
    codigo,
    status,
    CASE
        WHEN status = 'Aguardando' THEN 'Aguardando atendimento'
        WHEN status = 'Em atendimento' THEN 'Atendimento em andamento'
        WHEN status = 'Finalizada' THEN 'Atendimento concluído'
        ELSE 'Status não identificado'
    END AS descricao_status
FROM senhas;

-- 25. Mostrar as cinco senhas mais recentes.
SELECT
    codigo,
    id_paciente,
    id_fila,
    data_chegada,
    status
FROM senhas
ORDER BY data_chegada DESC
LIMIT 5;


-- =========================================================
-- 9. ANÁLISE DE DESEMPENHO E OTIMIZAÇÃO
-- =========================================================

-- 26. Analisar o plano de execução da busca de paciente por CPF.
-- EXPLAIN permite verificar como o MySQL pretende executar a consulta.
EXPLAIN
SELECT
    id_paciente,
    nome,
    cpf
FROM pacientes
WHERE cpf = '111.111.111-11';

-- 27. Analisar o plano de execução da consulta de senhas por status.
EXPLAIN
SELECT
    codigo,
    status,
    data_chegada
FROM senhas
WHERE status = 'Aguardando'
ORDER BY data_chegada ASC;

-- 28. Analisar o plano de execução da consulta de histórico.
EXPLAIN
SELECT
    pacientes.nome AS paciente,
    senhas.codigo AS senha,
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

