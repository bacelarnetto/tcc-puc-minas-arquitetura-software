// Relações entre atores/sistemas externos e a Plataforma RelatoSeg.
// Editar aqui quando: uma seta mudar de direção/rótulo, ou surgir/sumir uma integração.
// Dividido em nível Contexto (sistema como caixa-preta) e nível Container (mesmas relações,
// detalhadas por container) — igual à separação já usada nos diagramas Mermaid do relatório.

// --- Nível Contexto (espelha 3.1) ---
segurada -> relatoSeg "Envia fotos e dados do dano"
regulador -> workflowBpm "Solicita análise do sinistro"
workflowBpm -> relatoSeg "Dispara geração"
relatoSeg -> workflowBpm "Atualiza status"
regulador -> relatoSeg "Acompanha status"
corretor -> relatoSeg "Acompanha status dos sinistros do cliente"
admin -> relatoSeg "Cria e configura agentes, cadastra MCP Servers"
relatoSeg -> ssoCorporativo "Federa identidade (usuários internos)"
relatoSeg -> dataWarehouse "Consulta dados estruturados"
relatoSeg -> sistemaApolices "Consulta documentos (laudos periciais)"
relatoSeg -> servicoDocumentos "Gera parecer/documento"
relatoSeg -> provedorLLM "Invoca agente (chat completion)"
relatoSeg -> regulador "Notifica por e-mail (conclusão/erro)"
relatoSeg -> corretor "Notifica por e-mail (conclusão/erro)"
relatoSeg -> segurada "Push notification (resultado)"

// --- Nível Container: 3.2.1 Entrada, Autenticação e Roteamento ---
segurada -> relatoSeg.mobileApp "Usa"
segurada -> relatoSeg.webPortal "Usa"
regulador -> relatoSeg.webConsole "Usa"
corretor -> relatoSeg.webConsole "Usa"
admin -> relatoSeg.iap "Acesso restrito por IP/identidade"
relatoSeg.iap -> relatoSeg.agentConsole "Autorizado"

relatoSeg.mobileApp -> relatoSeg.keycloak "Login (OIDC)"
relatoSeg.webPortal -> relatoSeg.keycloak "Login (OIDC)"
relatoSeg.webConsole -> relatoSeg.keycloak "Login (OIDC)"
relatoSeg.agentConsole -> relatoSeg.keycloak "Login (OIDC)"
relatoSeg.gateway -> relatoSeg.keycloak "Valida token (JWKS)"
relatoSeg.keycloak -> relatoSeg.keycloakDb "Persiste realms/usuários"
relatoSeg.keycloak -> ssoCorporativo "Federa (realm interno)"

relatoSeg.mobileApp -> relatoSeg.gateway "Envia fotos + dados do dano (offline-first)"
relatoSeg.webPortal -> relatoSeg.gateway "Envia fotos + dados do dano"
relatoSeg.webConsole -> relatoSeg.gateway "Consulta status/histórico"
relatoSeg.agentConsole -> relatoSeg.gateway "Cria/configura agentes, cadastra MCP Servers"
relatoSeg.gateway -> relatoSeg.sinistroApi "Roteia"

workflowBpm -> relatoSeg.sinistroApi "Dispara (client credentials)"
workflowBpm -> relatoSeg.keycloak "Client credentials"
relatoSeg.sinistroApi -> workflowBpm "Atualiza status"

relatoSeg.sinistroApi -> relatoSeg.sinistroDb "Grava registro inicial (view)"
relatoSeg.sinistroApi -> relatoSeg.sinistroDb "Consulta status/histórico"
relatoSeg.sinistroApi -> relatoSeg.temporalServer "Inicia workflow"

// --- Nível Container: 3.2.2 Coleta e Consolidação de Dados (steps 1-4) ---
relatoSeg.temporalServer -> relatoSeg.postgresPipeline "Persiste histórico de execução (interno)"
relatoSeg.temporalServer -> relatoSeg.initWorker "Orquestra activity"
relatoSeg.initWorker -> relatoSeg.postgresPipeline "Persiste solicitação (step 1)"
relatoSeg.temporalServer -> relatoSeg.mcpHost "Orquestra activity"
relatoSeg.gateway -> relatoSeg.mcpHost "Roteia (Agent Console: cria/configura agentes, cadastra MCP Servers)"
relatoSeg.mcpHost -> relatoSeg.keycloak "Client credentials"
relatoSeg.mcpHost -> relatoSeg.promptConfigDb "Persiste prompts/config (Prompt Config Store)"
relatoSeg.mcpHost -> provedorLLM "Chama LLM (chat completion)"
relatoSeg.mcpHost -> relatoSeg.toolsApi "Chama tools via protocolo MCP (token M2M)"
relatoSeg.toolsApi -> dataWarehouse "Consulta dados estruturados"
relatoSeg.toolsApi -> sistemaApolices "Consulta documentos (laudos periciais)"
relatoSeg.toolsApi -> relatoSeg.redis "Cache leitura"
relatoSeg.toolsApi -> relatoSeg.storage "Grava dados brutos"
relatoSeg.temporalServer -> relatoSeg.reportBuilder "Orquestra activity"
relatoSeg.reportBuilder -> relatoSeg.storage "Consolida metadado"
relatoSeg.temporalServer -> relatoSeg.documentGenerator "Orquestra activity"
relatoSeg.documentGenerator -> relatoSeg.storage "Lê metadado"
relatoSeg.documentGenerator -> servicoDocumentos "Gera documento"

// --- Nível Container: 3.2.3 Notificação (step 5) e Consumo do Resultado ---
relatoSeg.temporalServer -> relatoSeg.notifier "Orquestra activity"
relatoSeg.notifier -> relatoSeg.pubsub "Publica resultado/erro (tópico)"
relatoSeg.pubsub -> relatoSeg.sinistroApi "Subscription: view"
relatoSeg.sinistroApi -> relatoSeg.sinistroDb "Atualiza status final"
relatoSeg.pubsub -> relatoSeg.notificationApi "Subscription: notificação (independente)"
relatoSeg.notificationApi -> servicoEmail "Envia e-mail"
relatoSeg.notificationApi -> servicoPush "Dispara push"
servicoEmail -> regulador "Notifica por e-mail"
servicoEmail -> corretor "Notifica por e-mail"
servicoPush -> segurada "Push notification"
