#!/usr/bin/env bash
# Build the book PDF (macOS).
# Usage:
#   ./make-pdf.sh                         # default theme, default output
#   ./make-pdf.sh path/to/out.pdf         # custom output path
#   THEME=mytheme ./make-pdf.sh           # custom theme (themes/mytheme.yml)
#   THEMES_DIR=path/to/themes ./make-pdf.sh
set -euo pipefail

OUT="${1:-output/book.pdf}"
THEME="${THEME:-letterpress}"
THEMES_DIR="${THEMES_DIR:-themes}"

env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
  DIAGRAM_PLANTUML_CLASSPATH="${DIAGRAM_PLANTUML_CLASSPATH:-/opt/homebrew/opt/plantuml/libexec/plantuml.jar}" \
  PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
  asciidoctor-pdf book.adoc \
    --doctype book \
    -a "pdf-theme=${THEME}" \
    -a "pdf-themesdir=${THEMES_DIR}" \
    -r asciidoctor-diagram \
    -r asciidoctor-mathematical \
    -o "$OUT"

echo ""
echo "Built: $OUT ($(du -h "$OUT" | cut -f1)) — theme: ${THEME}"
