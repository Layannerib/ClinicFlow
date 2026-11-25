-- Testes de procedures, function, trigger e views.
-- Obs.: executar primeiro o arquivo recursos_avancados
-- Pre-requisito: executar tambem schema.sql e inserts.sql para ter dados de teste.

USE clinic_flow;


-- Definicao dos IDs utilizados nos testes
SET @id_paciente_teste = (SELECT MIN(id_paciente) FROM pacientes);
SET @id_fila_teste = (SELECT MIN(id_fila) FROM filas);
SET @id_atendente_teste = (SELECT MIN(id_atendente) FROM atendente);

SELECT
    @id_paciente_teste AS id_paciente_disponivel,
    @id_fila_teste AS id_fila_disponivel,
    @id_atendente_teste AS id_atendente_disponivel;


-- 1. Gerar senha sem paciente associado
SET @codigo_teste_1 = CONCAT(
    'T',
    UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 9))
);

CALL sp_gerar_senha(
    @codigo_teste_1,
    @id_fila_teste
);

SET @id_senha_teste_1 = (
    SELECT id_senha
    FROM senhas
    WHERE CAST(codigo AS BINARY) = CAST(@codigo_teste_1 AS BINARY)
);

-- Conferir que a senha foi criada sem paciente e aguardando
SELECT
    id_senha,
    codigo,
    id_paciente,
    id_fila,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;


-- 2. Associar paciente a senha gerada
CALL sp_associar_paciente_senha(
    @id_senha_teste_1,
    @id_paciente_teste
);

-- Conferir a associacao do paciente
SELECT
    id_senha,
    codigo,
    id_paciente,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;


-- 3. Registrar atendimento
CALL sp_registrar_atendimento(
    @id_senha_teste_1,
    @id_atendente_teste
);

SET @id_atendimento_teste_1 = (
    SELECT id_atendimento
    FROM atendimentos
    WHERE id_senha = @id_senha_teste_1
);

SELECT *
FROM atendimentos
WHERE id_atendimento = @id_atendimento_teste_1;


-- 4. Function antes de finalizar: deve retornar NULL
SELECT fn_tempo_atendimento(@id_atendimento_teste_1)
AS tempo_antes_de_finalizar;


-- 5. Finalizar atendimento
-- O trigger deve alterar o status da senha para 'finalizada'.
-- A function deve retornar 35 minutos.
UPDATE atendimentos
SET fim = DATE_ADD(inicio, INTERVAL 35 MINUTE)
WHERE id_atendimento = @id_atendimento_teste_1;

SELECT
    id_senha,
    codigo,
    status
FROM senhas
WHERE id_senha = @id_senha_teste_1;

SELECT fn_tempo_atendimento(@id_atendimento_teste_1)
AS tempo_apos_finalizar;


-- 6. Testar a view da fila e a view do historico
SELECT *
FROM vw_fila_pacientes
WHERE CAST(senha AS BINARY) = CAST(@codigo_teste_1 AS BINARY);

SELECT *
FROM vw_historico_atendimentos
WHERE CAST(senha AS BINARY) = CAST(@codigo_teste_1 AS BINARY);


-- 7. Gerar outra senha e deixa-la sem paciente associado
SET @codigo_sem_paciente = CONCAT(
    'N',
    UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 9))
);

CALL sp_gerar_senha(
    @codigo_sem_paciente,
    @id_fila_teste
);

SET @id_senha_sem_paciente = (
    SELECT id_senha
    FROM senhas
    WHERE CAST(codigo AS BINARY) = CAST(@codigo_sem_paciente AS BINARY)
);

-- Conferir que a senha continua sem paciente e aguardando
SELECT
    id_senha,
    codigo,
    id_paciente,
    status
FROM senhas
WHERE id_senha = @id_senha_sem_paciente;

-- A view deve exibir a senha mesmo sem paciente associado.
SELECT *
FROM vw_fila_pacientes
WHERE CAST(senha AS BINARY) = CAST(@codigo_sem_paciente AS BINARY);


-- 8. Testes negativos: operacoes que devem ser impedidas
-- Os erros esperados sao capturados para que o restante do arquivo continue executando.

DROP PROCEDURE IF EXISTS sp_testes_negativos_temp;

DELIMITER //

