# RelatoSeg: uma arquitetura de referência distribuída para orquestração de agentes de IA via MCP aplicada à geração automatizada de relatórios de sinistros de seguros

*Projeto Integrado — Relatório Técnico*

**Sistema:** `RelatoSeg — Geração Automatizada de Relatórios de Análise de Sinistros` *(instância do domínio de seguros; a arquitetura subjacente é apresentada como referência arquitetural multi-domínio — podendo servir de inspiração, base ou template para outros sistemas, além de admitir extensão do próprio RelatoSeg a novos domínios de negócio via novo MCP Server, sem alterar o MCP Host — RF15/RNF02)*
**Domínio aplicado:** `Análise de Sinistros de Seguros`
**Aluno(s):** José Ribamar Bacelar Netto
**Belo Horizonte, agosto de 2026**

> Estrutura baseada no template oficial (`doc/puc/Template RelatorioTecnico ASD simpl.docx`) e no
> Regulamento do Projeto Integrado — pós ASD 2025 (`doc/puc/Regulamento do Projeto Integrado - pós ASD 2025.pdf`).
> Este documento segue as **duas etapas** vigentes (não a versão de 3 etapas dos arquivos do Notion, que
> parece ser de uma oferta anterior do curso — a confirmar com o professor).

> **Repositório do projeto:** o código-fonte, os modelos C4 (Structurizr) e os diagramas de componentes (PlantUML) usados neste relatório estão versionados em [github.com/bacelarnetto/tcc-engenharia-software](https://github.com/bacelarnetto/tcc-engenharia-software) — incluindo os artefatos editáveis (`doc/c4/`, `doc/uml/`) e o próprio relatório publicado via [docsify](https://docsify.js.org/) (`doc/relatorio/`).

---

## 1. Introdução

O presente relatório técnico apresenta o projeto da solução RelatoSeg, desenvolvida para otimizar e automatizar o fluxo de processamento e regulação de sinistros no setor securitário. Por meio da integração de modelos de linguagem e arquitetura distribuída baseada no protocolo MCP, o sistema busca consolidar dados heterogêneos e acelerar a tomada de decisão, garantindo eficiência operacional e conformidade com os prazos regulatórios do setor.

### Contextualização

Seguradoras processam diariamente um grande volume de sinistros, cada um exigindo a análise cruzada de informações heterogêneas: fotos do dano enviadas pela segurada, laudos e documentos de peritos, dados cadastrais e histórico da apólice em sistemas legados, e regras de cobertura específicas de cada produto. A regulação desses sinistros está sujeita a prazo regulatório: a Superintendência de Seguros Privados (SUSEP), pela Circular SUSEP nº 621/2021, estabelece prazo de até 30 dias corridos (prorrogável em casos específicos) entre a entrega da documentação pela segurada e a conclusão da regulação, sob pena de atualização monetária e juros de mora (SUSEP, 2021; CONJUR, 2024). Historicamente, essa análise é conduzida manualmente por reguladores de sinistro, que precisam consultar múltiplos sistemas e documentos para compor um parecer dentro desse prazo. Esse cenário de pressão por agilidade coincide com uma adoção crescente de inteligência artificial no setor: pesquisa da CNseg indica que 80% das seguradoras brasileiras já implantaram alguma solução de IA, apontando a integração entre sistemas legados como a principal barreira relatada, citada por 69% das respondentes (MOBILE TIME, 2026). Com a maturidade recente de agentes de IA (LLMs) capazes de interpretar dados não estruturados (imagens, documentos) e operar ferramentas (*tools*) via protocolos padronizados como o **MCP (Model Context Protocol)** (ANTHROPIC, 2024), abre-se a possibilidade de automatizar parte relevante desse processo de forma estruturada e auditável — endereçando justamente essa barreira de integração entre sistemas heterogêneos.

### Problema

A geração do relatório de análise de um sinistro, hoje, depende de um processo majoritariamente manual: o regulador precisa acessar individualmente o sistema de apólices, o repositório de documentos/fotos enviados pela segurada e, eventualmente, sistemas de terceiros (ex. tabelas de referência de peças/serviços), para então redigir um parecer consolidado. Isso torna o tempo de resposta ao segurado longo e sujeito a inconsistência entre pareceres de reguladores diferentes, além de dificultar a rastreabilidade de quais evidências embasaram cada decisão. Automatizar esse fluxo especificamente para sinistros, por sua vez, não resolve o problema de fundo: outras áreas da seguradora (ex. auditoria de compliance, ouvidoria) enfrentam a mesma necessidade de cruzar dados heterogêneos e gerar relatórios, sem uma arquitetura compartilhada que evite reconstruir o mesmo pipeline do zero.

### Motivação

Padronizar esse pipeline em uma arquitetura distribuída reutilizável reduz o esforço de engenharia necessário para automatizar a geração de relatórios em uma nova área da seguradora — bastando implementar sua própria API de ferramentas de domínio (MCP Server), sem recriar o restante do fluxo (orquestração, armazenamento, consolidação, geração de documento e notificação). No caso da análise de sinistros, isso significa reduzir o tempo de regulação, padronizar a qualidade dos pareceres e manter rastreabilidade completa de quais evidências (fotos, laudos, dados da apólice) embasaram cada relatório gerado — um requisito relevante inclusive do ponto de vista regulatório (ex. SUSEP).

### Objetivos
- **Objetivo geral:** Propor uma arquitetura distribuída de referência, baseada na orquestração de agentes de IA (LLM) via protocolo MCP, capaz de automatizar a geração de relatórios analíticos a partir de dados corporativos heterogêneos, de forma reutilizável entre diferentes áreas de negócio — demonstrada no domínio de **análise de sinistros de seguros**.
- **Objetivos específicos:**
  1. Definir a macroarquitetura (modelo **C4** — contexto, container e componentes; BROWN, [s.d.]) do pipeline de geração automatizada de relatórios de sinistro, desde a solicitação de regulação até a notificação do parecer.
  2. Especificar os mecanismos de integração entre o motor de orquestração da pipeline, a plataforma de orquestração de agentes (MCP Host) e a API de ferramentas de domínio (MCP Server / Tools API) que consulta apólices, sinistros e documentos.
  3. Avaliar a arquitetura proposta quanto a segurança, escalabilidade, desempenho, rastreabilidade e extensibilidade para novos domínios de negócio, segundo o método ATAM.

---

## 2. Especificação Arquitetural da Solução

Esta seção apresenta a especificação arquitetural da solução RelatoSeg, detalhando as restrições técnicas, os requisitos funcionais e não funcionais que norteiam o projeto, além dos mecanismos arquiteturais adotados para garantir a integração, escalabilidade e segurança na geração automatizada de relatórios de análise de sinistros.

### 2.1 Restrições Arquiteturais

As restrições arquiteturais definem as limitações técnicas, contratuais, normativas ou operacionais que impõem fronteiras ao design da solução RelatoSeg. A Tabela apresenta as restrições mandatórias estabelecidas para o desenvolvimento e a infraestrutura do sistema.

*Tabela — Restrições arquiteturais*

| ID | Restrição |
| --- | --- |
| R1 | A comunicação entre a plataforma de orquestração de agentes (MCP Host) e as APIs de ferramentas de domínio deve seguir o protocolo **MCP (Model Context Protocol)**. |
| R2 | Os dados brutos do sinistro (documentos, imagens, respostas de agentes) devem ser armazenados fora de infraestrutura on-premise, já que a seguradora não mantém datacenter próprio para novos projetos — restringindo o armazenamento intermediário a serviços de *object storage* em nuvem. A plataforma adota o **Google Cloud Platform (GCP)** como provedor único, para não fragmentar operação, billing e superfície de segurança entre múltiplas nuvens. |
| R3 | Os dados estruturados de apólice e sinistro já são replicados para o *data warehouse* corporativo (ex.: BigQuery) mantido pela área de dados da seguradora, sem acesso direto aos bancos operacionais dos sistemas legados — restringindo a consulta estruturada a essa camada analítica. |
| R4 | A notificação de conclusão ou erro de cada etapa deve ser assíncrona, via mecanismo de mensageria *pub/sub*. |
| R5 | Dados pessoais e de sinistro (fotos, laudos, dados da segurada) tratados pela plataforma devem atender a requisitos de proteção de dados (LGPD) e às normas do órgão regulador do setor (SUSEP). |

### 2.2 Requisitos Funcionais
*(12 a 15 requisitos, macro, claros e completos — CA-1.3)*

| ID | Descrição Resumida | Dificuldade (B/M/A) | Prioridade (B/M/A) |
| --- | --- | --- | --- |
| RF01 | Permitir que o regulador solicite a análise automatizada de um sinistro registrado, via Workflow/BPM existente | M | A |
| RF02 | Permitir que a segurada envie, via aplicativo mobile ou web portal, fotos e informações do dano diretamente para a plataforma, disparando a análise | A | A |
| RF03 | Registrar o pedido de análise com identificador único de correlação ao sinistro, independentemente da origem (regulador ou segurada) | B | A |
| RF04 | Orquestrar a execução dos agentes de IA (MCP Host) a partir do pedido registrado | A | A |
| RF05 | Permitir, via **Agent Console** dedicado (app própria, separada do Web Console operacional), a criação e configuração de agentes — prompt e modelo de LLM associado — e o cadastro de novos MCP Servers, restrito a funcionários técnicos/de negócio da seguradora (administrador de plataforma) | M | M |
| RF06 | Expor, via MCP Server (Tools API), as ferramentas de consulta a apólice, sinistro e documentos | A | A |
| RF07 | Consultar dados estruturados da apólice e do sinistro (data warehouse) a partir das tools | M | A |
| RF08 | Coletar e armazenar fotos do dano e laudos periciais, incluindo geolocalização e timestamp capturados pelo app mobile | M | A |
| RF09 | Consolidar os dados brutos coletados em um metadado padronizado do parecer de sinistro | A | A |
| RF10 | Gerar o documento final do parecer a partir do metadado consolidado | M | A |
| RF11 | Publicar o resultado do processamento (sucesso) em tópico de notificação, com link do documento, disparando notificação ativa por e-mail (regulador/corretor) e push mobile (segurada) | M | A |
| RF12 | Publicar erros ocorridos em qualquer etapa do pipeline no mesmo mecanismo de notificação | M | M |
| RF13 | Permitir que apenas a área solicitante consuma a notificação/relatório correspondente (filtro por correlação) | M | A |
| RF14 | Disponibilizar, via Web Console, o status e o histórico de cada solicitação de análise para regulador e corretor de seguros | M | M |
| RF15 | Permitir o cadastro de um novo MCP Server (nova área de negócio, além de sinistros) sem alterar o MCP Host | A | M |

### 2.3 Requisitos Não-funcionais

Os requisitos não funcionais estabelecem os critérios de qualidade, atributos de desempenho, diretrizes de segurança e restrições operacionais que sustentam a arquitetura da plataforma RelatoSeg. A Tabela descreve as métricas e padrões mandatórios garantidos pela solução.

*Tabela — Requisitos não funcionais*

| ID | Descrição | Prioridade (B/M/A) |
| --- | --- | --- |
| RNF01 | **Segurança/Privacidade:** dados sensíveis em trânsito e em repouso devem ser criptografados; autenticação via OAuth2/OIDC (Keycloak), com o API Gateway validando o token e aplicando RBAC por papel (segurada, regulador, corretor, administrador); acesso à Tools API deve exigir autenticação por serviço e estar sujeito a rate limiting no API Gateway e na própria Tools API | A |
| RNF02 | **Extensibilidade:** deve ser possível integrar um novo MCP Server (novo domínio de negócio) em até **10 dias-homem** (implementação das tools + testes, seguindo o padrão estabelecido), sem alteração no MCP Host | A |
| RNF03 | **Disponibilidade:** a plataforma deve operar com disponibilidade de 99,9% em horário comercial | M |
| RNF04 | **Desempenho e Escalabilidade:** para um sinistro de volume típico (até 15 fotos e laudo pericial de até 10 páginas), o tempo entre a solicitação do parecer e a notificação final não deve ultrapassar **10 minutos (p95)**; a plataforma deve suportar pelo menos **50 solicitações concorrentes** sem degradação, inclusive picos de envio de fotos via app mobile | A |
| RNF05 | **Rastreabilidade:** todo parecer gerado deve ser auditável de ponta a ponta (quem solicitou, quais fontes/evidências consultadas, quando), inclusive as submissões feitas via app mobile | M |
| RNF06 | **Usabilidade e Disponibilidade Offline (mobile):** o aplicativo da segurada deve permitir a captura de fotos do sinistro mesmo sem conectividade, sincronizando automaticamente quando a conexão for reestabelecida | M |

> **Nota sobre RNF03 (disponibilidade):** o valor de 99,9%/mês (~43min de indisponibilidade tolerada) é sustentado pela topologia definida em 2.4 — cluster **Kubernetes (GKE)** multi-zona, com múltiplas réplicas de cada componente de aplicação e *rolling updates* sem downtime, combinado a serviços gerenciados do GCP (**Cloud SQL**, **Memorystore**, **Pub/Sub**) que já oferecem SLA de alta disponibilidade próprio, tirando da plataforma a responsabilidade de operar HA para os componentes com estado. Esse trade-off (maior complexidade/custo operacional × maior disponibilidade, em troca da simplicidade do nó único usado só em desenvolvimento/testes locais via Docker Compose) é revisitado na Avaliação Arquitetural (seção 4).

### 2.4 Mecanismos Arquiteturais

Os mecanismos arquiteturais representam as decisões de design e escolhas tecnológicas adotadas para atender aos requisitos funcionais, não funcionais e restrições do sistema RelatoSeg. A estrutura mapeia as necessidades identificadas na fase de Análise para os padrões arquiteturais de Design e suas respectivas escolhas de Implementação na infraestrutura de nuvem.

*Tabela — Mecanismos arquiteturais*

| Análise | Design | Implementação |
| --- | --- | --- |
| Persistência (dados estruturados, fonte externa) | Data Warehouse na nuvem | BigQuery (GCP) |
| Persistência (dados não estruturados) | Object storage | Google Cloud Storage (GCS) |
| Persistência (estado operacional do pipeline) | Banco relacional — uma única instância, com um schema por dono: **Temporal Server** (histórico de execução dos workflows/activities, gerenciado automaticamente pelo próprio Temporal) e **Init Worker** (registro da solicitação, step 1) — mesmo domínio de execução (Init Worker é a própria *activity* de step 1 orquestrada pelo Temporal); a API de Sinistros não toca nesta base, preservando *Database per Service* | Cloud SQL for PostgreSQL |
| Persistência (configuração de agentes/LLM) | Banco relacional dedicado ao **MCP Host** (Prompt Config Store — prompts, modelos, **chaves de API dos provedores de LLM**, RF05) — instância própria, isolada da base de execução do pipeline: domínio diferente (configuração de agentes vs. execução de workflow) e dado sensível (credencial), mesmo raciocínio já aplicado à persistência do Keycloak | Cloud SQL for PostgreSQL (instância separada) |
| Persistência (modelo de leitura / view) | Banco relacional, uso exclusivo da API de Sinistros — princípio *Database per Service*: cada serviço dono da sua base, dados duplicados entre bases quando necessário, em troca de desacoplamento | Cloud SQL for PostgreSQL (instância separada) |
| Cache de leitura | Cache em memória, gerenciado | Memorystore for Redis |
| Autenticação/Autorização (IAM) | OAuth2 (HARDT, 2012)/OIDC — dois realms: interno (federado ao SSO corporativo já existente na seguradora) e externo (cadastro próprio da segurada); Gateway valida token via JWKS, RBAC aplicado por *claims* de papel | Keycloak (self-hosted, containerizado no GKE) |
| Persistência (IAM) | Banco relacional dedicado ao Keycloak — instância própria, isolada da base operacional, por ser dado sensível (credenciais) que pede segregação extra | Cloud SQL for PostgreSQL (instância separada) |
| Restrição de acesso de rede (IAM — Agent Console) | Controle de acesso na borda por identidade (zero-trust), adicional à autenticação Keycloak/OIDC — restringe quem sequer alcança a aplicação, não só quem consegue logar, dado o *blast radius* de configurar agentes/prompts/modelos e cadastrar novos MCP Servers | Google Cloud Identity-Aware Proxy (IAP) |
| Orquestração da pipeline (steps 1-5) | Execução durável / retries automáticos / dedup por Workflow ID | Temporal.io (self-hosted, containerizado no GKE) |
| Orquestração de agentes | Protocolo MCP — Spring MCP Client (Host) consome tools via `@McpTool`, transporte HTTP/SSE/Stdio | Spring AI (MCP Client/Server starters) |
| Integração com provedor de LLM | *Adapter* (`LLMProviderAdapter`) sobre o `ChatClient` do Spring AI, isolando o Agent Orchestrator do provedor específico — permite trocar de modelo/provedor sem alterar o MCP Host | Spring AI `ChatClient` + provedor de LLM contratado (ex. OpenAI, Anthropic, Gemini) |
| Borda de API (entrada de negócio) | API Gateway único — autenticação, rate limiting, roteamento; sem BFF (o Mobile App é o único canal com requisito distinto — RNF06, offline-first —, mas ainda opera sobre o mesmo contrato simples de disparo/consulta de status dos demais, sem exigir payload ou agregação diferente; não há hoje lógica condicional por canal que justifique a camada extra) | Spring Cloud Gateway (mesma stack Spring/Java do resto do back end; integra nativamente com Spring Security para autenticação, sem introduzir mais uma linguagem/tecnologia no projeto) |
| Back end (Tools API / MCP Service) | API REST + Spring MCP Service (Server), regras de negócio e segurança/rate limiting sobre BigQuery/APIs | Spring Boot 3.x + Spring MVC (Java 21 LTS) |
| Front end (Web Console — uso interno) | Single Page Application; compartilhada entre regulador e corretor de seguros (acompanhamento de status/histórico) | React (TypeScript) |
| Front end (Web Portal — uso externo) | Single Page Application; aplicação separada do Web Console — fronteira externo/interno (ver justificativa abaixo) | React (TypeScript) |
| Front end (Agent Console — uso interno, técnico) | Single Page Application dedicada ao administrador de plataforma (funcionário técnico/de negócio da seguradora); criação/configuração de agentes (prompt, modelo de LLM) e cadastro de MCP Servers — separada do Web Console (ver justificativa abaixo) | React (TypeScript) |
| Mobile (App da Segurada) | App multiplataforma com suporte offline-first | React Native (TypeScript) |
| Notificação ativa (push/e-mail) | **API de Notificação** própria — container dedicado, reutilizável por outros domínios de negócio (RF15), consumidor independente do evento final: e-mail para regulador/corretor, push mobile para a segurada | Spring Boot + SendGrid (e-mail) + OneSignal (push) |
| Mensageria (notificação externa) | Tópico com duas *subscriptions* independentes (API de Sinistros e API de Notificação), cada uma recebendo cópia completa da mensagem publicada — mesmo comportamento de *fanout*, sem operar um broker próprio | Google Cloud Pub/Sub |
| Geração de documento | Integração com serviço de documentos | Google Drive API |
| Log do sistema | Log estruturado centralizado (emissão / coleta / armazenamento / visualização) | SLF4J/Logback (emissão) + Promtail (coleta) + Loki (armazenamento) + Grafana (dashboards) |
| Teste de Software | Unitário / integração / contrato / *end-to-end* | JUnit 5 + Mockito (back end); `temporal-testing` (Temporal Test Server em memória, para testes de workflow sem subir o Temporal Server completo); Testcontainers (Postgres + Redis + **emulador Google Cloud Pub/Sub**, em testes de integração); Jest + Testing Library (React/React Native); testes *end-to-end* do pipeline completo (disparo → notificação, incluindo caminho de erro do RF12) rodando contra o Docker Compose de desenvolvimento (componentes internos da plataforma, sem *mocks*) combinado ao **ambiente de homologação GCP** para Provedor de LLM e Google Drive (pasta de teste dedicada) — mesmo critério de homologação já usado para Storage/BigQuery (nota abaixo) |
| Deploy | Containerização + orquestração + CI/CD | **Kubernetes (GKE — Google Kubernetes Engine)** em produção; **Docker Compose** para desenvolvimento e testes locais (Temporal Server, Postgres, Redis, Keycloak e emulador Pub/Sub containerizados — ver nota abaixo sobre Storage/BigQuery); GitHub Actions (build/test/publish de imagens, deploy via Helm/kubectl) |

> **Decisões de stack consolidadas:** optou-se por **Temporal.io** (TEMPORAL TECHNOLOGIES, [s.d.]) como motor de orquestração da pipeline interna por oferecer execução durável com retries automáticos e **deduplicação nativa via Workflow ID** — dispensando um broker de mensageria entre os steps internos e uma solução própria de idempotência (ex. Redis com chave TTL) só para esse fim. O Temporal Server persiste seu estado na **Base do Pipeline** (Cloud SQL for PostgreSQL, compartilhada em schema separado com o Init Worker — suporte nativo do Temporal a Postgres, sem necessidade de Cassandra), simplificando a infraestrutura. Ao todo, a plataforma usa **quatro instâncias de Cloud SQL for PostgreSQL** (Base do Pipeline, Base do Prompt Config Store, Base de Sinistros e base do Keycloak), cada uma isolada por domínio ou por sensibilidade do dado (ver seção 2.4). Para a notificação externa final (Notifier → consumidores), optou-se pelo **Google Cloud Pub/Sub** em vez de um broker self-hosted: um único tópico com duas *subscriptions* independentes (API de Sinistros e API de Notificação), cada uma recebendo cópia completa de toda mensagem publicada — o mesmo comportamento de *fanout* que uma exchange RabbitMQ ofereceria, sem o ônus operacional de manter um broker (patching, HA, backup) por conta da plataforma. O filtro por área solicitante (RF13) continua não sendo feito pelo Pub/Sub; é aplicado na lógica de cada consumidor, a partir do `sinistro_id`/correlação presente no payload da mensagem. O **Memorystore for Redis** permanece na arquitetura com papel reduzido: cache de leitura para dados de apólice/sinistro consultados com frequência pela Tools API, reduzindo latência e custo de chamadas repetidas ao BigQuery/sistema legado. Para o estado operacional da plataforma (registro de solicitações, status, histórico consumido pelo Web Console) foi definido um banco relacional dedicado (**Cloud SQL for PostgreSQL**), já que o BigQuery — sendo um data warehouse analítico — não é adequado para carga transacional. Web Console e Mobile App foram unificados sob **React / React Native**, compartilhando linguagem (TypeScript) e padrões de componente entre as duas frentes. Em produção, todo o stack de aplicação (apps, API Gateway, Keycloak, Temporal Server) roda em **Kubernetes (GKE — Google Kubernetes Engine)**, com **Cloud SQL**, **Memorystore** e **Pub/Sub** como serviços gerenciados — dispensando a operação manual de alta disponibilidade para os componentes com estado (bancos, cache, mensageria), o principal ganho de escalabilidade/disponibilidade da topologia (ver nota do RNF03 acima).

> **Nota sobre o ambiente de desenvolvimento local:** um ponto de atenção da arquitetura é não deixar o time dependente de infraestrutura GCP real (custo, latência, credenciais) só para rodar e testar a plataforma no dia a dia — em especial a orquestração via **Temporal.io**, que concentra a lógica mais sensível a bug (retries, dedup, *activities*). Por isso o Docker Compose de desenvolvimento reproduz localmente, com fidelidade real (mesmo software, não simulação), tudo que tem uma contrapartida open-source containerizável:
>
> - **Temporal Server** (imagem oficial `temporal.io/auto-setup`, com seu próprio schema de histórico) — permite reproduzir localmente o comportamento real de execução durável, retries e deduplicação por Workflow ID, sem depender de conta GCP;
> - **PostgreSQL** e **Redis** — Cloud SQL for PostgreSQL e Memorystore for Redis são apenas hospedagem gerenciada dos bancos open-source correspondentes, falando o protocolo padrão de cada um (wire protocol do Postgres, RESP do Redis); um container `postgres`/`redis` comum já é 100% compatível — a aplicação não distingue se fala com a instância gerenciada ou com o container local, além de host/porta de conexão;
> - **Keycloak** e **Grafana/Loki/Promtail** — mesmas imagens self-hosted usadas como referência para o comportamento em produção;
> - **Pub/Sub** — via **emulador oficial do Google** (`gcloud-pubsub-emulator`), não um container Pub/Sub genérico: por expor uma API proprietária (gRPC/REST) sem equivalente open-source que fale o mesmo protocolo, é o único componente desta lista que precisa de um *emulador* (e não do software real) para ser reproduzido localmente.
>
> Já **Cloud Storage (GCS)** e **BigQuery** não têm uma opção de simulação local oficial com fidelidade equivalente — BigQuery, em particular, não possui emulador mantido pelo Google, e o próprio dado consultado (data warehouse corporativo da seguradora) não existe fora do GCP real. Nesses dois casos, a estratégia adotada é diferente: em vez de simular, o **profile de configuração local/dev** (Spring Profiles) aponta os endpoints/credenciais da aplicação para um **ambiente de homologação real no GCP** — um projeto GCP de staging, isolado do de produção, com dado de teste — usado só para os componentes sem simulação viável. O **Provedor de LLM** e a **Google Drive API** seguem o mesmo critério, por não terem emulador oficial e por chamada real ter custo/efeito colateral: os testes que os exercitam (incluindo os *end-to-end* da seção 2.4) rodam contra o ambiente de homologação, nunca produção — o Google Drive usando uma **pasta de teste dedicada**, isolada da pasta usada em produção. Resumindo o critério: tudo que roda localmente com fidelidade (Temporal, Postgres, Redis, Pub/Sub via emulador) entra no Docker Compose; o que não dá para simular com fidelidade (Storage, BigQuery, Provedor de LLM, Google Drive) usa profile apontando para homologação, mantendo o restante do ambiente 100% local.

> **Por que Web Console e Web Portal são aplicações separadas (e não uma só):** o Web Portal atende a **segurada**, uma **usuária externa**, o que é uma fronteira arquitetural mais forte que "papéis diferentes dentro da mesma organização": (1) **autenticação distinta** — a segurada tipicamente entra por CPF/número de apólice, não pela SSO corporativa usada por regulador/corretor/administrador; (2) **postura de segurança distinta** — uma aplicação exposta a clientes externos exige controles de borda (rate limiting mais restritivo, superfície de ataque isolada) diferentes de uma aplicação de uso interno, e uma eventual vulnerabilidade em um dos apps não compromete o outro; (3) **ciclos de release independentes** — o Web Portal evolui no ritmo da experiência do cliente (produto/UX), enquanto o Web Console evolui no ritmo das necessidades operacionais internas. Unificar os dois exigiria conciliar esses requisitos divergentes em uma única aplicação, aumentando o acoplamento sem um ganho real de simplicidade.
>
> **Por que o Agent Console também é uma aplicação separada (e não uma área restrita dentro do Web Console):** ao contrário de regulador e corretor — que usam o Web Console para a mesma tarefa (acompanhar status/histórico), diferindo só no escopo de sinistros que enxergam — o administrador de plataforma exerce uma função de **domínio técnico** (configurar agentes, modelos de LLM e integrações MCP), tipicamente exercida por funcionários técnicos/de negócio da seguradora, não pelo público operacional de regulador/corretor. Misturar as duas coisas num único app com RBAC exigiria expor, no mesmo bundle front-end, telas e chamadas de API de um domínio completamente diferente (configuração de infraestrutura de IA) para um público que nunca deveria precisar disso — aumentando a superfície de ataque do console operacional sem necessidade, e acoplando o ciclo de release de uma tela usada raramente (configuração) ao de uma usada todo dia (acompanhamento de status). Separar em um **Agent Console** próprio isola essa superfície tecnicamente mais sensível, mantendo o mesmo raciocínio de fronteira de confiança já aplicado ao Web Portal.
>
> **Por que o Agent Console tem uma restrição de acesso de rede adicional (IAP), além do login:** por concentrar a superfície mais sensível da arquitetura — configuração de prompts, modelos de LLM, chaves de API e cadastro de novos MCP Servers —, o Agent Console recebe uma camada de defesa em profundidade que os demais front ends não têm: o **Google Cloud Identity-Aware Proxy (IAP)** é posicionado na borda do seu Ingress no GKE, de forma que a aplicação simplesmente não é alcançável por um IP não autorizado, mesmo antes de qualquer tentativa de login. Optou-se por IAP em vez de uma VPN dedicada por dois motivos: reaproveita a mesma identidade federada já usada pelo SSO corporativo/Keycloak (sem exigir cliente de VPN nem infraestrutura de rede adicional para o administrador) e é nativo do GCP, já provedor único da plataforma (R2) — mesmo raciocínio de reuso de infraestrutura já aplicado ao restante da arquitetura.

---

## 3. Modelagem Arquitetural

*(Modelo C4 — https://c4model.com/)*

### 3.1 Diagrama de Contexto
*(CA-1.6 — não precisa ser UML, deve ser claro e completo)*

![Diagrama de Contexto do RelatoSeg](diagramas/3.1-contexto.png)

![Legenda](diagramas/3.1-contexto-legenda.png)

*Legenda de formas/cores da Figura 1.*

**Figura 1 – Diagrama de Contexto.** Fonte: elaborado pelo autor (gerado a partir do modelo C4 em Structurizr — [doc/c4/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/c4), fonte editável, ver [view-contexto.dsl](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/c4/view-contexto.dsl)).

A Figura 1 mostra a especificação do diagrama geral (macroarquitetura) da solução proposta, com todos os atores e sistemas externos que interagem com a Plataforma RelatoSeg. A segurada pode enviar fotos e informações do dano diretamente pelo aplicativo mobile ou pelo web portal (aplicações separadas do Web Console interno — ver justificativa na seção 2.4), disparando a análise (entrada self-service). Alternativamente, o regulador de sinistros solicita a análise através do sistema de Workflow/BPM já existente na seguradora, que dispara a Plataforma RelatoSeg — comunicação bidirecional, já que a Plataforma também atualiza o Workflow/BPM com o status da análise. Regulador e corretor de seguros usam o Web Console para acompanhar o status das análises; o administrador de plataforma — funcionário técnico/de negócio da seguradora — usa uma aplicação separada, o **Agent Console** (ver justificativa na seção 2.4), para criar/configurar agentes, modelos de LLM e prompts, e cadastrar novos MCP Servers. Em todos os casos, a plataforma orquestra os agentes de IA — invocando o **provedor de LLM** contratado para cada chamada de chat completion —, consulta as fontes de dados da apólice e do sinistro (estruturadas no data warehouse, documentais como laudos periciais nos sistemas internos), gera o parecer final e notifica ativamente ao término do processo (sucesso ou erro): por e-mail para regulador e corretor, por push notification para a segurada — além de o resultado ficar sempre disponível sob consulta nos respectivos consoles.

### 3.2 Diagrama de Container
*(CA-1.7 — segundo o C4 model)*

O Diagrama de Container descreve a arquitetura de alto nível do RelatoSeg, detalhando a distribuição das aplicações, bases de dados e filas de mensagens. Ele evidencia as fronteiras de execução do sistema e como o protocolo MCP orquestra o fluxo de dados entre os serviços.

> **Nota:** o Diagrama de Container é apresentado em três *views* complementares — prática aceita pelo C4 model quando um único diagrama fica denso demais para permanecer legível (aqui seriam ~23 containers e ~53 relações num só grafo). **3.2.1** cobre a entrada de negócio (autenticação, roteamento, gatilho da orquestração); **3.2.2** e **3.2.3** cobrem, juntas, os 5 *steps* que o Temporal orquestra — divididas só por legibilidade do diagrama, não por escopo de orquestração: **3.2.2** detalha os steps 1-4 (coleta e consolidação), **3.2.3** detalha o step 5 (notificação) e os dois consumidores independentes do resultado; o Temporal Server aciona os cinco da mesma forma (ver seção 2.4, "Orquestração da pipeline (steps 1-5)"). Containers como **API de Sinistros**, **MCP Host**, **Keycloak**, **Gateway** e **Temporal Server** reaparecem como nós de fronteira entre *views* quando participam de mais de um fluxo — prática normal no C4 model.

Antes de detalhar cada *view*, a Figura 2 mostra a **visão macro** — todos os 23 containers de uma vez, agrupados pelas mesmas 3 áreas (fronteiras tracejadas):

![Diagrama de Container — visão macro](diagramas/3.2-container-macro.png)

![Legenda](diagramas/3.2-container-macro-legenda.png)

*Legenda de formas/cores da Figura 2.*

**Figura 2 – Diagrama de Container, visão macro.** Fonte: elaborado pelo autor (gerado a partir do modelo C4 em Structurizr — [doc/c4/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/c4), fonte editável, ver [view-container-macro.dsl](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/c4/view-container-macro.dsl)).

#### 3.2.1 Entrada, Autenticação e Roteamento

Esta subseção detalha as portas de entrada de negócio da plataforma — o fluxo de autenticação compartilhado entre os canais de acesso (segurada, regulador, corretor e administrador) e o roteamento das solicitações até a API de Sinistros, ponto a partir do qual a orquestração durável do pipeline assume o processamento do sinistro.

![Diagrama de Container 3.2.1 — Entrada, Autenticação e Roteamento](diagramas/3.2.1-container-entrada.png)

![Legenda](diagramas/3.2.1-container-entrada-legenda.png)

*Legenda de formas/cores da Figura 3.*

**Figura 3 – Diagrama de Container 3.2.1, Entrada, Autenticação e Roteamento.** Fonte: elaborado pelo autor (gerado a partir do modelo C4 em Structurizr — [doc/c4/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/c4), fonte editável, ver [view-container-entrada.dsl](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/c4/view-container-entrada.dsl)).

A Figura 3 apresenta os containers responsáveis pela entrada de negócio. Antes de qualquer chamada de negócio, os clientes (Mobile App, Web Portal, Web Console, Agent Console) se autenticam no **Keycloak** via OAuth2/OIDC — um *realm* interno, federado ao SSO corporativo já existente na seguradora (regulador, corretor, administrador), e um *realm* externo com cadastro próprio (segurada). O token resultante carrega o papel do usuário como *claim*, usado pelo **API Gateway** para aplicar RBAC na borda, sem que cada serviço downstream precise reimplementar essa checagem. O fluxo tem três portas de entrada de negócio para o mesmo pipeline: as duas portas **self-service** passam pelo **API Gateway** único (autenticação, rate limiting e roteamento), já que carregam o token de usuário validado ali — a segurada envia fotos e dados do dano via **Mobile App** (React Native, com captura offline-first) ou **Web Portal** (React). Já a integração do regulador de sinistros, feita pelo sistema de Workflow/BPM já existente na seguradora, é uma chamada **service-to-service (M2M)** direta à **API de Sinistros**, autenticada via OAuth2 *client credentials* no Keycloak — sem passar pelo Gateway, pois não carrega token de usuário para RBAC por papel, e sim credencial do próprio sistema externo. Todo o tráfego de negócio (disparo e consulta de status) converge para a **API de Sinistros** — que segrega comando de leitura (padrão **CQRS**): ela grava um registro inicial na sua **própria base de leitura (Base de Sinistros)**, dispara a execução no **Temporal Server** e devolve o status atual sempre consultando essa mesma base, isolada do estado interno da orquestração. O **Web Console** (React) agora é de uso exclusivo de regulador e corretor, que o utilizam para acompanhar o status/histórico das solicitações. O **Agent Console** (React) é uma aplicação separada, de uso técnico/interno, restrita ao administrador de plataforma (funcionário técnico/de negócio da seguradora — ver justificativa na seção 2.4): antes mesmo do login, o acesso já é filtrado na borda pelo **Identity-Aware Proxy (IAP)**, que só deixa alcançar a aplicação usuários autorizados (ver justificativa na seção 2.4) — camada extra que os demais front ends não têm, dado o *blast radius* dessa superfície. Autenticado, o administrador cria e configura agentes (prompt, modelo de LLM) e cadastra novos MCP Servers, através do mesmo Gateway único, roteado ao **MCP Host** — persistência detalhada em 3.2.2. A partir da chamada `SinistroAPI → Temporal Server`, a orquestração durável do pipeline assume o fluxo, detalhada na próxima *view*.

#### 3.2.2 Coleta e Consolidação de Dados (steps 1-4)

Esta subseção detalha os steps 1 a 4 do pipeline, responsáveis por registrar a solicitação, orquestrar os agentes de IA e consolidar os dados coletados no metadado padronizado do parecer, até a geração do documento final.

![Diagrama de Container 3.2.2 — Coleta e Consolidação de Dados (steps 1-4)](diagramas/3.2.2-container-pipeline.png)

![Legenda](diagramas/3.2.2-container-pipeline-legenda.png)

*Legenda de formas/cores da Figura 4.*

**Figura 4 – Diagrama de Container 3.2.2, Coleta e Consolidação de Dados (steps 1-4).** Fonte: elaborado pelo autor (gerado a partir do modelo C4 em Structurizr — [doc/c4/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/c4), fonte editável, ver [view-container-pipeline.dsl](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/c4/view-container-pipeline.dsl)).

A Figura 4 detalha os steps 1 a 4 do pipeline. O Temporal orquestra de forma durável (com retries automáticos e deduplicação nativa por Workflow ID) uma sequência de 5 *activities*, mantendo a numeração original do pipeline: **step 1** (**Init Worker**) persiste a solicitação na **Base do Pipeline** (Cloud SQL for PostgreSQL), seguido por **step 2** (**MCP Host**), **step 3** (**Report Builder**) e **step 4** (**Document Generator**) — cada step com seu próprio container, dono exclusivo dos dados que grava. O MCP Host — implementado como **Spring MCP Client** — aciona os agentes de IA, chamando o **provedor de LLM** contratado (chat completion) e utilizando a **Tools API** — implementada como **Spring MCP Service (Server)** — para buscar as informações necessárias (dados do data warehouse e do sistema de apólices/sinistros, com cache de leitura no **Memorystore for Redis**), persistindo-as no storage intermediário; o MCP Host também persiste, numa instância própria de Cloud SQL isolada da base de execução do pipeline (Prompt Config Store — domínio de configuração de agentes/LLM, dado sensível como as chaves de API dos modelos, mesmo raciocínio já aplicado ao Keycloak), a configuração de agentes/modelos/prompts recebida do Agent Console (RF05). O **Report Builder** consolida esses dados brutos em um metadado padronizado, consumido pelo **Document Generator** para produzir o documento final. Concluído o step 4, o Temporal aciona o **step 5** (**Notifier**), detalhado na próxima *view*.

> **Nota sobre granularidade do status (RF14):** entre o disparo e a conclusão, nenhum dos steps 2-4 (MCP Host, Report Builder, Document Generator) atualiza a **Base de Sinistros** — só o registro inicial (gravado pela API de Sinistros no disparo) e o resultado final (via step 5, seção 3.2.3) chegam até ela. O progresso *step a step* já existe, mas só no histórico de execução interno do próprio Temporal Server, que a API de Sinistros deliberadamente não consulta (preserva *Database per Service* — ver seção 2.4). Trade-off aceito: o Web Console mostra status binário (recebido → concluído/erro) durante o processamento, sem granularidade por step, o que é razoável dado o tempo de resposta esperado (RNF04, até 10min p95). Se o produto exigir progresso intermediário no futuro, o mecanismo mais direto seria reaproveitar o padrão já existente (Pub/Sub → Notification Consumer, seção 3.2.3) para eventos de progresso, não só para o evento final — sem introduzir tecnologia nova.

#### 3.2.3 Notificação (step 5) e Consumo do Resultado

Esta subseção detalha o step 5 do pipeline, responsável por publicar o resultado do processamento e acioná-lo aos dois consumidores independentes: a atualização do status na Base de Sinistros e o envio da notificação ativa ao regulador, corretor e segurada.

![Diagrama de Container 3.2.3 — Notificação (step 5) e Consumo do Resultado](diagramas/3.2.3-container-notificacao.png)

![Legenda](diagramas/3.2.3-container-notificacao-legenda.png)

*Legenda de formas/cores da Figura 5.*

**Figura 5 – Diagrama de Container 3.2.3, Notificação (step 5) e Consumo do Resultado.** Fonte: elaborado pelo autor (gerado a partir do modelo C4 em Structurizr — [doc/c4/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/c4), fonte editável, ver [view-container-notificacao.dsl](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/c4/view-container-notificacao.dsl)).

A Figura 5 detalha o step 5 e os dois consumidores independentes do resultado. O **Notifier** publica o resultado (ou erro) num tópico do **Google Cloud Pub/Sub**, consumido por duas *subscriptions* independentes entre si: a **API de Sinistros** atualiza a **Base de Sinistros** com o status final e o link do documento; em paralelo, a **API de Notificação** — desacoplada e reutilizável por outros domínios de negócio que venham a integrar a plataforma (RF15) — dispara o aviso ativo: e-mail via **SendGrid** para regulador/corretor, push via **OneSignal** para a segurada. Nenhum dos dois consumidores depende do outro: se a API de Notificação estiver indisponível, a atualização da Base de Sinistros não é afetada, e vice-versa. Os clientes (Mobile App, Web Portal, Web Console) sempre podem consultar a Base de Sinistros sob demanda, nunca o estado interno da orquestração, mas não dependem só da consulta: a notificação ativa avisa proativamente quando o resultado sai.

> **Nota sobre tratamento de erro em qualquer step (RF12):** por padrão, se uma *activity* (MCP Host, Report Builder ou Document Generator) esgota sua política de retry e falha definitivamente, o Temporal apenas marca a execução do workflow como "Failed" e para — o **step 5 (Notifier) nunca seria acionado**, e o erro nunca chegaria ao Pub/Sub, à Base de Sinistros ou ao e-mail do regulador, quebrando o RF12. Por isso o **workflow captura a falha de qualquer step e aciona o Notifier mesmo assim** (padrão try/catch dentro da lógica do workflow, funcionando como um "finally" que sempre notifica, com sucesso ou erro) — o Notifier passa a rodar tanto no caminho feliz quanto no caminho de erro, só variando o status publicado. O histórico técnico da falha (qual step, quantas tentativas, motivo) fica automaticamente no histórico de execução do Temporal Server (Base do Pipeline, seção 2.4) — auditável via Temporal Web UI/SDK para fins operacionais, mas não exposto ao regulador via Web Console (RNF05 é atendido no nível técnico/interno; o nível de negócio permanece o status binário descrito na nota da seção 3.2.2). Dados brutos já coletados antes da falha (fotos, documentos) permanecem no Object Storage — chave determinística (seção 2.4) —, preservando evidência parcial mesmo em pareceres que não concluíram.

### 3.3 Diagrama de Componentes
*(CA-1.8 — preferencialmente UML)*

O Diagrama de Componentes decompõe os containers do sistema em suas unidades funcionais e módulos de código. A estrutura a seguir detalha as responsabilidades internas da API de Sinistros, do MCP Host e das ferramentas de suporte, destacando a aplicação de padrões de projeto e arquitetura hexagonal.

O diagrama cobre os **8 containers de aplicação com lógica própria desenvolvida** (API de Sinistros, MCP Host, Tools API, Init Worker, Report Builder, Document Generator, Notifier, API de Notificação) — dos 23 containers do Diagrama de Container (seção 3.2), os 15 restantes ficam de fora por não terem estrutura de componentes própria a detalhar: os 4 front-ends React/React Native (Mobile App, Web Portal, Web Console, Agent Console — SPAs) e os 11 containers adquiridos/geridos como serviço ou configurados sobre framework pronto, sem lógica de negócio própria (API Gateway, Identity-Aware Proxy, Keycloak, Temporal Server, e as 7 bases de dados/mensageria: Base do Keycloak, Base de Sinistros, Base do Pipeline, Base do Prompt Config Store, Object Storage, Cache de Leitura, Tópico de Notificação). Igual ao Diagrama de Container, dividido em múltiplas *views* por legibilidade — um grafo único teria ~38 componentes/interfaces e ~33 relações: **3.3.1** cobre a API de Sinistros (CQRS, entrada); **3.3.2** cobre MCP Host e Tools API (agentes e tools, step 2); **3.3.3** cobre Init Worker, Report Builder e Document Generator (steps 1, 3 e 4); **3.3.4** cobre Notifier e API de Notificação (step 5). Toda vez que um componente cruza uma fronteira externa (banco de dados, SDK de terceiro, API de terceiro), ele o faz através de uma interface própria — nenhum componente depende diretamente de uma classe concreta externa.

#### 3.3.1 API de Sinistros (Entrada)

![Diagrama de Componentes 3.3.1 — API de Sinistros](diagramas/3.3.1-api-sinistros.png)

**Figura 6 – Diagrama de Componentes 3.3.1, API de Sinistros.** Fonte: elaborado pelo autor (gerado a partir da fonte PlantUML — [doc/uml/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/uml), fonte editável, ver [3.3.1-api-sinistros.puml](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/3.3.1-api-sinistros.puml), renderizar com [render.sh](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/render.sh)).

A Figura 6 apresenta os componentes da API de Sinistros.

#### 3.3.2 MCP Host e Tools API (Agentes e Tools)

![Diagrama de Componentes 3.3.2 — MCP Host e Tools API](diagramas/3.3.2-mcp-host-tools-api.png)

**Figura 7 – Diagrama de Componentes 3.3.2, MCP Host e Tools API.** Fonte: elaborado pelo autor (gerado a partir da fonte PlantUML — [doc/uml/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/uml), fonte editável, ver [3.3.2-mcp-host-tools-api.puml](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/3.3.2-mcp-host-tools-api.puml), renderizar com [render.sh](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/render.sh)).

A Figura 7 apresenta os componentes do MCP Host e da Tools API.

#### 3.3.3 Init Worker, Report Builder e Document Generator (Coleta e Consolidação — steps 1, 3, 4)

![Diagrama de Componentes 3.3.3 — Init Worker, Report Builder e Document Generator](diagramas/3.3.3-init-report-document.png)

**Figura 8 – Diagrama de Componentes 3.3.3, Init Worker, Report Builder e Document Generator.** Fonte: elaborado pelo autor (gerado a partir da fonte PlantUML — [doc/uml/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/uml), fonte editável, ver [3.3.3-init-report-document.puml](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/3.3.3-init-report-document.puml), renderizar com [render.sh](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/render.sh)).

A Figura 8 apresenta os componentes dos steps 1, 3 e 4. `IObjectStorage` é a mesma porta realizada pelo **Storage Writer** na Figura 7 (Object Storage é um container só, compartilhado entre Tools API, Report Builder e Document Generator) — não repetida aqui por já pertencer ao grupo de componentes da Tools API.

#### 3.3.4 Notifier e API de Notificação (Notificação — step 5)

![Diagrama de Componentes 3.3.4 — Notifier e API de Notificação](diagramas/3.3.4-notifier-notificacao.png)

**Figura 9 – Diagrama de Componentes 3.3.4, Notifier e API de Notificação.** Fonte: elaborado pelo autor (gerado a partir da fonte PlantUML — [doc/uml/](https://github.com/bacelarnetto/tcc-engenharia-software/tree/main/doc/uml), fonte editável, ver [3.3.4-notifier-notificacao.puml](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/3.3.4-notifier-notificacao.puml), renderizar com [render.sh](https://github.com/bacelarnetto/tcc-engenharia-software/blob/main/doc/uml/render.sh)).

A Figura 9 apresenta os componentes do step 5.

**Estilos/padrões arquiteturais utilizados:** *Arquitetura Hexagonal* (**Ports & Adapters**, COCKBURN, 2005) — princípio guarda-chuva aplicado de forma consistente nos 8 containers: nenhum componente de negócio depende diretamente de uma classe concreta externa (banco, SDK de terceiro, API de terceiro); toda travessia de fronteira externa passa por uma interface (*porta*) realizada por um componente dedicado (*adapter*), isolando o núcleo de decisão (Agent Orchestrator, Command/Query Handler, Document Generator, Notification Dispatcher) da tecnologia concreta por trás — os padrões a seguir são instâncias concretas desse princípio. *CQRS* (API de Sinistros: Command Handler separado do Query Handler, cada um com seu próprio caminho de dados); *Publish-Subscribe* (Pub/Sub com duas *subscriptions* independentes: API de Sinistros e API de Notificação consomem o mesmo evento do Notifier de forma independente, sem se conhecerem); *Adapter* (Temporal Workflow Client, LLM Provider Adapter, Cache Adapter, Google Drive Adapter e Pub/Sub Publisher Adapter — cada um isolando um componente interno de um SDK/API de terceiro específico, atrás de uma interface própria); *Strategy* (Email Channel Adapter e Push Channel Adapter realizam a mesma `INotificationChannel`; o Notification Dispatcher escolhe o canal em tempo de execução sem conhecer a implementação concreta — a mesma porta com dois adapters é também o exemplo mais didático da Arquitetura Hexagonal neste diagrama); *Registry* (Tool Registry, permitindo cadastrar novas tools sem alterar o MCP Server Endpoint); *Facade* (MCP Server Endpoint, expondo um ponto único de entrada MCP sobre múltiplas tools internas); *Gateway/Repository* (Apólice/Sinistro Query Service, Storage Writer, Read Model Repository, Init Request Repository e Prompt Config Store, isolando o acesso a sistemas externos e a bases de leitura/escrita).

**Descrição dos componentes:**

| Componente | Papel | Classificação |
| --- | --- | --- |
| Command Handler | Recebe a solicitação de disparo (do API Gateway ou do Workflow/BPM), valida uma chave de idempotência (gerada pelo cliente — essencial no canal self-service, onde o `sinistro_id` ainda não existe no momento do envio) e inicia a execução no Temporal Server via `IWorkflowStarter`, usando um Workflow ID determinístico (dedup); a gravação inicial na Base de Sinistros (view) também é um UPSERT idempotente | A desenvolver |
| Query Handler | Recebe a solicitação de consulta de status/histórico (RF14) e lê da Base de Sinistros, isolada do estado interno da orquestração | A desenvolver |
| Notification Consumer | Consome o evento final (sucesso/erro) publicado pelo Notifier via *subscription* própria no tópico do Pub/Sub (entrega *at-least-once*) e aplica UPSERT idempotente na Base de Sinistros por `sinistro_id` (seguro contra reentrega). Consumidor independente da API de Notificação — as duas reagem ao mesmo evento sem se conhecerem | A desenvolver |
| Read Model Repository | Persiste e consulta a Base de Sinistros (modelo de leitura), usada pelo Query Handler e pelo Notification Consumer | A desenvolver |
| Temporal Workflow Client | Adapta o Command Handler ao Temporal Java SDK — inicia a execução do workflow com o Workflow ID determinístico recebido | A desenvolver (usa biblioteca reutilizada — Temporal Java SDK) |
| Agent Orchestrator | Coordena o ciclo do agente: decide quando chamar o LLM, quando invocar uma tool e quando encerrar, retornando o resultado consolidado | A desenvolver |
| LLM Provider Adapter | Abstrai o provedor de LLM (OpenAI, Anthropic, Gemini) via Spring AI `ChatClient`, permitindo trocar o modelo sem alterar o Agent Orchestrator | A desenvolver (usa biblioteca reutilizada — Spring AI) |
| Prompt Config Store | Armazena e disponibiliza os prompts, variáveis de ambiente, chaves de API dos modelos e o mapeamento de URLs/portas dos MCP Servers, configurados via Agent Console (RF05) e persistidos em instância própria de Cloud SQL for PostgreSQL, isolada da base de execução do pipeline (dado sensível) | A desenvolver |
| MCP Client Manager | Conecta-se aos MCP Services via transporte (Streamable HTTP, SSE ou Stdio), descobre dinamicamente as tools disponíveis (`tools/list`) e injeta as referências no LLM antes de invocá-las (`tools/call`) | A desenvolver (usa biblioteca reutilizada — Spring AI MCP Client) |
| MCP Server Endpoint | Expõe as tools da Tools API via protocolo MCP (funções anotadas com `@McpTool` e *resources*), aplicando validação de entrada, permissões de acesso e rate limiting | A desenvolver (usa biblioteca reutilizada — Spring AI MCP Server) |
| Tool Registry | Registra e descreve as tools disponíveis (ex.: consultar apólice, consultar sinistro, coletar documentos) | A desenvolver |
| Apólice/Sinistro Query Service | Implementa a consulta a dados estruturados de apólice e sinistro no Data Warehouse | A desenvolver |
| Document Collector | Coleta fotos do dano e laudos periciais dos sistemas internos e do envio via app mobile | A desenvolver |
| Cache Adapter | Cacheia consultas frequentes de apólice/sinistro | A desenvolver (usa biblioteca reutilizada — cliente Redis) |
| Storage Writer | Grava os dados brutos coletados no object storage intermediário, usando chave de objeto determinística (`sinistroId/documentoId`) para que retries de chamada de tool sobrescrevam em vez de duplicar | A desenvolver (usa biblioteca reutilizada — cliente Cloud Storage) |
| Init Activity Worker | Recebe a *activity* "init" (step 1) orquestrada pelo Temporal e monta o registro da solicitação (`sinistro_id`, origem, timestamp) | A desenvolver |
| Init Request Repository | Persiste o registro da solicitação na Base do Pipeline, em UPSERT idempotente por `sinistro_id` | A desenvolver |
| Report Consolidator | Lê os dados brutos já coletados (Object Storage) e grava o metadado padronizado consolidado (step 3) | A desenvolver |
| Document Generator | Lê o metadado consolidado, checa se já existe documento gerado para o `sinistro_id` (idempotência — criação no Drive não é idempotente por natureza) e publica o parecer final (step 4) | A desenvolver |
| Google Drive Adapter | Adapta o Document Generator à Google Drive API — cria o documento e permite checar existência prévia | A desenvolver (usa biblioteca reutilizada — Google Drive API client) |
| Notifier | Publica o resultado (sucesso ou erro) do processamento no tópico de notificação (step 5) | A desenvolver |
| Pub/Sub Publisher Adapter | Adapta o Notifier ao cliente do Google Cloud Pub/Sub | A desenvolver (usa biblioteca reutilizada — cliente Google Cloud Pub/Sub) |
| Notification Dispatcher | Consome o evento final via *subscription* própria (independente da API de Sinistros) e decide o(s) canal(is) de notificação, aplicando *dedup* por `sinistro_id` | A desenvolver |
| Email Channel Adapter | Adapta o Notification Dispatcher ao SendGrid | A desenvolver (usa biblioteca reutilizada — cliente SendGrid) |
| Push Channel Adapter | Adapta o Notification Dispatcher ao OneSignal | A desenvolver (usa biblioteca reutilizada — cliente OneSignal) |

**Componentes adquiridos/reutilizados (não desenvolvidos):** provedor de LLM (API paga do provedor escolhido), BigQuery, Cloud Storage, Google Drive API, SendGrid (e-mail), OneSignal (push notification), Keycloak (IAM, self-hosted, sem código próprio de autenticação) — todos consumidos/configurados como serviços prontos, sem código próprio de infraestrutura; os *Adapters* (Temporal Workflow Client, LLM Provider Adapter, Cache Adapter, Google Drive Adapter, Pub/Sub Publisher Adapter, Email/Push Channel Adapter) são código próprio fino sobre bibliotecas cliente reutilizadas, não sobre infraestrutura própria.

> **Pontos de idempotência e deduplicação:** todo ponto de reentrega/retry da arquitetura tem um mecanismo de idempotência correspondente, evitando duplicidade de efeito colateral. O Temporal garante execução *exactly-once* da lógica do workflow em si, mas cada *activity* pode ser reexecutada em caso de falha/timeout — por isso cada uma precisa ser idempotente individualmente; leituras (Query Handler, Apólice/Sinistro Query Service) não precisam de tratamento, por não terem efeito colateral.
>
> 1. **Início do workflow** (Command Handler → Temporal): Workflow ID determinístico por `sinistro_id`, dedup nativa do Temporal — não precisa de lock adicional (por isso não usamos Redis para esse fim, como discutido na seção 2.4). Suficiente sozinho no canal do regulador, onde o sinistro já existe antes da chamada.
> 2. **Envio/reenvio self-service** (segurada, via mobile offline-first ou web portal): como o `sinistro_id` ainda não existe nesse momento, o Workflow ID sozinho não basta — o Command Handler exige uma chave de idempotência gerada no cliente, tanto para decidir se inicia um novo workflow quanto para o UPSERT do registro inicial na Base de Sinistros.
> 3. **Retry da *activity* "init"** (**Init Worker**, step 1, container próprio): UPSERT idempotente por `sinistro_id` na base de estado do pipeline (Cloud SQL, compartilhada em schema separado com o Temporal Server).
> 4. **Retry das *activities* "Report Builder" e "Document Generator"** (steps 3 e 4): o Report Builder grava o metadado consolidado com chave determinística no storage (mesmo padrão do Storage Writer). O Document Generator é o ponto mais delicado — a criação de arquivo no Google Drive **não é idempotente por natureza** (duas chamadas criam dois arquivos); a *activity* precisa checar, antes de gerar, se já existe um documento para aquele `sinistro_id` (guardando o ID do arquivo no estado do workflow ou buscando por nome determinístico), evitando parecer duplicado.
> 5. **Reentrega do Pub/Sub** (*at-least-once*, duas *subscriptions* independentes): o Notification Consumer (API de Sinistros) aplica UPSERT idempotente por `sinistro_id` na Base de Sinistros; a **API de Notificação** também precisa ser idempotente do seu lado (ex.: chave de deduplicação por `sinistro_id` antes de reenviar e-mail/push), já que ambos os consumidores podem receber a mesma mensagem mais de uma vez, independentemente um do outro. Cobre também um eventual reenvio duplicado do lado do Notifier (publish retry).
> 6. **Retry de chamada de tool** (Storage Writer, coleta de documentos): chave de objeto determinística no object storage, tornando a gravação idempotente por natureza (sobrescreve em vez de duplicar).

---

## 4. Avaliação da Arquitetura (ATAM)

A avaliação segue o método **ATAM** (*Architecture Tradeoff Analysis Method*), conforme descrito por Bass, Clements e Kazman (2021).

### 4.1 Análise das Abordagens Arquiteturais
*(CA-2.1 — deve contemplar todos os RNF)*

| Atributo de Qualidade | Cenário | Importância | Complexidade |
| --- | --- | --- | --- |
| `TODO` | `TODO` | | |

### 4.2 Cenários
*(CA-2.2 — um cenário para cada RNF da seção 2.3)*

- **Cenário 1** — `TODO`
- **Cenário 2** — `TODO`

`Semente para quando escrever — cenário de disponibilidade (RNF03): explicitar no escopo do cenário que os 99,9% cobrem a infraestrutura própria da plataforma (GKE + Cloud SQL + Memorystore + Pub/Sub, cujos SLAs individuais já sustentam essa meta — ver nota da seção 2.3), não a SLA de provedores terceiros fora do controle da arquitetura (provedor de LLM, Google Drive API, SendGrid, OneSignal). A disponibilidade fim-a-fim de uma solicitação depende também desses terceiros — declarar essa fronteira explicitamente no cenário evita prometer cobertura sobre algo que a plataforma não controla, e antecipa a pergunta óbvia de banca ("como vocês garantem isso, dado que dependem de APIs externas?").`

### 4.3 Evidências da Avaliação
*(CA-2.3 — pelo menos 2 evidências por avaliação: 1 textual + 1 figura)*

`TODO: para cada cenário, preencher Atributo/Requisito/Preocupação/Ambiente/Estímulo/Mecanismo/Medida de resposta/Riscos.`

---

## 5. Avaliação Crítica dos Resultados
*(CA-2.4 — prós e contras da arquitetura)*

`TODO`

`Semente para quando escrever — observação de escopo: a decisão de deploy (Kubernetes/GKE em produção, GitHub Actions para CI/CD) foi definida só em nível de mecanismo arquitetural (seção 2.4), sem aprofundar pipeline (steps de build/deploy), estratégia de versionamento de imagem/API ou GitOps — por estar fora do escopo deste trabalho, que é modelagem arquitetural, não implementação/construção (regulamento, seção 2).`

`Semente para quando escrever — trade-off "sem BFF" (seção 2.4): decisão considerada razoável para o escopo atual (canais com necessidades de dados semelhantes, operações simples de disparo/consulta de status), mas vale registrar como contraponto explícito: o Mobile App é o canal com requisito genuinamente diferente dos demais (RNF06 — offline-first, banda limitada), então se no futuro ele precisar de payloads mais enxutos/agregados, a API de Sinistros compartilhada tende a acumular lógica condicional por cliente — sintoma clássico que levaria a introduzir um BFF só para o mobile, não para todos os canais. Se essa evolução for adotada, o cuidado de design é não duplicar responsabilidade já resolvida em outra camada: o BFF deve se restringir a moldar payload, nunca reimplementar autenticação/rate limiting (já no API Gateway) nem recalcular status/dados que já são responsabilidade da API de Sinistros (Query Handler, CQRS) — senão cria-se uma segunda fonte de verdade.`

`Semente para quando escrever — correção de consistência: Prompt Config Store isolado do Postgres do pipeline (seção 2.4): a primeira versão da modelagem colocava Temporal Server, Init Worker e MCP Host compartilhando uma única instância de Cloud SQL (schemas separados). Revisão identificou que MCP Host pertence a um domínio diferente dos outros dois — configuração de agentes/LLM (dado escrito em runtime pelo administrador via Agent Console, RF05 — só o *schema* das tabelas é que evolui via migração tipo Flyway/Liquibase, gerido pela própria aplicação) vs. execução de workflow (dado operacional de alto volume, schema gerenciado automaticamente pelo próprio Temporal) — e que o Prompt Config Store guarda credencial sensível (chaves de API de LLM), o mesmo tipo de dado que já justificou instância própria pro Keycloak. Corrigido para MCP Host ter instância própria, isolada da base de execução do pipeline (Temporal Server + Init Worker, que permanecem juntos por serem o mesmo domínio de execução — Init Worker é a própria activity de step 1 orquestrada pelo Temporal). Bom exemplo pra Avaliação Crítica: mostra o princípio *Database per Service* sendo aplicado por domínio de negócio (bounded context), não só por "quem tecnicamente pode compartilhar instância sem colidir".`

---

## 6. Conclusão
*(CA-2.5 — lições aprendidas, trade-offs, possibilidades de melhoria)*

`TODO`

`Semente para quando escrever — possibilidade de melhoria já identificada: o cluster GKE usado neste TCC é single-region; uma evolução natural para maior resiliência seria um cluster multi-region (ou multi-cluster) com failover automático, cobrindo cenários de indisponibilidade de uma região inteira do GCP — hoje fora do escopo do RNF03 (99,9%).`

---

## Referências
*(CA-2.6, peso 5 — o template descreve como "recomendado", mas a rubrica exige explicitamente pelo menos 5 boas referências, avaliadas por qualidade/atualização/adequação; tratar como item obrigatório, não opcional. Normas ABNT.)*

- SUSEP. Circular SUSEP nº 621, de 12 de fevereiro de 2021. Dispõe sobre as regras de funcionamento e os critérios para operação das coberturas dos seguros de danos. Brasília: Diário Oficial da União, 17 fev. 2021. Disponível em: https://www.in.gov.br/en/web/dou/-/circular-susep-n-621-de-12-de-fevereiro-de-2021-303756056. Acesso em: 06 ago. 2026.
- CONJUR. A duração razoável da regulação do sinistro pela seguradora. *Consultor Jurídico*, 28 mar. 2024. Disponível em: https://www.conjur.com.br/2024-mar-28/a-duracao-razoavel-da-regulacao-do-sinistro-pela-seguradora/. Acesso em: 06 ago. 2026.
- MOBILE TIME. IA é usada por 80% das seguradoras no Brasil, diz CNSeg. *Mobile Time*, 24 fev. 2026. Disponível em: https://www.mobiletime.com.br/noticias/24/02/2026/ia-seguradoras-80-brasil/. Acesso em: 06 ago. 2026.
- ANTHROPIC. *Introducing the Model Context Protocol*. 25 nov. 2024. Disponível em: https://www.anthropic.com/news/model-context-protocol. Acesso em: 06 ago. 2026.
- BROWN, Simon. *The C4 model for visualising software architecture*. [s.d.]. Disponível em: https://c4model.com/. Acesso em: 06 ago. 2026.
- BASS, Len; CLEMENTS, Paul; KAZMAN, Rick. *Software Architecture in Practice*. 4. ed. Boston: Addison-Wesley Professional, 2021. 464 p. ISBN 978-0-13-688588-7 (e-book).
- HARDT, Dick (ed.). *The OAuth 2.0 Authorization Framework (RFC 6749)*. Internet Engineering Task Force (IETF), out. 2012. Disponível em: https://www.rfc-editor.org/info/rfc6749. Acesso em: 06 ago. 2026.
- TEMPORAL TECHNOLOGIES. *Temporal documentation: durable execution*. [s.d.]. Disponível em: https://docs.temporal.io/. Acesso em: 06 ago. 2026.
- COCKBURN, Alistair. *Hexagonal architecture*. 2005. Disponível em: https://alistair.cockburn.us/hexagonal-architecture/. Acesso em: 10 ago. 2026.
