-- Recursos avancados 

USE clinic_flow;

DELIMITER //

-- Procedure: gerar senha sem associar paciente
CREATE PROCEDURE sp_gerar_senha(
    IN p_codigo VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_id_fila INT
)
BEGIN
    DECLARE v_codigo VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

    SET v_codigo = TRIM(p_codigo);

    IF p_codigo IS NULL OR v_codigo = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Codigo da senha obrigatorio.';
    END IF;

    IF p_id_fila IS NULL OR NOT EXISTS (
        SELECT 1 FROM filas WHERE id_fila = p_id_fila
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Fila nao encontrada.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM senhas WHERE codigo = v_codigo
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Codigo de senha ja existe.';
    END IF;

    INSERT INTO senhas (
        codigo, id_paciente, id_fila, data_chegada, status
    )
    VALUES (
        v_codigo, NULL, p_id_fila, NOW(), 'aguardando'
    );
END //

-- Procedure: associar paciente a uma senha gerada
CREATE PROCEDURE sp_associar_paciente_senha(
    IN p_id_senha INT,
    IN p_id_paciente INT
)
BEGIN
    DECLARE v_paciente_atual INT DEFAULT NULL;
    DECLARE v_status VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL;
    DECLARE v_encontrada BOOLEAN DEFAULT TRUE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_encontrada = FALSE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT id_paciente, status
    INTO v_paciente_atual, v_status
    FROM senhas
    WHERE id_senha = p_id_senha
    FOR UPDATE;

    IF NOT v_encontrada THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Senha nao encontrada.';
    END IF;

    IF p_id_paciente IS NULL OR NOT EXISTS (
        SELECT 1 FROM pacientes WHERE id_paciente = p_id_paciente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Paciente nao encontrado.';
    END IF;

    IF v_paciente_atual IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esta senha ja possui um paciente associado.';
    END IF;

    IF v_status <> 'aguardando' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Somente senhas aguardando podem receber um paciente.';
    END IF;

    UPDATE senhas
    SET id_paciente = p_id_paciente
    WHERE id_senha = p_id_senha;

    COMMIT;
END //

-- Procedure: registrar atendimento com transacao
CREATE PROCEDURE sp_registrar_atendimento(
    IN p_id_senha INT,
    IN p_id_atendente INT
)
BEGIN
    DECLARE v_paciente INT DEFAULT NULL;
    DECLARE v_status VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL;
    DECLARE v_encontrada BOOLEAN DEFAULT TRUE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_encontrada = FALSE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT id_paciente, status
    INTO v_paciente, v_status
    FROM senhas
    WHERE id_senha = p_id_senha
    FOR UPDATE;

    IF NOT v_encontrada THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Senha nao encontrada.';
    END IF;

    IF v_paciente IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Senha sem paciente associado.';
    END IF;

    IF v_status <> 'aguardando' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Senha nao esta aguardando atendimento.';
    END IF;

    IF p_id_atendente IS NULL OR NOT EXISTS (
        SELECT 1 FROM atendente WHERE id_atendente = p_id_atendente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Atendente nao encontrado.';
    END IF;

    INSERT INTO atendimentos (id_senha, id_atendente, inicio, fim)
    VALUES (p_id_senha, p_id_atendente, NOW(), NULL);

    UPDATE senhas
    SET status = 'em atendimento'
    WHERE id_senha = p_id_senha;

    COMMIT;
END //

-- Function: calcular tempo de atendimento
CREATE FUNCTION fn_tempo_atendimento(
    p_id_atendimento INT
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_tempo INT DEFAULT NULL;

    SELECT TIMESTAMPDIFF(MINUTE, inicio, fim)
    INTO v_tempo
    FROM atendimentos
    WHERE id_atendimento = p_id_atendimento;

    RETURN v_tempo;
END //

-- Trigger: finalizar senha
CREATE TRIGGER trg_finalizar_senha
AFTER UPDATE ON atendimentos
FOR EACH ROW
BEGIN
    IF OLD.fim IS NULL AND NEW.fim IS NOT NULL THEN
        UPDATE senhas
        SET status = 'finalizada'
        WHERE id_senha = NEW.id_senha;
    END IF;
END //

DELIMITER ;

-- View: fila de pacientes
CREATE VIEW vw_fila_pacientes AS
SELECT
    p.nome AS paciente,
    s.codigo AS senha,
    f.nome AS fila,
    f.prioridade,
    s.data_chegada,
    s.status
FROM senhas s
LEFT JOIN pacientes p
    ON p.id_paciente = s.id_paciente
JOIN filas f
    ON f.id_fila = s.id_fila;

-- View: historico de atendimentos
CREATE VIEW vw_historico_atendimentos AS
SELECT
    p.nome AS paciente,
    s.codigo AS senha,
    a.nome AS atendente,
    atd.inicio,
    atd.fim,
    TIMESTAMPDIFF(MINUTE, atd.inicio, atd.fim) AS tempo_minutos
FROM atendimentos atd
JOIN senhas s
    ON s.id_senha = atd.id_senha
LEFT JOIN pacientes p
    ON p.id_paciente = s.id_paciente
JOIN atendente a
    ON a.id_atendente = atd.id_atendente;

-- Conferencia dos objetos criados
SHOW PROCEDURE STATUS WHERE Db = 'clinic_flow';
SHOW FUNCTION STATUS WHERE Db = 'clinic_flow';
SHOW TRIGGERS FROM clinic_flow;
SHOW FULL TABLES FROM clinic_flow WHERE Table_type = 'VIEW';
