{
  description = "Varnam on Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go_1_22
            gnumake
            meson
            ninja
            cmake
            pkg-config
          ];
        };
        packages = rec {
          libgovarnam = pkgs.callPackage ./govarnam/default.nix { };
          varnam-cli = pkgs.callPackage ./govarnam/default.nix { cli = true; };
          fcitx5-varnam = pkgs.callPackage ./varnam-fcitx5 { inherit libgovarnam; };
        };
      }
    );
}
