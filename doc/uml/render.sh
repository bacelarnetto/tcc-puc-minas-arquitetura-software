#!/usr/bin/env bash
# Renderiza todos os .puml desta pasta em PNG, via Docker (imagem oficial plantuml/plantuml).
# Saída vai para doc/relatorio/diagramas/ — mesmo lugar dos diagramas C4 embutidos no relatório.
# Uso: ./render.sh (a partir de doc/uml/, ou de qualquer lugar — resolve o próprio caminho)

set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOC_DIR="$(cd "$DIR/.." && pwd)"
OUT_DIR="$DOC_DIR/relatorio/diagramas"

mkdir -p "$OUT_DIR"
docker run --rm -v "$DOC_DIR":/data plantuml/plantuml -tpng -o /data/relatorio/diagramas /data/uml/*.puml

echo "PNGs gerados em $OUT_DIR"
