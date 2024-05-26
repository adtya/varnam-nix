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

        packages = rec {
          libgovarnam = pkgs.callPackage ./govarnam/libgovarnam.nix { };
          varnam-cli = pkgs.callPackage ./govarnam { inherit libgovarnam; selected_schemes = [ "ml" ]; };
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
        };
      }
    );
}
