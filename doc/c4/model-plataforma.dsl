// A Plataforma RelatoSeg e seus containers (nível 2, C4).
// Editar aqui quando: um container novo entrar/sair da arquitetura, ou a descrição/tecnologia
// de um container existente mudar. Agrupado em 3 "group" (fronteira visual) que espelham as
// mesmas 3 áreas do relatório (3.2.1/3.2.2/3.2.3) — usado pela view macro para desenhar as
// caixas rotuladas; todos pertencem ao mesmo softwareSystem.

relatoSeg = softwareSystem "RelatoSeg" "Plataforma de orquestração de agentes de IA (LLM) via MCP para geração automatizada de pareceres de sinistro" {

    group "Entrada, Autenticação e Roteamento" {
        mobileApp = container "Mobile App" "Envio de fotos e dados do dano pela segurada, com captura offline-first (RNF06)" "React Native"
        webPortal = container "Web Portal" "Canal web alternativo para a segurada (uso externo)" "React"
        webConsole = container "Web Console" "Acompanhamento de status/histórico por regulador e corretor (uso interno)" "React"
        agentConsole = container "Agent Console" "Criação/configuração de agentes e cadastro de MCP Servers, uso técnico/interno" "React"
        iap = container "Identity-Aware Proxy" "Restrição de acesso de rede à Agent Console, na borda, antes do login" "Google Cloud IAP"
        gateway = container "API Gateway" "Autenticação, rate limiting e roteamento de negócio; entrada única self-service" "Spring Cloud Gateway"
        keycloak = container "Keycloak" "IAM — realm interno (federado ao SSO corporativo) e realm externo (segurada)" "Keycloak"
        keycloakDb = container "Base do Keycloak" "Realms e usuários, instância isolada por ser dado sensível" "Cloud SQL for PostgreSQL" "Database"
        sinistroApi = container "API de Sinistros" "Gatilho + view (CQRS): grava registro inicial, inicia o Temporal, expõe status/histórico" "Spring Boot"
        sinistroDb = container "Base de Sinistros" "Modelo de leitura (CQRS), isolado do estado interno da orquestração" "Cloud SQL for PostgreSQL" "Database"
    }

    group "Coleta e Consolidação de Dados (steps 1-4)" {
        temporalServer = container "Temporal Server" "Orquestração durável do pipeline (steps 1-5): retries automáticos e dedup por Workflow ID" "Temporal.io"
        initWorker = container "Init Worker" "Step 1: persiste a solicitação — activity orquestrada pelo Temporal" "Spring Boot"
        mcpHost = container "MCP Host" "Step 2: Spring MCP Client — orquestra os agentes de IA, chama o LLM e as tools" "Spring AI"
        toolsApi = container "Tools API" "Step 2: Spring MCP Service (Server) — expõe tools de consulta a apólice/sinistro/documentos" "Spring AI"
        reportBuilder = container "Report Builder" "Step 3: consolida os dados brutos coletados em metadado padronizado" "Spring Boot"
        documentGenerator = container "Document Generator" "Step 4: gera o documento final do parecer a partir do metadado" "Spring Boot"
        storage = container "Object Storage" "Dados brutos coletados e metadado consolidado" "Google Cloud Storage" "Database"
        postgresPipeline = container "Base do Pipeline" "Schema por dono: Temporal Server (histórico, gerenciado pelo próprio Temporal) e Init Worker (registro da solicitação)" "Cloud SQL for PostgreSQL" "Database"
        promptConfigDb = container "Base do Prompt Config Store" "Instância própria do MCP Host, isolada da base de execução do pipeline — domínio de configuração de agentes/LLM, guarda chaves de API (dado sensível), mesmo raciocínio da base do Keycloak" "Cloud SQL for PostgreSQL" "Database"
        redis = container "Cache de Leitura" "Cache de consultas frequentes de apólice/sinistro pela Tools API" "Memorystore for Redis" "Database"
    }

    group "Notificação (step 5)" {
        notifier = container "Notifier" "Step 5: publica o resultado (sucesso ou erro) no tópico de notificação" "Spring Boot"
        pubsub = container "Tópico de Notificação" "Fanout via duas subscriptions independentes (view e notificação)" "Google Cloud Pub/Sub" "Queue"
        notificationApi = container "API de Notificação" "Consumidora independente; dispara e-mail/push; reutilizável entre domínios (RF15)" "Spring Boot"
    }
}
