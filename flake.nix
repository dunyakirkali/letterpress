{
  description = "letterpress - a self-publishing book template built on Asciidoctor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Ruby gem environment pinned by Gemfile.lock + gemset.nix.
        # The native `mathematical` gem (pulled in by asciidoctor-mathematical)
        # needs a bunch of C libraries + bison/flex to build its bundled lasem.
        gems = pkgs.bundlerEnv {
          name = "letterpress-gems";
          ruby = pkgs.ruby_3_4;
          gemdir = ./.;
          # nixpkgs' defaultGemConfig already knows how to build the tricky
          # native `mathematical` gem (bison/flex/cmake + rpath fixups). We only
          # extend it: the gem vendors an mtex2MML whose CMakeLists declares an
          # ancient cmake_minimum_required that modern cmake rejects, so allow it.
          gemConfig = pkgs.defaultGemConfig // {
            mathematical = attrs:
              (pkgs.defaultGemConfig.mathematical attrs) // {
                CMAKE_POLICY_VERSION_MINIMUM = "3.5";
              };
          };
        };

        # Everything needed to render the book: the gem env plus the external
        # binaries asciidoctor-diagram shells out to.
        runtimeInputs = with pkgs; [
          gems
          gems.wrappedRuby
          gnumake
          plantuml
          mermaid-cli
          graphviz
          jre
          vale
          epubcheck
        ];

        # Nixpkgs' mermaid-cli only bundles Chromium on Linux.
        mermaidBrowserExecutable = pkgs.lib.optionalString (system == "aarch64-darwin")
          "${pkgs.playwright-driver.components.chromium-headless-shell}/chrome-headless-shell-mac-arm64/chrome-headless-shell";
        # Chromium's sandbox cannot nest inside the Nix build sandbox.
        mermaidPuppeteerConfig = pkgs.writeText "puppeteer.json" ''
          { "args": ["--no-sandbox"] }
        '';

        book = pkgs.stdenv.mkDerivation {
          pname = "letterpress-book";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = runtimeInputs;
          DIAGRAM_PLANTUML_CLASSPATH = "${pkgs.plantuml}/lib/plantuml.jar";
          PUPPETEER_EXECUTABLE_PATH = mermaidBrowserExecutable;
          # asciidoctor-diagram caches into $HOME
          buildPhase = ''
            export HOME=$TMPDIR
            make all ASCIIDOC_FLAGS="--doctype book --failure-level ERROR -a mermaid-puppeteer-config=${mermaidPuppeteerConfig}"
          '';
          installPhase = ''
            mkdir -p $out
            cp -r output/* $out/
          '';
        };
      in
      {
        packages = {
          default = book;
          book = book;
          gems = gems;
        };

        devShells.default = pkgs.mkShell {
          packages = runtimeInputs ++ (with pkgs; [ bundix ]);
          DIAGRAM_PLANTUML_CLASSPATH = "${pkgs.plantuml}/lib/plantuml.jar";
          PUPPETEER_EXECUTABLE_PATH = mermaidBrowserExecutable;
          shellHook = ''
            echo "letterpress dev shell"
            echo "  make            build PDF + EPUB"
            echo "  make output/book.pdf"
            echo "  make output/book.epub"
            echo "  make lint       run vale"
            echo "  make epubcheck  validate EPUB"
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
