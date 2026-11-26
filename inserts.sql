

USE clinic_flow;


-- Inserção de atendentes
INSERT INTO atendente(nome, dia_atendimento)
VALUES
    ('Roberto', 'Quarta-feira'),
    ('Ana', 'Segunda-feira'),
    ('Carlos', 'Sexta-feira')
ON DUPLICATE KEY UPDATE
    dia_atendimento = VALUES(dia_atendimento);


-- Inserção de filas
INSERT INTO filas(nome, prioridade)
VALUES
    ('Atendimento Prioritario', 1),
    ('Atendimento Geral', 2),
    ('Exames', 3)
ON DUPLICATE KEY UPDATE
    prioridade = VALUES(prioridade);


-- Inserção de pacientes
INSERT INTO pacientes(nome, cpf, telefone)
VALUES
    ('Ana Silva', '111.111.111-11', '(98) 99911-1111'),
    ('Carlos Santos', '222.222.222-22', '(98) 99922-2222'),
    ('Maria Oliveira', '333.333.333-33', '(98) 99933-3333'),
    ('Joao Costa', '444.444.444-44', '(98) 99944-4444'),
    ('Fernanda Lima', '555.555.555-55', '(98) 99955-5555')
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    telefone = VALUES(telefone);


-- Inserção de senhas
INSERT INTO senhas(codigo, id_paciente, id_fila, data_chegada, status)
SELECT
    d.codigo,
    p.id_paciente,
    f.id_fila,
    d.chegada,
    d.situacao
FROM (
    SELECT
        'A001' codigo,
        '111.111.111-11' cpf,
        'Atendimento Geral' fila,
        '2026-11-18 08:00:00' chegada,
        'finalizada' situacao

    UNION ALL

    SELECT
        'A002',
        '222.222.222-22',
        'Atendimento Geral',
        '2026-11-18 08:10:00',
        'aguardando'

    UNION ALL

    SELECT
        'P001',
        '333.333.333-33',
        'Atendimento Prioritario',
        '2026-11-18 08:15:00',
        'aguardando'

    UNION ALL

    SELECT
        'E001',
        '444.444.444-44',
        'Exames',
        '2026-11-18 08:20:00',
        'em atendimento'

    UNION ALL

    SELECT
        'A003',
        '555.555.555-55',
        'Atendimento Geral',
        '2026-11-18 08:30:00',
        'aguardando'
) d
JOIN pacientes p ON p.cpf = d.cpf
JOIN filas f ON f.nome = d.fila
ON DUPLICATE KEY UPDATE
    id_paciente = VALUES(id_paciente),
    id_fila = VALUES(id_fila),
    data_chegada = VALUES(data_chegada),
    status = VALUES(status);


-- Inserção de atendimentos
INSERT INTO atendimentos(id_senha, id_atendente, inicio, fim)
SELECT
    s.id_senha,
    a.id_atendente,

    CASE s.codigo
        WHEN 'A001' THEN '2026-11-18 08:05:00'
        ELSE '2026-11-18 08:25:00'
    END,

    CASE s.codigo
        WHEN 'A001' THEN '2026-11-18 08:25:00'
        ELSE NULL
    END

FROM senhas s
JOIN atendente a
    ON a.nome = CASE s.codigo
        WHEN 'A001' THEN 'Ana'
        ELSE 'Carlos'
    END

WHERE s.codigo IN ('A001', 'E001')

ON DUPLICATE KEY UPDATE
    id_atendente = VALUES(id_atendente),
    inicio = VALUES(inicio),
    fim = VALUES(fim);


-- Visualização dos dados inseridos
SELECT * FROM pacientes;
SELECT * FROM atendente;
SELECT * FROM filas;
SELECT * FROM senhas;
SELECT * FROM atendimentos;