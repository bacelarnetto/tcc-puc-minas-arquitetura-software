// Corresponde à seção 3.2.3 do relatório (Notificação, step 5, e Consumo do Resultado).
// Editar aqui: quais containers/atores/sistemas externos aparecem nesta view específica.
// Para mudar descrição/tecnologia de um container, editar model-plataforma.dsl.

container relatoSeg "Container_Notificacao" {
    include relatoSeg.temporalServer
    include relatoSeg.notifier
    include relatoSeg.pubsub
    include relatoSeg.sinistroApi
    include relatoSeg.sinistroDb
    include relatoSeg.notificationApi
    include regulador
    include corretor
    include segurada
    include servicoEmail
    include servicoPush
    autoLayout tb
    description "Diagrama de Container 3.2.3 — Notificação (step 5) e Consumo do Resultado"
}
