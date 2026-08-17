# tcc-puc-minas-arquitetura-software

Projeto Integrado — Relatório Técnico de Arquitetura de Software Distribuída.

**Sistema:** RelatoSeg — arquitetura de referência distribuída para orquestração de agentes de IA via MCP, aplicada à geração automatizada de relatórios de análise de sinistros de seguros.

**Relatório técnico:** [doc/relatorio/relatorio_tecnico.md](doc/relatorio/relatorio_tecnico.md)

## Estrutura do repositório

```
doc/
├── c4/          Diagramas C4 (DSL do Structurizr) + docker-compose
├── puc/         Material institucional do curso (não versionado)
├── relatorio/   Relatório técnico (docsify) e diagramas gerados
│   ├── index.html      Entrada do docsify
│   ├── relatorio_tecnico.md   Relatório técnico (fonte)
│   └── diagramas/       PNGs renderizados (C4 + UML)
└── uml/         Diagramas de componentes (PlantUML) + render.sh
```

## Diagramas C4 (Structurizr)

Os diagramas de contexto, container e componentes são modelados em DSL no `doc/c4/`.

Para visualizar no navegador:

```bash
cd doc/c4
docker compose up -d
# abra http://localhost:8080
```

O `workspace.dsl` apenas amarra os arquivos de model, views e styles separados.

## Diagramas de componentes (PlantUML)

Os diagramas de componentes de `doc/uml/` são renderizados para PNG em `doc/relatorio/diagramas/` (mesma pasta dos diagramas C4 embutidos no relatório) via Docker:

```bash
./doc/uml/render.sh
```

Requer Docker; a imagem `plantuml/plantuml` é baixada automaticamente do Docker Hub na primeira execução.

## Visualizar o relatório no navegador (docsify)

O relatório técnico (`doc/relatorio/`) é renderizado via [docsify](https://docsify.js.org/) — um gerador de documentação que roda sem build, direto dos arquivos `.md` (`index.html` + `relatorio_tecnico.md`).

Requer [Node.js](https://nodejs.org/) (o `npx` já vem junto). Para visualizar em `http://localhost:3000`:

```bash
cd doc/relatorio
npx docsify-cli serve . -p 3000
```

Na primeira execução o `npx` baixa o pacote `docsify-cli` automaticamente. O Mermaid e a busca são carregados via CDN pelo `index.html`.
