USE clinic_flow;

INSERT INTO pacientes (nome, cpf, telefone) VALUES
('Ana Silva', '111.111.111-11', '(98) 99911-1111'),
('Carlos Santos', '222.222.222-22', '(98) 99922-2222'),
('Maria Oliveira', '333.333.333-33', '(98) 99933-3333'),
('João Costa', '444.444.444-44', '(98) 99944-4444'),
('Fernanda Lima', '555.555.555-55', '(98) 99955-5555');

INSERT INTO atendente (nome, dia_atendimento) VALUES
('Roberto', 'Quarta-feira'),
('Ana', 'Segunda-feira'),
('Carlos', 'Sexta-feira');

INSERT INTO filas (nome, prioridade) VALUES
('Atendimento Geral', 1),
('Atendimento Prioritário', 2),
('Exames', 3);

INSERT INTO senhas
(codigo, id_paciente, id_fila, data_chegada, status)
VALUES
('A001', 1, 1, '2026-11-18 08:00:00', 'Aguardando'),
('A002', 2, 1, '2026-11-18 08:10:00', 'Aguardando'),
('P001', 3, 2, '2026-11-18 08:15:00', 'Aguardando'),
('E001', 4, 3, '2026-11-18 08:20:00', 'Aguardando'),
('A003', 5, 1, '2026-11-18 08:30:00', 'Aguardando');

INSERT INTO atendimentos
(id_senha, id_atendente, inicio, fim)
VALUES
(1, 2, '2026-11-18 08:05:00', '2026-11-18 08:25:00'),
(4, 3, '2026-11-18 08:25:00', NULL);

UPDATE senhas
SET status = 'Finalizada'
WHERE id_senha = 1;

UPDATE senhas
SET status = 'Em atendimento'
WHERE id_senha = 4;

