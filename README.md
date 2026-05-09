# letterpress

![CI](https://github.com/dunyakirkali/letterpress/actions/workflows/continuous_integration.yaml/badge.svg)
![CD](https://github.com/dunyakirkali/letterpress/actions/workflows/continuous_delivery.yaml/badge.svg)

Gutenberg the 💩 out of it!

<img src="figures/gutenberg.jpg" width=530>

Letterpress is a project aimed at simplifying the self-publishing process for books. It provides a ready-to-use template based on AsciiDoctor, catering to authors who need robust support for diagramming, coding examples, and mathematical formulas.

## Contributing

Contributions to Letterpress are welcome! If you have suggestions, improvements, or bug fixes, please fork the repository and submit a pull request.

## Tools

This Project makes use of the following tools:

- [GNU Make](https://www.gnu.org/software/make/)
- [Asciidoctor](https://asciidoctor.org/)

## Batteries included

Everything you need to get started is included in the package

- Devcontainers: Allows you to build your book locally
- GitHub Workflows: Allows you to build your book on GitHub CI

## Local build on macOS

> ⚠️ The instructions below are **macOS-only** (tested on Apple Silicon, Sequoia 15.x). Linux/Windows users should use the devcontainer or the `asciidoctor/docker-asciidoctor` image directly.

### One-shot setup

```bash
make setup-macos
```

Installs Ruby 3.3, the required gems (via `bundle install` from the included `Gemfile`), and system dependencies (PlantUML, Mermaid + headless Chrome, cairo/pango/cmake/bison/flex).

### Building

```bash
export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:/opt/homebrew/opt/ruby@3.3/bin:$PATH"
make output/book.pdf
```

### Gotchas

- **Don't use brew's default `ruby` formula (4.x).** asciidoctor-pdf 2.3.x depends on stdlib gems (`bigdecimal`, `ostruct`, ...) removed in Ruby 4.0. Use `ruby@3.3`.
- **RVM users:** RVM hijacks `gem` and `ruby` via shell functions / env vars. Always invoke commands with `env -u GEM_HOME -u GEM_PATH -u RUBY_VERSION -u rvm_path` to bypass.
- **CMake 4.x + `mathematical` 1.6.20:** Native build fails because the bundled `mtex2MML/CMakeLists.txt` requires CMake < 3.5 syntax. The `setup-macos` target sets `CMAKE_POLICY_VERSION_MINIMUM=3.5` to work around this.
- **Mermaid Chrome version pinning:** `npx puppeteer browsers install` fetches the *latest* Chrome — but `mermaid-cli` pins a specific version. Use mermaid-cli's bundled puppeteer (`node_modules/puppeteer/install.mjs`); the `setup-macos` target does this.

## Bring your own

- Content
- Images

## Commands

### Generate

In order to generate the PDF and the EPUB versions of the book you can just run:

```bash
make
```

If you just need to generate the PDF:

```bash
make output/book.pdf
```

If you just need to generate the EPUB:

```bash
make output/book.epub
```

### Count

```bash
make count
```

### Clean

In order to remove the generated files you can run:

```bash
make clean
```

### Linting

letterpress comes with [vale](https://vale.sh/). Once you've installed vale on your machine you can run it with:

```bash
make lint
```

## Structure

The entry point of the book is [book.adoc](book.adoc).

The [book.adoc](book.adoc) consists of 3 sections:

- The [front matter](source/front_matter.adoc)
- The [body](source/body.adoc)
- The [back matter](source/back_matter.adoc)

The [body](source/body.adoc) is where should be placing the main content of your book.
