SOURCE_FOLDER := source

ASCIIDOC_FILES := $(wildcard $(SOURCE_FOLDER)/*.adoc)

FIGURES = $(shell find . -name '*.svg')

PDF_NAME := book.pdf
PDF_PATH := output/$(PDF_NAME)

EPUB_NAME := book.epub
EPUB_PATH := output/$(EPUB_NAME)

ASCIIDOC_FLAGS = \
  --doctype book

all: $(PDF_PATH) $(EPUB_PATH)

$(PDF_PATH): $(ASCIIDOC_FILES) $(FIGURES) Makefile metadata.yaml | output
	asciidoctor-pdf source/book.adoc $(ASCIIDOC_FLAGS) \
		-o $@ \
		-r asciidoctor-diagram \
		-r asciidoctor-mathematical

$(EPUB_PATH): $(ASCIIDOC_FILES) $(FIGURES) Makefile metadata.yaml | output
	asciidoctor-epub3 source/book.adoc $(ASCIIDOC_FLAGS) \
		-o $@ \
		-r asciidoctor-diagram \
		-r asciidoctor-mathematical

count:
	wc -w source/*

output:
	mkdir output

clean:
	rm -vrf output
