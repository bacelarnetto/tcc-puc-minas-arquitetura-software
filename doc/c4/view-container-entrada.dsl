// Corresponde à seção 3.2.1 do relatório (Entrada, Autenticação e Roteamento).
// Editar aqui: quais containers/atores aparecem nesta view específica.
// Para mudar descrição/tecnologia de um container, editar model-plataforma.dsl.
// MCP Host aparece só como ponto de continuidade do roteamento do Agent Console — detalhado
// em view-container-pipeline.dsl, não duplicar Tools API/Report Builder/Document Generator aqui.

container relatoSeg "Container_Entrada" {
    include segurada
    include regulador
    include corretor
    include admin
    include workflowBpm
    include ssoCorporativo
    include relatoSeg.mobileApp
    include relatoSeg.webPortal
    include relatoSeg.webConsole
    include relatoSeg.agentConsole
    include relatoSeg.iap
    include relatoSeg.gateway
    include relatoSeg.mcpHost
    include relatoSeg.keycloak
    include relatoSeg.keycloakDb
    include relatoSeg.sinistroApi
    include relatoSeg.sinistroDb
    include relatoSeg.temporalServer
    autoLayout tb
    description "Diagrama de Container 3.2.1 — Entrada, Autenticação e Roteamento"
}
