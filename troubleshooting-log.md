# Troubleshooting Log

## Environment

- **OS:** macOS Sequoia 15.7.3 (Darwin 24.6.0)
- **Arch:** arm64 (Apple Silicon)
- **Shell:** zsh
- **Package manager:** Homebrew
- **Pre-existing:** RVM installed with Ruby 2.7.0 (interferes with brew Ruby — see Issue 4)

## 2026-05-09 — Getting `make output/book.pdf` to work

### Step 1: Install asciidoctor via Homebrew
```bash
brew install asciidoctor
```
Pulled in `ruby 4.0.3` as dependency.

### Issue 1: Ruby 4.0 removed stdlib gems (bigdecimal, ostruct, ...)
- **Error:** `cannot load such file -- bigdecimal (LoadError)` then `cannot load such file -- ostruct (LoadError)`
- **Cause:** Ruby 4.0 removed multiple gems from stdlib; asciidoctor-pdf 2.3.15 doesn't declare them as deps.
- **Fix:** Install missing gems explicitly (whack-a-mole — eventually abandoned for Ruby 3.3 approach).

### Issue 2: rbenv install Ruby 3.3.6 FAILED
- **Tried:** `brew install rbenv && rbenv install 3.3.6`
- **Error:** `OpenSSL library could not be found` during source compile
- **Lesson:** Don't use rbenv (compiles from source). Use `brew install ruby@3.3` (precompiled bottle).

### Issue 3: RVM hijacks `gem` and `ruby`
- **Symptom:** `which gem` returns shell function, `which ruby` returns `/Users/alexey/.rvm/rubies/ruby-2.7.0/bin/ruby`. Even calling `/opt/homebrew/opt/ruby/bin/gem` reads RVM's `GEM_HOME` and installs into `~/.rvm/gems/ruby-2.7.0/`.
- **Fix:** Always invoke gem/asciidoctor with clean env:
  ```bash
  env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
    PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
    <command>
  ```

### Step 2: Install Ruby 3.3 brew bottle
```bash
brew install ruby@3.3   # → 3.3.11 installed
```

### Issue 4: `mathematical 1.6.20` native build fails (cmake 4.x incompat)
- **Error:** `cp_r ... mathematical/mtex2MML/build/libmtex2MML.a (Errno::ENOENT)` — silent cmake failure upstream.
- **Root cause:** cmake 4.x dropped `cmake_minimum_required(VERSION 2.x)` support. Manual run shows:
  ```
  CMake Error: Compatibility with CMake < 3.5 has been removed from CMake.
  ```
- **Fix:** Set env var before gem install:
  ```bash
  env ... CMAKE_POLICY_VERSION_MINIMUM=3.5 gem install mathematical -v 1.6.20
  ```
- **C deps required (brew install):** `cmake bison flex cairo pango glib gdk-pixbuf`

### Step 3: Install all asciidoctor gems
```bash
env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
  CMAKE_POLICY_VERSION_MINIMUM=3.5 \
  PATH="/opt/homebrew/opt/flex/bin:/opt/homebrew/opt/bison/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
  /opt/homebrew/opt/ruby@3.3/bin/gem install \
    asciidoctor asciidoctor-pdf asciidoctor-diagram asciidoctor-mathematical rouge
```

### Issue 5: PlantUML diagrams fail
- **Error:** `Could not load PlantUML. Either require 'asciidoctor-diagram-plantuml' or specify the location of the PlantUML JAR(s) using the 'DIAGRAM_PLANTUML_CLASSPATH' environment variable.`
- **Fix:**
  ```bash
  brew install plantuml
  export DIAGRAM_PLANTUML_CLASSPATH=/opt/homebrew/opt/plantuml/libexec/plantuml.jar
  ```

### Issue 6: Mermaid diagrams fail (Chrome missing)
- **Error:** `mmdc failed: Could not find Chrome (ver. 147.0.7727.57)`
- **Cause:** brew `mermaid-cli` ships Puppeteer but not bundled Chrome.
- **Gotcha:** `npx puppeteer browsers install` uses LATEST puppeteer (24.43) which downloads Chrome 148/145, not the 147.0.7727.57 mermaid-cli's bundled puppeteer wants. Must use mermaid-cli's own puppeteer.
- **Fix:**
  ```bash
  cd /opt/homebrew/Cellar/mermaid-cli/11.14.0/libexec/lib/node_modules/@mermaid-js/mermaid-cli
  node node_modules/puppeteer/install.mjs
  ```

### Step 4: Final build invocation (working)
```bash
brew install plantuml mermaid-cli  # plus chrome via puppeteer

env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path \
  DIAGRAM_PLANTUML_CLASSPATH=/opt/homebrew/opt/plantuml/libexec/plantuml.jar \
  PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:/opt/homebrew/bin:/usr/bin:/bin" \
  make output/book.pdf
```

**Result:** `output/book.pdf` (~28MB) generated successfully — zero errors, zero warnings.

## Working state ✅
- PDF builds with math (chapters 4-5) ✓
- PDF builds with PlantUML diagrams ✓
- PDF builds with Mermaid diagrams ✓
- EPUB builds (27M) ✓ — needed extra `gem install asciidoctor-epub3`

## Wrappers
- `./make-pdf.sh [out]` — sets env, runs `make <out>`. Default `output/book.pdf`.
- `./make-epub.sh [out]` — same for EPUB. Default `output/book.epub`.

## 2026-05-09 — Custom PDF theme and EPUB stylesheet

### Issue 7: Noto Sans not found in PDF theme
- **Error:** `Noto Sans (bold) is not a known font family`
- **Cause:** `themes/letterpress-theme.yml` referenced `Noto Sans` without registering it in the font catalog.
- **Fix:** Add `font.catalog` with `merge: true` and register Noto Sans from `GEM_FONTS_DIR`:
  ```yaml
  font:
    catalog:
      merge: true
      Noto Sans:
        normal: GEM_FONTS_DIR/notosans-regular-subset.ttf
        bold: GEM_FONTS_DIR/notosans-bold-subset.ttf
        italic: GEM_FONTS_DIR/notosans-italic-subset.ttf
        bold_italic: GEM_FONTS_DIR/notosans-bold_italic-subset.ttf
  ```
  `GEM_FONTS_DIR` resolves to the fonts bundled with the asciidoctor-pdf gem; `merge: true` keeps default fonts available.

### Issue 8: EPUB looked for epub3.css, not epub3.scss
- **Cause:** asciidoctor-epub3 expects `epub3.css` (plain CSS) in the stylesdir, not `.scss`.
- **Fix:** Rename `epub-styles/epub3.scss` → `epub-styles/epub3.css`. Also requires `epub-styles/epub3-css3-only.css` (can be empty).

### Issue 9: epub3-css3-only.css missing
- **Error:** EPUB build warning about missing `epub3-css3-only.css`.
- **Fix:** Create empty `epub-styles/epub3-css3-only.css`.

## Upstream PR
Submitted: https://github.com/dunyakirkali/letterpress/pull/7
Branch: `feat/macos-local-dev` on fork `krivitsky/letterpress`.
Contains: Makefile setup-macos target + auto-classpath, Gemfile pins, README local-macOS section, AGENTS.md, CI dead-step removal.
