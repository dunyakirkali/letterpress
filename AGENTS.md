# AGENTS.md

Guidance for AI coding agents (Claude Code, Cursor, Aider, Codex, ...) working in this repo.

## Project

AsciiDoctor self-publishing book template. Outputs **PDF** (`asciidoctor-pdf`) and **EPUB** (`asciidoctor-epub3`) from `book.adoc`.

## Build commands

```bash
make output/book.pdf    # PDF only
make output/book.epub   # EPUB only
make                    # both
make count              # word count (wc -w source/*)
make lint               # vale
make clean              # remove output/
```

## File layout

```
book.adoc                  ← entry; sets attrs, includes front/body/back
metadata.yaml              ← title, author, rights, date
source/
  front_matter.adoc        ← includes colophon, dedication, preface
  body.adoc                ← includes chapter1..chapter5
  back_matter.adoc         ← includes about, index
  chapter*.adoc            ← put new chapter content here
figures/                   ← images referenced by `image::`
backgrounds/               ← cover.png, back-cover.png
output/                    ← build artifacts (gitignored)
.github/workflows/         ← CI (vale + word count) and CD (PDF/EPUB)
.devcontainer/             ← VSCode container config
.vale.ini                  ← linter config
```

## Authoring conventions

| Feature | Syntax |
|---------|--------|
| Index term (inline) | `((term))` |
| Math equation | `[stem]\n++++\n<latex>\n++++` |
| PlantUML diagram | `[plantuml, <id>, png, ...]\n----\n@startuml ... @enduml\n----` |
| Mermaid diagram | `[mermaid, <id>, png, ...]\n----\n<mermaid>\n----` |
| Code block | `[source,<lang>]\n----\n<code>\n----` (Rouge highlighter) |
| Admonition | `[NOTE]` / `[TIP]` / `[IMPORTANT]` |
| Sidebar | `[sidebar]` |
| Quote | `[quote, <author>, <source>]` |
| Image | `image::file.jpg[Alt, width=500, align=center]` |

## Toolchain requirements

- **Ruby ≥ 3.0 AND < 4.0** (4.0 removed stdlib gems asciidoctor-pdf depends on)
- Gems (pinned in `Gemfile`): `asciidoctor`, `asciidoctor-pdf`, `asciidoctor-epub3`, `asciidoctor-diagram`, `asciidoctor-mathematical`, `rouge`
- System: `plantuml` (Java), `mermaid-cli` + headless Chrome, `cmake`, `bison`, `flex`, `cairo`, `pango`, `glib`, `gdk-pixbuf`
- Env: `DIAGRAM_PLANTUML_CLASSPATH=<path-to-plantuml.jar>` (Makefile auto-detects on macOS Homebrew)

### macOS quick path

```bash
make setup-macos
export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:$PATH"
make output/book.pdf
```

### Linux / CI path

Use the `asciidoctor/docker-asciidoctor` image — the GitHub Actions workflows do this. All deps preinstalled.

## Common build failures → fixes

| Error | Fix |
|-------|-----|
| `cannot load such file -- bigdecimal` (or `ostruct`, `csv`, ...) | Using Ruby 4.0; switch to 3.x |
| `'asciidoctor-mathematical' could not be loaded` | Native build of `mathematical 1.6.20` failed; reinstall with `CMAKE_POLICY_VERSION_MINIMUM=3.5` |
| `Could not load PlantUML` | Set `DIAGRAM_PLANTUML_CLASSPATH=<path-to-plantuml.jar>` |
| `mmdc failed: Could not find Chrome (ver. X.Y.Z)` | Run mermaid-cli's bundled puppeteer install: `node node_modules/puppeteer/install.mjs` from the mermaid-cli libexec dir (not `npx`, which fetches wrong version) |

## Testing your changes

After editing `.adoc` files:

```bash
make output/book.pdf
```

Expected: PDF written, no `ERROR:` lines on stderr. Successful build is ~28MB.

## Conventions for agents

- **Don't break** the include chain in `book.adoc` → `front_matter.adoc` / `body.adoc` / `back_matter.adoc`.
- **Don't add timestamps** in content; the build is reproducible (`:reproducible:` attr).
- **Vale lint runs in CI** on `source/` — avoid passive voice and weasel words flagged by Google/proselint/write-good styles.
- **Don't commit** `output/` or any generated PDFs/EPUBs.
- **New chapter:** add `source/chapterN.adoc`, then add `include::chapterN.adoc[]` in `source/body.adoc`.
- **New figure:** drop image into `figures/`, reference with `image::filename.ext[...]` (no path prefix — `:imagesdir: figures` in `book.adoc`).
