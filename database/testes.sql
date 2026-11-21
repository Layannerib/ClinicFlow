
USE clinic_flow;

-- Gera uma nova senha para o paciente 1
-- na fila 1.

CALL sp_gerar_senha('A004', 1, 1);

-- Verificar se a senha foi cadastrada
SELECT * FROM senhas
WHERE codigo = 'A004';

-- Registra atendimento da senha 5
-- pelo atendente 1.

CALL sp_registrar_atendimento(5, 1);

-- Verificar o atendimento cadastrado
SELECT * FROM atendimentos
WHERE id_senha = 5;

-- Calcula o tempo do atendimento 1 em minutos.

SELECT fn_tempo_atendimento(1) AS tempo_minutos;

-- Finaliza o atendimento de ID 2.
-- O trigger deverá atualizar o status da senha.

UPDATE atendimentos
SET fim = NOW()
WHERE id_atendimento = 2;

-- Conferir se o status foi atualizado
SELECT *
FROM senhas
WHERE id_senha = 4;

SELECT * FROM vw_fila_pacientes;

SELECT * FROM vw_historico_atendimentos;

-- Registra um atendimento utilizando transacao.
-- O COMMIT confirma as alteracoes e o ROLLBACK
-- desfaz as alteracoes caso ocorra um erro.

CALL sp_registrar_atendimento_transacao(3, 2);

-- Conferir o registro
SELECT *
FROM atendimentos
WHERE id_senha = 3;
