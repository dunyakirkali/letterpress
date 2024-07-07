# letterpress

Gutenberg the 💩 out of it!

<img src="figures/gutenberg.jpg" width=530>

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
make output/your_book_slug.pdf
```

If you just need to generate the EPUB:

```bash
make output/your_book_slug.epub
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
