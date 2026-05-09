# letterpress

AsciiDoctor self-publishing book template. Repo: https://github.com/dunyakirkali/letterpress

Setup history and gotchas: see `troubleshooting-log.md`.

## Features

### Output formats
- **PDF** via `asciidoctor-pdf` (cover + back cover images, TOC, font icons, part numbering)
- **EPUB** via `asciidoctor-epub3`
- Reproducible builds (`:reproducible:` attr)

### Authoring
- Standard book structure: front matter (colophon, dedication, preface) → body (chapters) → back matter (about, index)
- Index term syntax: `((term))` auto-collected into index
- Admonition blocks: `[NOTE]`, `[TIP]`, `[IMPORTANT]`
- Sidebar blocks, quote blocks, tables (`[cols="..."]`)
- Cover art via `:front-image:` / `:back-image:` attrs (`backgrounds/`)
- Book metadata in `metadata.yaml` (title, author, rights, date, category, wordcount)

### Diagrams (`asciidoctor-diagram`)
- **PlantUML** — UML class/sequence/component diagrams (Java + plantuml.jar)
- **Mermaid** — flowcharts, graphs (mmdc + headless Chrome)

### Math (`asciidoctor-mathematical`)
- LaTeX equations via `[stem]` blocks → rendered to images for PDF

### Code highlighting
- `[source,<lang>]` blocks via **Rouge** (`:source-highlighter: rouge`)
- Examples in repo: Elixir, Go

### Quality / CI
- **Vale linting** (`make lint`) — Google + proselint + write-good + Readability styles
- **Word count** (`make count`) — wraps `wc -w source/*`
- **GitHub Actions CI** — runs vale + word count on push/PR
- **GitHub Actions CD** — manual `workflow_dispatch` builds PDF + EPUB inside `asciidoctor/docker-asciidoctor` container, uploads as artifacts

### Dev environment
- **Devcontainer** with `asciidoctor/docker-asciidoctor` image + VSCode extensions (asciidoctor, makefile-tools, vale)

## Build commands

```bash
make output/book.pdf    # PDF
make output/book.epub   # EPUB
make                    # both
make count              # word count
make lint               # vale
make clean              # remove output/
```

## Required env (local macOS)

Makefile invokes `asciidoctor-pdf` from PATH. Two copies via brew:

- `/opt/homebrew/bin/asciidoctor-pdf` → Ruby 4.0 (BROKEN)
- `/opt/homebrew/lib/ruby/gems/3.3.0/bin/asciidoctor-pdf` → Ruby 3.3 (WORKS)

Every build needs:

```bash
env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
  DIAGRAM_PLANTUML_CLASSPATH=/opt/homebrew/opt/plantuml/libexec/plantuml.jar \
  PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
  make output/book.pdf
```

## Gotchas

- **RVM hijacks gem/ruby** — clean env (`-u GEM_HOME ...`) required even with absolute paths.
- **Don't use brew Ruby 4.0** — asciidoctor-pdf needs stdlib gems removed in 4.0.
- **Don't `rbenv install`** — fails on openssl. Use `brew install ruby@3.3`.
- **`mathematical 1.6.20` + cmake 4.x** — needs `CMAKE_POLICY_VERSION_MINIMUM=3.5` at gem install.
- **Mermaid Chrome pinning** — use mermaid-cli's bundled puppeteer (`node_modules/puppeteer/install.mjs`), not `npx`.

## Structure

```
book.adoc                  ← entry; sets attrs, includes front/body/back
metadata.yaml              ← book metadata
source/
  front_matter.adoc        ← includes colophon, dedication, preface
  body.adoc                ← includes chapter1-5
  back_matter.adoc         ← includes about, index
  chapter1-5.adoc          ← edit chapters here
figures/                   ← images referenced by image::
backgrounds/               ← cover.png, back-cover.png
output/                    ← build artifacts
.github/workflows/         ← CI + CD pipelines
.devcontainer/             ← VSCode container config
.vale.ini                  ← lint config
```

