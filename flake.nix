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
  };

  outputs = { nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };

      packages = pkgs: rec {
        libgovarnam = pkgs.callPackage ./govarnam/libgovarnam.nix { };
        varnam-cli = pkgs.callPackage ./govarnam { inherit libgovarnam; };
        fcitx5-varnam = pkgs.callPackage ./varnam-fcitx5 { inherit libgovarnam; };
      };
    in
    {
      formatter.x86_64-linux = pkgs.nixpkgs-fmt;
      devShells.x86_64-linux.default = pkgs.mkShell {
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
        ]) ++ (with (packages pkgs); [ libgovarnam varnam-cli ]);
      };
      packages.x86_64-linux = rec {
        inherit (packages pkgs) libgovarnam varnam-cli fcitx5-varnam;
        default = varnam-cli;
      };
      overlays.default = final: prev: {
        inherit (packages prev) libgovarnam varnam-cli fcitx5-varnam;
      };
    };
}
