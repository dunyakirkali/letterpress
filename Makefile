SOURCE_FOLDER := source

ASCIIDOC_FILES := $(wildcard $(SOURCE_FOLDER)/*.adoc)

FIGURES = $(shell find . -name '*.svg')

PDF_NAME := book.pdf

EPUB_NAME := book.epub

ASCIIDOC_FLAGS = \
  --doctype book

all: $(PDF_NAME) $(EPUB_NAME)

$(PDF_NAME): book.adoc $(ASCIIDOC_FILES) $(FIGURES) Makefile metadata.yaml
	asciidoctor-pdf book.adoc $(ASCIIDOC_FLAGS) \
		-o $@ \
		-r asciidoctor-diagram \
		-r asciidoctor-mathematical \
		-r asciidoctor-kroki \
		-a allow-uri-read \
		--safe-mode server

$(EPUB_NAME): book.adoc $(ASCIIDOC_FILES) $(FIGURES) Makefile metadata.yaml
	asciidoctor-epub3 book.adoc $(ASCIIDOC_FLAGS) \
		-o $@ \
		-r asciidoctor-diagram \
		-r asciidoctor-mathematical \
		-r asciidoctor-kroki \
		-a allow-uri-read \
		--safe-mode server

count:
	wc -w source/*

clean:
	rm -vrf $(PDF_NAME) $(EPUB_NAME)
