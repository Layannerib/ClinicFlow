-- ============================================================
-- ARQUIVO DE TESTES - CLINIC FLOW
-- Testes dos recursos avancados do banco de dados
-- ============================================================

USE clinic_flow;

-- ------------------------------------------------------------
-- 0. VERIFICAR OS REGISTROS NECESSARIOS
-- ------------------------------------------------------------

SET @id_paciente_teste := (
    SELECT MIN(id_paciente) FROM pacientes
);

SET @id_fila_teste := (
    SELECT MIN(id_fila) FROM filas
);

SET @id_atendente_teste := (
    SELECT MIN(id_atendente) FROM atendente
);

SELECT
    @id_paciente_teste AS id_paciente,
    @id_fila_teste AS id_fila,
    @id_atendente_teste AS id_atendente;


-- ------------------------------------------------------------
-- 1. TESTE DA PROCEDURE sp_gerar_senha
-- Gera uma nova senha para um paciente.
-- Status esperado: Aguardando.
-- ------------------------------------------------------------

SET @codigo_teste_1 := CONCAT(
    'T',
    DATE_FORMAT(NOW(), '%H%i%s'),
    LPAD(FLOOR(RAND() * 1000), 3, '0')
);


SET @id_senha_teste_1 := (
    SELECT id_senha
    FROM senhas
    WHERE codigo = @codigo_teste_1
    ORDER BY id_senha DESC
    LIMIT 1
);

-- Verificar se a senha foi cadastrada.

SELECT *
FROM senhas
WHERE id_senha = @id_senha_teste_1;


-- ------------------------------------------------------------
-- 2. TESTE DA PROCEDURE sp_registrar_atendimento
-- Registra o inicio de um atendimento.
-- Status esperado: Em atendimento.
-- ------------------------------------------------------------

CALL sp_registrar_atendimento(
    @id_senha_teste_1,
    @id_atendente_teste
);

SET @id_atendimento_teste_1 := (
    SELECT id_atendimento
    FROM atendimentos
    WHERE id_senha = @id_senha_teste_1
    ORDER BY id_atendimento DESC
    LIMIT 1
);

-- Verificar o status da senha.

SELECT
    id_senha,
    codigo,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;

-- Verificar o atendimento cadastrado.

SELECT *
FROM atendimentos
WHERE id_atendimento = @id_atendimento_teste_1;


-- ------------------------------------------------------------
-- 3. TESTE DA FUNCTION fn_tempo_atendimento
-- Antes de finalizar, deve retornar NULL.
-- ------------------------------------------------------------

SELECT
    id_atendimento,
    fn_tempo_atendimento(id_atendimento)
        AS tempo_minutos_antes_de_finalizar
FROM atendimentos
WHERE id_atendimento = @id_atendimento_teste_1;


-- ------------------------------------------------------------
-- 4. TESTE DA TRIGGER trg_finalizar_senha
-- Ao informar o fim do atendimento, a trigger deve
-- atualizar automaticamente o status para Finalizada.
-- ------------------------------------------------------------

UPDATE atendimentos
SET fim = DATE_ADD(inicio, INTERVAL 35 MINUTE)
WHERE id_atendimento = @id_atendimento_teste_1;

-- Verificar se o status mudou para Finalizada.

SELECT
    id_senha,
    codigo,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;

-- Verificar a duracao do atendimento.
-- Resultado esperado: 35 minutos.

SELECT
    id_atendimento,
    fn_tempo_atendimento(id_atendimento)
        AS tempo_minutos_apos_finalizar
FROM atendimentos
WHERE id_atendimento = @id_atendimento_teste_1;


-- ------------------------------------------------------------
-- 5. TESTE DA VIEW vw_fila_pacientes
-- Consulta os pacientes e suas respectivas senhas.
-- ------------------------------------------------------------

SELECT *
FROM vw_fila_pacientes
WHERE senha = @codigo_teste_1;


-- ------------------------------------------------------------
-- 6. TESTE DA VIEW vw_historico_atendimentos
-- Consulta o historico dos atendimentos.
-- ------------------------------------------------------------

SELECT *
FROM vw_historico_atendimentos
WHERE senha = @codigo_teste_1;


-- ------------------------------------------------------------
-- 7. TESTE DA PROCEDURE COM TRANSACAO
-- sp_registrar_atendimento_transacao
-- ------------------------------------------------------------

SET @codigo_teste_2 := CONCAT(
    'U',
    DATE_FORMAT(NOW(), '%H%i%s'),
    LPAD(FLOOR(RAND() * 1000), 3, '0')
);

-- Gerar uma segunda senha.

CALL sp_gerar_senha(
    @codigo_teste_2,
    @id_paciente_teste,
    @id_fila_teste
);

SET @id_senha_teste_2 := (
    SELECT id_senha
    FROM senhas
    WHERE codigo = @codigo_teste_2
    ORDER BY id_senha DESC
    LIMIT 1
);

-- Registrar atendimento utilizando transacao.

CALL sp_registrar_atendimento_transacao(
    @id_senha_teste_2,
    @id_atendente_teste
);

-- Verificar o status da senha.

SELECT
    id_senha,
    codigo,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_2;

-- Verificar o atendimento cadastrado.

SELECT *
FROM atendimentos
WHERE id_senha = @id_senha_teste_2;


-- ------------------------------------------------------------
-- 8. CONFERENCIA FINAL DOS RECURSOS
-- ------------------------------------------------------------

-- Consultar procedures.

SHOW PROCEDURE STATUS
WHERE Db = 'clinic_flow';

-- Consultar functions.

SHOW FUNCTION STATUS
WHERE Db = 'clinic_flow';

-- Consultar triggers.

SHOW TRIGGERS
FROM clinic_flow;

-- Consultar views.

SHOW FULL TABLES
WHERE Table_type = 'VIEW';