## AsciiDoc syntax reference

Asciidoctor (https://asciidoctor.org) is the upstream processor. Cheat sheet for common authoring needs:

### Output backends (asciidoctor processor)
HTML5, DocBook 5, manpages — built-in. PDF (asciidoctor-pdf), EPUB3 (asciidoctor-epub3), reveal.js slides — via converter gems.

### Text formatting
| Syntax | Result |
|--------|--------|
| `*bold*` / `**bold**` | constrained / unconstrained bold |
| `_italic_` / `__italic__` | constrained / unconstrained italic |
| `` `mono` `` | monospace |
| `#highlight#` | highlight |
| `^sup^` / `~sub~` | super/subscript |
| `[.line-through]#text#` | strikethrough |
| `[.lead]` paragraph | lead paragraph |

### Lists
- Unordered: `* item` (nest with `**`)
- Ordered: `. item` (nest with `..`)
- Checklist: `* [ ]` / `* [*]`
- Description: `term:: description`
- Q&A: `[qanda]` then `term:: answer`
- Continuation: standalone `+` line keeps next block in list item

### Blocks
| Delimiter | Block type |
|-----------|-----------|
| `----` | listing (code) |
| `....` | literal |
| `====` | example |
| `****` | sidebar |
| `____` | quote |
| `++++` | passthrough (raw HTML or stem math) |
| `--` | open block |

### Code listings
```
[source,ruby]
----
puts "hello" <1>
----
<1> Greeting

include::file.rb[tag=snippet]
include::file.rb[lines=5..10]
```

### Tables
```
[cols="1,2,3a",%header]
|===
| Col1 | Col2 | Col3
| a | b | _italic in cell_
|===
```
- `a` modifier on cols: render AsciiDoc inside cell
- formats: pipe (default), CSV, TSV, DSV

### Admonitions
Inline: `NOTE: text` · Block: `[NOTE]\n====\n...\n====`
Types: `NOTE`, `TIP`, `IMPORTANT`, `CAUTION`, `WARNING`. Icons via `:icons: font`.

### Links, anchors, xrefs
- Autolink: `https://example.com`
- Labelled: `https://example.com[click]`
- Anchor: `[[id]]` or `[#id]`
- Cross-ref: `<<id>>` or `<<id,custom text>>`
- Inter-doc: `xref:other.adoc#section[text]`

### Images
- Block: `image::file.jpg[Alt, width=500, align=center]`
- Inline: `image:icon.png[]`
- `:imagesdir:` attr sets default base path
- `:data-uri:` embeds images inline (single-file HTML)

### Includes
```
include::source/chapter.adoc[]
include::file.adoc[tag=region]
include::file.adoc[lines=10..20]
```

### Conditionals
```
ifdef::draft[]
DRAFT MARKER
endif::[]

ifndef::backend-pdf[]
ifeval::["{revnumber}" == "1.0"]
```

### Attributes
- Define: `:name: value` (in header or doc body)
- Reference: `{name}`
- Counter: `{counter:n}` / `{counter2:n}` (silent increment)
- Built-ins: `:toc:`, `:toclevels:`, `:source-highlighter:` (rouge/coderay/highlight.js/pygments), `:icons: font`, `:reproducible:`, `:partnums:`, `:doctype: book`, `:imagesdir:`, `:stem: latexmath`

### Footnotes / bibliography / index
- Footnote: `text.footnote:[content]` or `.footnote:name[content]` (reusable)
- Bibliography: `[bibliography]` section, entries `* [[[ref]]] Citation`. Cite with `<<ref>>`
- Index term: `((term))` (visible) or `(((Primary,Secondary,Tertiary)))` (hidden, multi-level)

### Math (STEM)
- Set `:stem:` (default `asciimath`) or `:stem: latexmath`
- Inline: `stem:[E = mc^2]`
- Block: `[stem]\n++++\n\\phi = \\frac{1+\\sqrt{5}}{2}\n++++`
- letterpress uses `asciidoctor-mathematical` to rasterize for PDF

### Diagrams (`asciidoctor-diagram` extension)
Supports PlantUML, Mermaid, Graphviz/dot, ditaa, blockdiag, ERD, Vega, Wavedrom, BPMN, etc.
Syntax: `[<engine>, <output-id>, <format>, <options>]\n----\n<source>\n----`

### Misc
- `// comment` (single line) · `////` block comment
- `'''` thematic break (hr)
- `<<<` page break (PDF/EPUB)
- `[discrete]` headline that stays out of TOC
- `+escape+` passthrough · `\` escape next char
- `[.role]` apply CSS class

### Doc header
```
= Book Title
Author Name <email@example.com>
v1.0, 2026-01-15
:doctype: book
:toc:
:toclevels: 2
:source-highlighter: rouge
:icons: font
:imagesdir: figures
```

## PDF themes

All theme files are in `themes/`. Use with:
```bash
THEME=<name> ./make-pdf.sh          # themes/<name>-theme.yml
THEMES_DIR=other/dir THEME=foo ./make-pdf.sh
```

### Built-in (ship with gem, no install)
| File | Description |
|---|---|
| `base-theme.yml` | Minimal, almost no styling |
| `default-theme.yml` | Screen-optimized, serif |
| `default-for-print-theme.yml` | Print-optimized, tight margins, no color |
| `default-sans-theme.yml` | Sans-serif base font |
| `default-with-font-fallbacks-theme.yml` | Default + Unicode/emoji |
| `default-for-print-with-font-fallbacks-theme.yml` | Print + extended chars |

### Official examples
| File | Description |
|---|---|
| `chronicles-theme.yml` | Book/literary, warm serif, decorative chapter headings |
| `chronicles-dark-theme.yml` | Dark variant; use with `-a rouge-style=molokai` |

### Community (saved to `themes/`)
| File | Style | Notes |
|---|---|---|
| `letterpress-theme.yml` | Book | Custom theme for this project |
| `pretty-theme.yml` | Clean | Ubuntu font, A4, red/blue accents |
| `sogo-minimal-theme.yml` | Minimal | Lato-Light body, Inconsolata code |
| `bentolor-pdfstyle-theme.yml` | General | Feature-rich template base |
| `redhat-refarch-theme.yml` | Corporate | Red Hat docs style, draft watermark support |
| `ferrao-corporate-theme.yml` | Corporate | Helvetica, A4, logo placeholder header |
| `whitepaper-theme.yml` | Whitepaper | Navy/gold, MarkOT fonts (must supply) |
| `word-like-theme.yml` | Office | MS Word look-alike |
| `uoc-academic-theme.yml` | Academic | SourceSerif4, print-optimized, student ID title page |
| `kuboaki-beauty-theme.yml` | Japanese | AozoraMincho + GenShinGothic, A4 |
| `daisuke-japanese-theme.yml` | Japanese | GenShinGothic + GenYoMinJP, full styling |
| `cjk-kaigen-theme.yml` | Chinese | Source Han Sans CN, Letter size |

### Theme authoring
Top-level keys: `page`, `font`, `base`, `heading`, `heading-h1`–`h6`, `code`, `codespan`, `table`, `admonition`, `sidebar`, `quote`, `header`, `footer`, `link`, `toc`, `title-page`.
Start with `extends: default`, override only what differs.
Full reference: https://docs.asciidoctor.org/pdf-converter/latest/theme/

## EPUB styles

No theme gallery — community resources sparse. Copy base CSS from gem:

```bash
gem contents asciidoctor-epub3 | grep epub3.css
# → copy the two files to your stylesdir
```

Required files in `epub3-stylesdir`:
- `epub3.css` — main styles
- `epub3-css3-only.css` — WebKit/CSS3 additions (can be empty)

Use: `STYLE_DIR=my-epub-styles ./make-epub.sh`

## Logs

Append every new install issue/fix to `troubleshooting-log.md`.
