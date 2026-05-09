SOURCE_FOLDER := source

ASCIIDOC_FILES := $(wildcard $(SOURCE_FOLDER)/*.adoc)

FIGURES = $(shell find . -name '*.svg')

PDF_NAME := book.pdf
PDF_PATH := output/$(PDF_NAME)

EPUB_NAME := book.epub
EPUB_PATH := output/$(EPUB_NAME)

ASCIIDOC_FLAGS = \
  --doctype book

# Auto-detect PlantUML jar on macOS Homebrew if env var unset (no-op on Linux).
PLANTUML_JAR_MACOS := /opt/homebrew/opt/plantuml/libexec/plantuml.jar
ifeq ($(DIAGRAM_PLANTUML_CLASSPATH),)
ifneq ($(wildcard $(PLANTUML_JAR_MACOS)),)
export DIAGRAM_PLANTUML_CLASSPATH := $(PLANTUML_JAR_MACOS)
endif
endif

all: $(PDF_PATH) $(EPUB_PATH)

$(PDF_PATH): $(ASCIIDOC_FILES) $(FIGURES) Makefile metadata.yaml themes/letterpress-theme.yml | output
	asciidoctor-pdf book.adoc $(ASCIIDOC_FLAGS) \
		-a pdf-theme=letterpress \
		-a pdf-themesdir=themes \
		-o $@ \
		-r asciidoctor-diagram \
		-r asciidoctor-mathematical

$(EPUB_PATH): $(ASCIIDOC_FILES) $(FIGURES) Makefile metadata.yaml epub-styles/epub3.scss | output
	asciidoctor-epub3 book.adoc $(ASCIIDOC_FLAGS) \
		-a epub3-stylesdir=epub-styles \
		-o $@ \
		-r asciidoctor-diagram \
		-r asciidoctor-mathematical

count:
	wc -w source/*

output:
	mkdir output

clean:
	rm -vrf output

lint:
	vale source/

# macOS-only: install all system + Ruby dependencies via Homebrew.
# Linux/Windows users: use the devcontainer or asciidoctor/docker-asciidoctor image.
setup-macos:
	@command -v brew >/dev/null || { echo "Homebrew required. https://brew.sh"; exit 1; }
	brew install ruby@3.3 plantuml mermaid-cli cmake bison flex cairo pango glib gdk-pixbuf
	cd /opt/homebrew/Cellar/mermaid-cli/*/libexec/lib/node_modules/@mermaid-js/mermaid-cli && \
		node node_modules/puppeteer/install.mjs
	env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
		CMAKE_POLICY_VERSION_MINIMUM=3.5 \
		PATH="/opt/homebrew/opt/flex/bin:/opt/homebrew/opt/bison/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
		/opt/homebrew/opt/ruby@3.3/bin/bundle install
	@echo ""
	@echo "Setup complete. Add this to your shell profile or run before each build:"
	@echo "  export PATH=\"/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:\$$PATH\""

.PHONY: all count clean lint setup-macos
