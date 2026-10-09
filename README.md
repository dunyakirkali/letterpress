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

- [Nix](https://nixos.org/) (flakes) for reproducible builds and dev environments
- [GNU Make](https://www.gnu.org/software/make/)
- [Asciidoctor](https://asciidoctor.org/)

## Batteries included

Everything you need to get started is included in the package

- Nix flake: Reproducible toolchain for local dev and CI/CD
- Devcontainers: Allows you to build your book locally
- GitHub Workflows: Allows you to build your book on GitHub CI

## Bring your own

- Content
- Images
- Cover images: `backgrounds/cover.png` and `backgrounds/back-cover.png` (referenced from [book.adoc](book.adoc); the build works without them, but the book has no cover)

## Development environment

Letterpress ships a [Nix flake](flake.nix) that pins the entire toolchain
(Asciidoctor, asciidoctor-pdf/epub3/diagram/mathematical, PlantUML, Mermaid,
Graphviz, a JRE, Vale and EPUBCheck). This is the same environment used in CI, so builds
are reproducible everywhere.

### Enter the dev shell

```bash
nix develop
```

This drops you into a shell with every tool on `PATH`, so all the `make`
commands below just work. If you use [direnv](https://direnv.net/), run
`direnv allow` once and the environment loads automatically.

### Build the book with Nix

You can build the book directly, without entering a shell, and get a `result`
symlink containing `book.pdf` and `book.epub`:

```bash
nix build            # builds both PDF and EPUB into ./result
ls result/
```

Under the hood this runs the same `make` targets described below inside the
pinned environment.

## Commands

The `make` commands below assume the toolchain is available. The easiest way to
get it is the Nix dev shell (`nix develop`); alternatively install the tools
yourself.

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

### Update gems

Gems are pinned in `Gemfile.lock`, and the Nix build reads them from `gemset.nix`. After changing `Gemfile` or `Gemfile.lock` (including Dependabot bumps), regenerate it inside the dev shell and commit the result:

```bash
make gemset
```

CI fails if `gemset.nix` doesn't match `Gemfile.lock`.

### Count

```bash
make count
```

### Validate EPUB

Letterpress can validate the generated EPUB with [EPUBCheck](https://www.w3.org/publishing/epubcheck/). EPUBCheck is provided by the Nix dev shell (or install it yourself), then run:

```bash
make epubcheck
```

This builds the EPUB (if needed) and then validates it.

### Clean

In order to remove the generated files you can run:

```bash
make clean
```

### Linting

Letterpress comes with [vale](https://vale.sh/). Vale is provided by the Nix dev shell (or install it yourself), then run:

```bash
make lint
```

The style rules (Google, proselint, write-good, Readability) are committed under `.github/styles`, so no `vale sync` is needed. Only errors fail the lint. To see the softer warnings and suggestions, run `vale --minAlertLevel=warning source/`.

## Structure

The entry point of the book is [book.adoc](book.adoc).

The [book.adoc](book.adoc) consists of 3 sections:

- The [front matter](source/front_matter.adoc)
- The [body](source/body.adoc)
- The [back matter](source/back_matter.adoc)

The [body](source/body.adoc) is where you should place the main content of your book.
