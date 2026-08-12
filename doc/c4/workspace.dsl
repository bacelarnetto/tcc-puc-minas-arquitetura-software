// Ponto de entrada. Não editar model/views aqui — só amarra os arquivos separados.
// Subir com: docker compose up -d (dentro de doc/c4), depois abrir http://localhost:8080.

workspace "RelatoSeg" "Arquitetura de referência distribuída para orquestração de agentes de IA (LLM) via MCP, aplicada à geração automatizada de pareceres de sinistro de seguros" {

    !identifiers hierarchical

    model {
        !include model-atores.dsl
        !include model-plataforma.dsl
        !include model-relacionamentos.dsl
    }

    views {
        !include view-contexto.dsl
        !include view-container-macro.dsl
        !include view-container-entrada.dsl
        !include view-container-pipeline.dsl
        !include view-container-notificacao.dsl
        !include styles.dsl
    }

    configuration {
        scope softwaresystem
    }
}
