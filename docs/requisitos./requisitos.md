# Requisitos do Sistema — ClinicFlow

## 1. Requisitos Funcionais (RF)

Os requisitos funcionais descrevem as funcionalidades que o sistema deverá oferecer.

| Código | Requisito | Descrição |
|---|---|---|
| RF01 | Cadastrar pacientes | O sistema deverá permitir o cadastro de pacientes, armazenando nome, CPF e telefone. |
| RF02 | Consultar pacientes | O sistema deverá permitir a consulta dos pacientes cadastrados. |
| RF03 | Cadastrar funcionários | O sistema deverá permitir o cadastro dos funcionários responsáveis pelos atendimentos. |
| RF04 | Gerar senhas | O sistema deverá gerar uma senha para cada paciente que entrar na fila de atendimento. |
| RF05 | Classificar fila | O sistema deverá permitir a classificação das senhas em atendimento normal ou prioritário. |
| RF06 | Consultar fila | O sistema deverá exibir os pacientes que estão aguardando atendimento, respeitando as regras de prioridade. |
| RF07 | Chamar próximo paciente | O sistema deverá permitir que o funcionário chame o próximo paciente da fila. |
| RF08 | Iniciar atendimento | O sistema deverá registrar o início do atendimento de um paciente chamado. |
| RF09 | Finalizar atendimento | O sistema deverá permitir que o funcionário finalize o atendimento, registrando a data e o horário de término. |
| RF10 | Consultar histórico | O sistema deverá permitir a consulta dos atendimentos realizados. |
| RF11 | Calcular tempo médio de espera | O sistema deverá calcular o tempo médio de espera dos pacientes antes do início do atendimento. |
| RF12 | Cancelar senha | O sistema deverá permitir o cancelamento de uma senha, retirando-a da fila de espera. |

## 2. Requisitos Não Funcionais (RNF)

Os requisitos não funcionais descrevem características e condições que o sistema deverá atender.

| Código | Requisito | Descrição |
|---|---|---|
| RNF01 | Banco de dados | O sistema deverá utilizar o MySQL para armazenar e gerenciar os dados. |
| RNF02 | Integridade dos dados | O banco de dados deverá utilizar chaves primárias, estrangeiras e restrições para garantir a consistência das informações. |
| RNF03 | Segurança | O sistema deverá restringir o acesso às funcionalidades administrativas aos funcionários autorizados. |
| RNF04 | Usabilidade | O sistema deverá apresentar funcionalidades organizadas e de fácil compreensão para os usuários. |
| RNF05 | Desempenho | O sistema deverá realizar operações de cadastro, consulta e atualização das filas sem atrasos desnecessários. |
| RNF06 | Manutenibilidade | O código deverá ser organizado para facilitar futuras correções e melhorias. |
| RNF07 | Confiabilidade | O sistema deverá evitar registros duplicados e inconsistências durante as operações de atendimento. |
| RNF08 | Tecnologia | O backend deverá ser desenvolvido em Python utilizando o framework FastAPI. |
