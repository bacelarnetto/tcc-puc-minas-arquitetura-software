// Pessoas e sistemas externos à Plataforma RelatoSeg (fora do boundary "softwareSystem").
// Editar aqui quando: surgir um novo tipo de usuário/ator, ou uma nova integração externa
// (sistema legado, provedor terceiro) que a plataforma passa a consumir.

segurada = person "Segurada" "Cliente da seguradora que sofreu o sinistro; envia fotos e dados do dano via app mobile ou web portal"
regulador = person "Regulador de Sinistros" "Analisa e decide sobre os sinistros reportados; solicita a análise via Workflow/BPM"
corretor = person "Corretor de Seguros" "Acompanha o status dos sinistros dos clientes que representa"
admin = person "Administrador de Plataforma" "Funcionário técnico/de negócio da seguradora; configura agentes, modelos de LLM, prompts e cadastra novos MCP Servers"

// Agrupados: em qualquer view, o Structurizr desenha a fronteira só ao redor dos que
// estiverem incluídos naquela view específica (não precisa estar todos presentes) — por isso
// um único group serve tanto pro Contexto (todos os 8) quanto pra cada view de Container
// (só o subconjunto que ela usa).
group "Sistemas Externos" {
    workflowBpm = softwareSystem "Sistema de Workflow/BPM" "Sistema de workflow já existente na seguradora; dispara e recebe atualização de status das solicitações de análise" "Existing System"
    ssoCorporativo = softwareSystem "SSO Corporativo" "Provedor de identidade corporativo já existente na seguradora; federado pelo Keycloak (realm interno)" "Existing System"
    dataWarehouse = softwareSystem "Data Warehouse Corporativo" "Réplica analítica de dados estruturados de apólices e sinistros (ex.: BigQuery)" "Existing System"
    sistemaApolices = softwareSystem "Sistema de Apólices e Sinistros" "Sistemas internos da seguradora; fonte de documentos como laudos periciais" "Existing System"
    servicoDocumentos = softwareSystem "Serviço de Documentos" "Armazenamento do parecer final gerado (ex.: Google Drive)" "Existing System"
    provedorLLM = softwareSystem "Provedor de LLM" "API paga de modelo de linguagem consumida pelo MCP Host (ex.: OpenAI, Anthropic, Gemini)" "Existing System"
    servicoEmail = softwareSystem "Serviço de E-mail" "Envio de notificação por e-mail (SendGrid)" "Existing System"
    servicoPush = softwareSystem "Serviço de Push Notification" "Envio de notificação push para o app mobile (OneSignal)" "Existing System"
}
