SOURCE_FOLDER := source

SHELL := /bin/bash

ASCIIDOC_FILES := $(wildcard $(SOURCE_FOLDER)/*.adoc)

FIGURES := $(wildcard figures/*)

PDF_NAME := book.pdf
PDF_PATH := output/$(PDF_NAME)

EPUB_NAME := book.epub
EPUB_PATH := output/$(EPUB_NAME)

ASCIIDOC_FLAGS := \
  -r asciidoctor-diagram \
  -r asciidoctor-mathematical

.PHONY: all count clean lint epubcheck

all: $(PDF_PATH) $(EPUB_PATH)

$(PDF_PATH): $(ASCIIDOC_FILES) $(FIGURES) Makefile | output
	asciidoctor-pdf book.adoc $(ASCIIDOC_FLAGS) -o $@

$(EPUB_PATH): $(ASCIIDOC_FILES) $(FIGURES) Makefile | output
	asciidoctor-epub3 book.adoc $(ASCIIDOC_FLAGS) -o $@

count:
	@dir="$(SOURCE_FOLDER)"; \
	total=0; \
	while read -r file; do \
		words=$$(wc -w < "$$file"); \
		total=$$((total + words)); \
		printf "%6d %s\n" "$$words" "$$file"; \
	done < <(find "$$dir" -type f -name "*.adoc" | sort); \
	printf "%6d total\n" "$$total"

epubcheck: $(EPUB_PATH)
	epubcheck $(EPUB_PATH)

output:
	mkdir output

clean:
	rm -vrf output

lint:
	vale source/
