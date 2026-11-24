

USE clinic_flow;


-- PROCEDURES, FUNCTION E TRIGGER


DELIMITER //

-- ------------------------------------------------------------
-- PROCEDURE 1: Gerar uma nova senha para um paciente.
-- Recebe o codigo da senha, o paciente e a fila.
-- Registra automaticamente a data e hora da chegada.
-- ------------------------------------------------------------

CREATE PROCEDURE sp_gerar_senha(
    IN p_codigo VARCHAR(10),
    IN p_id_paciente INT,
    IN p_id_fila INT
)
BEGIN
    INSERT INTO senhas (
        codigo,
        id_paciente,
        id_fila,
        data_chegada,
        status
    )
    VALUES (
        p_codigo,
        p_id_paciente,
        p_id_fila,
        NOW(),
        'Aguardando'
    );
END //


-- ------------------------------------------------------------
-- PROCEDURE 2: Registrar o inicio de um atendimento.
-- Registra o atendimento e atualiza o status da senha
-- para "Em atendimento".
-- ------------------------------------------------------------

CREATE PROCEDURE sp_registrar_atendimento(
    IN p_id_senha INT,
    IN p_id_atendente INT
)
BEGIN
    INSERT INTO atendimentos (
        id_senha,
        id_atendente,
        inicio,
        fim
    )
    VALUES (
        p_id_senha,
        p_id_atendente,
        NOW(),
        NULL
    );

    UPDATE senhas
    SET status = 'Em atendimento'
    WHERE id_senha = p_id_senha;
END //


-- ------------------------------------------------------------
-- FUNCTION: Recebe o ID do atendimento e retorna a duracao
-- em minutos. Retorna NULL se ainda nao estiver finalizado.
-- ------------------------------------------------------------

CREATE FUNCTION fn_tempo_atendimento(
    p_id_atendimento INT
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_tempo INT;

    SELECT TIMESTAMPDIFF(MINUTE, inicio, fim)
    INTO v_tempo
    FROM atendimentos
    WHERE id_atendimento = p_id_atendimento;

    RETURN v_tempo;
END //


-- ------------------------------------------------------------
-- TRIGGER: Quando o atendimento recebe uma data de fim,
-- o status da senha passa automaticamente para "Finalizada".
-- ------------------------------------------------------------

CREATE TRIGGER trg_finalizar_senha
AFTER UPDATE ON atendimentos
FOR EACH ROW
BEGIN
    IF OLD.fim IS NULL AND NEW.fim IS NOT NULL THEN
        UPDATE senhas
        SET status = 'Finalizada'
        WHERE id_senha = NEW.id_senha;
    END IF;
END //

DELIMITER ;


-- ============================================================
-- VIEWS
-- ============================================================

-- ------------------------------------------------------------
-- VIEW 1: Visualizar fila de pacientes.
-- Mostra o paciente, sua senha, a fila, o horario de chegada
-- e o status.
-- ------------------------------------------------------------

CREATE VIEW vw_fila_pacientes AS
SELECT
    pacientes.nome AS paciente,
    senhas.codigo AS senha,
    filas.nome AS fila,
    senhas.data_chegada,
    senhas.status
FROM senhas
INNER JOIN pacientes
    ON senhas.id_paciente = pacientes.id_paciente
INNER JOIN filas
    ON senhas.id_fila = filas.id_fila;


-- ------------------------------------------------------------
-- VIEW 2: Historico de atendimentos.
-- Mostra o paciente, o atendente, os horarios e a duracao.
--
-- CORRECAO: no banco, a tabela se chama "atendente"
-- (singular), e nao "atendentes" (plural).
-- ------------------------------------------------------------

CREATE VIEW vw_historico_atendimentos AS
SELECT
    pacientes.nome AS paciente,
    senhas.codigo AS senha,
    atendente.nome AS atendente,
    atendimentos.inicio,
    atendimentos.fim,
    TIMESTAMPDIFF(
        MINUTE,
        atendimentos.inicio,
        atendimentos.fim
    ) AS tempo_minutos
FROM atendimentos
INNER JOIN senhas
    ON atendimentos.id_senha = senhas.id_senha
INNER JOIN pacientes
    ON senhas.id_paciente = pacientes.id_paciente
INNER JOIN atendente
    ON atendimentos.id_atendente = atendente.id_atendente;


-- TRANSACAO


-- ------------------------------------------------------------
-- PROCEDURE: Registrar atendimento utilizando transacao.
-- Demonstra START TRANSACTION, COMMIT e ROLLBACK.
-- Se ocorrer algum erro SQL, as operacoes sao desfeitas.
-- ------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE sp_registrar_atendimento_transacao(
    IN p_id_senha INT,
    IN p_id_atendente INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Insere o atendimento.
    INSERT INTO atendimentos (
        id_senha,
        id_atendente,
        inicio,
        fim
    )
    VALUES (
        p_id_senha,
        p_id_atendente,
        NOW(),
        NULL
    );

    -- Atualiza o status da senha.
    UPDATE senhas
    SET status = 'Em atendimento'
    WHERE id_senha = p_id_senha;

    COMMIT;
END //

DELIMITER ;


-- CONFERENCIA DOS RECURSOS CRIADOS

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

