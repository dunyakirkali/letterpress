#!/usr/bin/env bash
# Build the book EPUB (macOS).
# Usage:
#   ./make-epub.sh                         # default style, default output
#   ./make-epub.sh path/to/out.epub        # custom output path
#   STYLE_DIR=my-styles ./make-epub.sh     # custom style dir (must contain epub3.css)
set -euo pipefail

OUT="${1:-output/book.epub}"
STYLE_DIR="${STYLE_DIR:-epub-styles}"

env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
  DIAGRAM_PLANTUML_CLASSPATH="${DIAGRAM_PLANTUML_CLASSPATH:-/opt/homebrew/opt/plantuml/libexec/plantuml.jar}" \
  PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
  asciidoctor-epub3 book.adoc \
    --doctype book \
    -a "epub3-stylesdir=${STYLE_DIR}" \
    -r asciidoctor-diagram \
    -r asciidoctor-mathematical \
    -o "$OUT"

echo ""
echo "Built: $OUT ($(du -h "$OUT" | cut -f1)) — style dir: ${STYLE_DIR}"
