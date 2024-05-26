{
  description = "Varnam on Nix";

  nixConfig = {
    extra-substituters = [
      "https://varnam-nix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "varnam-nix.cachix.org-1:IduaZzaMOJmY32L11e+a4fDDq6Xnq9/NcocAPcIbX9Y="
    ];
  };

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

        packages = rec {
          libgovarnam = pkgs.callPackage ./govarnam/libgovarnam.nix { };
          varnam-cli = pkgs.callPackage ./govarnam { inherit libgovarnam; };
          fcitx5-varnam = pkgs.callPackage ./varnam-fcitx5 { inherit libgovarnam; };
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            go_1_22
            gopls
            gnumake
            meson
            ninja
            cmake
            pkg-config
            ruby
            rubyPackages.ffi
            python3
          ]) ++ (with packages; [ libgovarnam varnam-cli ]);
        };
        packages = {
          inherit (packages) libgovarnam varnam-cli fcitx5-varnam;
          default = packages.varnam-cli;
        };
        overlays.default = final: prev: {
          inherit (packages) libgovarnam varnam-cli fcitx5-varnam;
        };
      }
    );
}
