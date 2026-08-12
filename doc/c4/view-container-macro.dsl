// Visão macro do Container (todos os 23 containers), agrupados nas 3 fronteiras rotuladas
// definidas em model-plataforma.dsl. Serve como "mapa geral" — para o detalhe granular de
// cada área, usar view-container-entrada.dsl / -pipeline.dsl / -notificacao.dsl na barra
// lateral do Structurizr (o zoom nativo por lupa só existe até o nível de Componente, não
// entre duas views de Container do mesmo sistema).

container relatoSeg "Container_Macro" {
    include *
    autoLayout tb
    description "Diagrama de Container — visão macro (todas as áreas agrupadas)"
}
