# Regras de Negócio — ClinicFlow

## 1. Cadastro de Pacientes

**RN01 — Identificação do paciente:** Todo paciente deverá possuir um cadastro com identificação única no sistema.

**RN02 — CPF único:** Não será permitido cadastrar dois pacientes com o mesmo CPF.

**RN03 — Dados obrigatórios:** Para realizar o cadastro, deverão ser informados o nome e o CPF do paciente.

## 2. Cadastro de Funcionários

**RN04 — Identificação do funcionário:** Todo funcionário cadastrado deverá possuir um identificador único.

**RN05 — Responsabilidade:** Cada atendimento deverá estar associado ao funcionário responsável por realizá-lo.

## 3. Gerenciamento de Senhas e Filas

**RN06 — Geração de senha:** Toda vez que um paciente entrar na fila, deverá ser gerada uma nova senha.

**RN07 — Identificação da senha:** Cada senha deverá possuir um código único.

**RN08 — Vínculo da senha:** Toda senha deverá estar vinculada a um paciente e a uma fila.

**RN09 — Classificação:** Cada senha deverá ser classificada como atendimento normal ou prioritário.

**RN10 — Ordem de atendimento:** Os pacientes da fila normal deverão ser chamados conforme a ordem de chegada, respeitando as prioridades previstas na legislação.

**RN11 — Atendimento prioritário:** Os pacientes com direito à prioridade deverão ser atendidos conforme as categorias e a ordem estabelecidas pela legislação aplicável.

**RN12 — Cancelamento:** Uma senha cancelada deverá deixar de participar da fila de espera.

## 4. Gerenciamento dos Atendimentos

**RN13 — Chamada de pacientes:** Somente senhas com status de aguardando poderão ser chamadas.

**RN14 — Início do atendimento:** O atendimento somente poderá ser iniciado após a chamada da senha correspondente.

**RN15 — Registro do atendimento:** Todo atendimento deverá possuir uma data e um horário de início, além de estar associado a um funcionário.

**RN16 — Finalização:** Um atendimento somente poderá ser finalizado se tiver sido iniciado anteriormente.

**RN17 — Registro do término:** Ao finalizar um atendimento, o sistema deverá registrar a data e o horário de término.

**RN18 — Impedimento de duplicidade:** Uma mesma senha não poderá possuir mais de um atendimento ativo simultaneamente.

## 5. Controle de Status

**RN19 — Status das senhas:** As senhas poderão apresentar os seguintes status:
- AGUARDANDO
- CHAMADA
- EM_ATENDIMENTO
- FINALIZADA
- CANCELADA

**RN20 — Alteração de status:** O status da senha deverá ser atualizado conforme as etapas do atendimento.

**RN21 — Senhas finalizadas ou canceladas:** Senhas finalizadas ou canceladas não poderão retornar à fila de espera. Caso o paciente precise de um novo atendimento, deverá receber uma nova senha.

## 6. Cálculo do Tempo de Espera

**RN22 — Tempo de espera:** O tempo de espera de cada paciente deverá ser calculado pela diferença entre o horário de chegada e o horário de início do atendimento.

**RN23 — Média de espera:** O sistema deverá calcular o tempo médio de espera considerando os atendimentos que possuam os horários de chegada e início registrados.
