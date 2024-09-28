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
