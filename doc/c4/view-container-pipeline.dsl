// Corresponde à seção 3.2.2 do relatório (Coleta e Consolidação de Dados, steps 1-4).
// Editar aqui: quais containers/sistemas externos aparecem nesta view específica.
// Para mudar descrição/tecnologia de um container, editar model-plataforma.dsl.
// Notifier (step 5) aparece só como ponto de continuidade da pipeline — detalhado em
// view-container-notificacao.dsl, não duplicar Pub/Sub/API de Notificação/Base de Sinistros aqui.
// Layout manual (workspace.json) tentado e revertido — drag não funciona nessa build do
// Structurizr e o posicionamento manual às cegas piorou o diagrama; voltamos pro autoLayout.

container relatoSeg "Container_Pipeline" {
    include relatoSeg.gateway
    include relatoSeg.temporalServer
    include relatoSeg.initWorker
    include relatoSeg.mcpHost
    include relatoSeg.toolsApi
    include relatoSeg.reportBuilder
    include relatoSeg.documentGenerator
    include relatoSeg.notifier
    include relatoSeg.storage
    include relatoSeg.postgresPipeline
    include relatoSeg.promptConfigDb
    include relatoSeg.redis
    include relatoSeg.keycloak
    include dataWarehouse
    include sistemaApolices
    include servicoDocumentos
    include provedorLLM
    autoLayout tb
    description "Diagrama de Container 3.2.2 — Coleta e Consolidação de Dados (steps 1-4)"
}
