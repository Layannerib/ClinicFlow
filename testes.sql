-- obs: executar primeiro o arquivo recursos avançados

USE clinic_flow;


-- ============================================================
-- 0. VERIFICAR OS REGISTROS NECESSARIOS
-- ============================================================

SET @id_paciente_teste := (
    SELECT MIN(id_paciente)
    FROM pacientes
);

SET @id_fila_teste := (
    SELECT MIN(id_fila)
    FROM filas
);

-- A tabela do banco chama-se atendente (singular).
SET @id_atendente_teste := (
    SELECT MIN(id_atendente)
    FROM atendente
);

SELECT
    @id_paciente_teste AS id_paciente_disponivel,
    @id_fila_teste AS id_fila_disponivel,
    @id_atendente_teste AS id_atendente_disponivel;


-- ============================================================
-- 1. TESTE DA PROCEDURE sp_gerar_senha
-- Deve inserir uma senha com status "Aguardando".
-- ============================================================

SET @codigo_teste_1 := CONCAT(
    'T',
    DATE_FORMAT(NOW(), '%H%i%s'),
    LPAD(FLOOR(RAND() * 1000), 3, '0')
);

-- Primeiro, CHAMAR a procedure para gerar a senha.
CALL sp_gerar_senha(
    @codigo_teste_1,
    @id_paciente_teste,
    @id_fila_teste
);

-- Depois, localizar o ID da senha criada.
-- COLLATE evita conflito entre collations diferentes.
SET @id_senha_teste_1 := (
    SELECT id_senha
    FROM senhas
    WHERE codigo COLLATE utf8mb4_unicode_ci =
          @codigo_teste_1 COLLATE utf8mb4_unicode_ci
    ORDER BY id_senha DESC
    LIMIT 1
);

-- Resultado esperado: uma senha com status "Aguardando".
SELECT
    id_senha,
    codigo,
    id_paciente,
    id_fila,
    data_chegada,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;


-- ============================================================
-- 2. TESTE DA PROCEDURE sp_registrar_atendimento
-- Deve inserir um atendimento e mudar a senha para
-- "Em atendimento".
-- ============================================================

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

-- Resultado esperado: status "Em atendimento".
SELECT
    id_senha,
    codigo,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;

-- Resultado esperado: atendimento criado, com fim = NULL.
SELECT *
FROM atendimentos
WHERE id_atendimento = @id_atendimento_teste_1;


-- ============================================================
-- 3. TESTE DA FUNCTION fn_tempo_atendimento
-- Antes de finalizar, deve retornar NULL.
-- ============================================================

SELECT
    id_atendimento,
    fn_tempo_atendimento(id_atendimento)
        AS tempo_minutos_antes_de_finalizar
FROM atendimentos
WHERE id_atendimento = @id_atendimento_teste_1;

-- Resultado esperado: NULL, pois fim ainda nao foi preenchido.


-- ============================================================
-- 4. TESTE DA TRIGGER trg_finalizar_senha
-- Ao preencher fim, a trigger deve mudar o status da senha
-- automaticamente para "Finalizada".
-- ============================================================

-- Define fim como 35 minutos depois do inicio para facilitar
-- a verificacao da function.
UPDATE atendimentos
SET fim = DATE_ADD(inicio, INTERVAL 35 MINUTE)
WHERE id_atendimento = @id_atendimento_teste_1;

-- Resultado esperado: status "Finalizada".
SELECT
    id_senha,
    codigo,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;

-- Resultado esperado: tempo_minutos = 35.
SELECT
    id_atendimento,
    fn_tempo_atendimento(id_atendimento)
        AS tempo_minutos_apos_finalizar
FROM atendimentos
WHERE id_atendimento = @id_atendimento_teste_1;


-- ============================================================
-- 5. TESTE DA VIEW vw_fila_pacientes
-- Deve exibir paciente, senha, fila, chegada e status.
-- ============================================================

SELECT *
FROM vw_fila_pacientes
WHERE senha COLLATE utf8mb4_unicode_ci =
      @codigo_teste_1 COLLATE utf8mb4_unicode_ci;


-- ============================================================
-- 6. TESTE DA VIEW vw_historico_atendimentos
-- Deve exibir paciente, senha, atendente, horarios e duracao.
-- ============================================================

SELECT *
FROM vw_historico_atendimentos
WHERE senha COLLATE utf8mb4_unicode_ci =
      @codigo_teste_1 COLLATE utf8mb4_unicode_ci;


-- ============================================================
-- 7. TESTE DA PROCEDURE sp_registrar_atendimento_transacao
-- Deve criar o atendimento e confirmar a transacao (COMMIT).
-- O status esperado da senha e "Em atendimento".
-- ============================================================

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
    WHERE codigo COLLATE utf8mb4_unicode_ci =
          @codigo_teste_2 COLLATE utf8mb4_unicode_ci
    ORDER BY id_senha DESC
    LIMIT 1
);

-- Registrar o atendimento usando a procedure transacional.
CALL sp_registrar_atendimento_transacao(
    @id_senha_teste_2,
    @id_atendente_teste
);

-- Resultado esperado: status "Em atendimento".
SELECT
    id_senha,
    codigo,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_2;

-- Resultado esperado: um atendimento associado a essa senha.
SELECT *
FROM atendimentos
WHERE id_senha = @id_senha_teste_2;


-- ============================================================
-- 8. CONFERENCIA FINAL DOS RECURSOS
-- Estas consultas mostram quais objetos estao criados.
-- ============================================================

-- Procedures.
SHOW PROCEDURE STATUS
WHERE Db = 'clinic_flow';

-- Function.
SHOW FUNCTION STATUS
WHERE Db = 'clinic_flow';

-- Trigger.
SHOW TRIGGERS
FROM clinic_flow;

-- Views.
SHOW FULL TABLES
WHERE Table_type = 'VIEW';
