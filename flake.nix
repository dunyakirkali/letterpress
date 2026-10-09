{
  description = "letterpress: write books in AsciiDoc and build PDF and EPUB";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs:
        let
          # Gems are pinned in nix/Gemfile.lock; regenerate nix/gemset.nix with
          # `nix run nixpkgs#bundix` from nix/ after changing the Gemfile.
          gems = pkgs.bundlerEnv {
            name = "letterpress-gems";
            ruby = pkgs.ruby;
            gemdir = ./nix;
            gemConfig = pkgs.defaultGemConfig // {
              mathematical = attrs: {
                nativeBuildInputs = with pkgs; [ cmake bison flex pkg-config python3 ];
                buildInputs = with pkgs; [ cairo pango glib gdk-pixbuf libxml2 ];
                dontUseCmakeConfigure = true;
                # The vendored mtex2MML predates CMake 4.
                env = (attrs.env or { }) // {
                  CMAKE_POLICY_VERSION_MINIMUM = "3.5";
                  NIX_CFLAGS_COMPILE = "${attrs.env.NIX_CFLAGS_COMPILE or ""} -I${pkgs.libxml2.dev}/include/libxml2";
                };
              };
            };
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gnumake
              gems
              graphviz
              mermaid-cli
              epubcheck
              vale
              jre_headless # PlantUML
            ] ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.chromium;

            # mermaid-cli drives a headless Chrome; nixpkgs only ships one for
            # Linux, so on macOS use the installed Google Chrome.
            shellHook = if pkgs.stdenv.hostPlatform.isLinux then ''
              export PUPPETEER_EXECUTABLE_PATH=${pkgs.chromium}/bin/chromium
            '' else ''
              export PUPPETEER_EXECUTABLE_PATH="''${PUPPETEER_EXECUTABLE_PATH:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
            '';
          };
        });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}
