{
  description = "Roc development environment";

  inputs = {
    # The standard package collection.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # The overlay that provides prebuilt roc nightlies.
    roc.url = "github:thebrandonlucas/roc-overlay";
  };

  outputs =
    { nixpkgs, roc, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # `nix develop` drops you into this shell.
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          roc.packages.${system}.default # latest roc nightly
        ];
      };
    };
}
