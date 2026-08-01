{
  description = "Roc development environment";

  inputs = {
    # The standard package collection.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Pinned prebuilt roc nightly. Regenerate with ./update-roc.sh.
      pin = builtins.fromJSON (builtins.readFile ./roc-pin.json);

      # Prebuilt roc nightly from github:roc-lang/nightlies. The binary is
      # statically linked, so no interpreter patching is needed; we only wrap it
      # so roc can find a C compiler/linker at runtime.
      roc = pkgs.stdenv.mkDerivation {
        pname = "roc";
        version = pin.version;
        src = pkgs.fetchurl {
          url = pin.url;
          hash = pin.sha256;
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        dontConfigure = true;
        dontBuild = true;
        dontStrip = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp roc $out/bin/roc
          wrapProgram $out/bin/roc \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.stdenv.cc ]}
          runHook postInstall
        '';
      };
    in
    {
      # `nix develop` drops you into this shell.
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          roc # latest roc nightly (see roc-pin.json)
        ];
      };
    };
}
