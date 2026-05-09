#!/usr/bin/env bash
# Build PDF for every theme in themes/ and one EPUB.
# Outputs: output/<theme-name>.pdf  output/book.epub
set -uo pipefail

cd "$(dirname "$0")"
mkdir -p output

LOG=output/build-all-themes.log
> "$LOG"

PASS=(); FAIL=()

for yml in themes/*-theme.yml; do
  name="${yml#themes/}"
  name="${name%-theme.yml}"
  out="output/${name}.pdf"
  echo "=== Building PDF: ${name} ===" | tee -a "$LOG"
  if env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
    DIAGRAM_PLANTUML_CLASSPATH="${DIAGRAM_PLANTUML_CLASSPATH:-/opt/homebrew/opt/plantuml/libexec/plantuml.jar}" \
    PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
    asciidoctor-pdf book.adoc \
      --doctype book \
      -a "pdf-theme=${name}" \
      -a "pdf-themesdir=themes" \
      -r asciidoctor-diagram \
      -r asciidoctor-mathematical \
      -o "$out" >> "$LOG" 2>&1; then
    echo "  OK: $out ($(du -h "$out" | cut -f1))" | tee -a "$LOG"
    PASS+=("$name")
  else
    echo "  FAIL: $name" | tee -a "$LOG"
    FAIL+=("$name")
  fi
done

echo "" | tee -a "$LOG"
echo "=== Building EPUB ===" | tee -a "$LOG"
if env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
  DIAGRAM_PLANTUML_CLASSPATH="${DIAGRAM_PLANTUML_CLASSPATH:-/opt/homebrew/opt/plantuml/libexec/plantuml.jar}" \
  PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
  asciidoctor-epub3 book.adoc \
    --doctype book \
    -a epub3-stylesdir=epub-styles \
    -r asciidoctor-diagram \
    -r asciidoctor-mathematical \
    -o output/book.epub >> "$LOG" 2>&1; then
  echo "  OK: output/book.epub ($(du -h output/book.epub | cut -f1))" | tee -a "$LOG"
else
  echo "  FAIL: EPUB" | tee -a "$LOG"
fi

echo "" | tee -a "$LOG"
echo "=== SUMMARY ===" | tee -a "$LOG"
echo "PASSED (${#PASS[@]}): ${PASS[*]}" | tee -a "$LOG"
echo "FAILED (${#FAIL[@]}): ${FAIL[*]:-none}" | tee -a "$LOG"
echo "" | tee -a "$LOG"
echo "PDFs in output/:" | tee -a "$LOG"
ls -lh output/*.pdf 2>/dev/null | tee -a "$LOG"