CREATE PROCEDURE sp_testes_negativos_temp()
BEGIN
    DECLARE v_id_senha_cancelada INT;
    DECLARE v_id_senha_atendente INT;
    DECLARE v_id_senha_repetida INT;

    DECLARE v_codigo_cancelada VARCHAR(10);
    DECLARE v_codigo_atendente VARCHAR(10);
    DECLARE v_codigo_repetida VARCHAR(10);

    -- Preparar uma senha cancelada, associada a um paciente.
    SET v_codigo_cancelada = CONCAT(
        'C',
        UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 9))
    );

    CALL sp_gerar_senha(v_codigo_cancelada, @id_fila_teste);

    SELECT id_senha
    INTO v_id_senha_cancelada
    FROM senhas
    WHERE CAST(codigo AS BINARY) = CAST(v_codigo_cancelada AS BINARY);

    CALL sp_associar_paciente_senha(v_id_senha_cancelada, @id_paciente_teste);

    UPDATE senhas
    SET status = 'cancelada'
    WHERE id_senha = v_id_senha_cancelada;


    -- Preparar uma senha valida para testar atendente inexistente.
    SET v_codigo_atendente = CONCAT(
        'A',
        UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 9))
    );

    CALL sp_gerar_senha(v_codigo_atendente, @id_fila_teste);

    SELECT id_senha
    INTO v_id_senha_atendente
    FROM senhas
    WHERE CAST(codigo AS BINARY) = CAST(v_codigo_atendente AS BINARY);

    CALL sp_associar_paciente_senha(v_id_senha_atendente, @id_paciente_teste);


    -- Preparar uma senha valida para testar tentativa de atendimento duplicado.
    SET v_codigo_repetida = CONCAT(
        'R',
        UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 9))
    );

    CALL sp_gerar_senha(v_codigo_repetida, @id_fila_teste);

    SELECT id_senha
    INTO v_id_senha_repetida
    FROM senhas
    WHERE CAST(codigo AS BINARY) = CAST(v_codigo_repetida AS BINARY);

    CALL sp_associar_paciente_senha(v_id_senha_repetida, @id_paciente_teste);


    -- Teste negativo 1: codigo de senha duplicado.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_gerar_senha(@codigo_teste_1, @id_fila_teste);

        SELECT
            'Codigo de senha duplicado' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 2: fila inexistente.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_gerar_senha(
            CONCAT('F', UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 9))),
            -1
        );

        SELECT
            'Fila inexistente' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 3: associar paciente inexistente.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_associar_paciente_senha(@id_senha_sem_paciente, -1);

        SELECT
            'Paciente inexistente' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 4: associar outro paciente a uma senha que ja possui paciente.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_associar_paciente_senha(@id_senha_teste_1, @id_paciente_teste);

        SELECT
            'Associacao duplicada de paciente' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 5: iniciar atendimento sem paciente associado.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_registrar_atendimento(
            @id_senha_sem_paciente,
            @id_atendente_teste
        );

        SELECT
            'Atendimento sem paciente associado' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 6: iniciar atendimento com senha finalizada.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_registrar_atendimento(
            @id_senha_teste_1,
            @id_atendente_teste
        );

        SELECT
            'Atendimento com senha finalizada' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 7: iniciar atendimento com senha cancelada.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_registrar_atendimento(
            v_id_senha_cancelada,
            @id_atendente_teste
        );

        SELECT
            'Atendimento com senha cancelada' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 8: registrar atendimento com atendente inexistente.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_registrar_atendimento(v_id_senha_atendente, -1);

        SELECT
            'Atendente inexistente' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 9: registrar atendimento para senha inexistente.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_registrar_atendimento(-1, @id_atendente_teste);

        SELECT
            'Senha inexistente' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Teste negativo 10: tentar registrar dois atendimentos para a mesma senha.
    BEGIN
        DECLARE v_erro BOOLEAN DEFAULT FALSE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_erro = TRUE;

        CALL sp_registrar_atendimento(
            v_id_senha_repetida,
            @id_atendente_teste
        );

        SET v_erro = FALSE;

        CALL sp_registrar_atendimento(
            v_id_senha_repetida,
            @id_atendente_teste
        );

        SELECT
            'Segundo atendimento para a mesma senha' AS teste,
            IF(v_erro, 'OK - erro esperado', 'FALHA - deveria impedir') AS resultado;
    END;


    -- Conferir os status finais dos registros usados nos testes negativos.
    SELECT
        id_senha,
        codigo,
        status,
        id_paciente
    FROM senhas
    WHERE id_senha IN (
        v_id_senha_cancelada,
        v_id_senha_atendente,
        v_id_senha_repetida
    );
END //

DELIMITER ;

CALL sp_testes_negativos_temp();

DROP PROCEDURE IF EXISTS sp_testes_negativos_temp;


-- Conferencia dos objetos criados
SHOW PROCEDURE STATUS
WHERE Db = 'clinic_flow';

SHOW FUNCTION STATUS
WHERE Db = 'clinic_flow';

SHOW TRIGGERS FROM clinic_flow;

SHOW FULL TABLES
FROM clinic_flow
WHERE Table_type = 'VIEW';
