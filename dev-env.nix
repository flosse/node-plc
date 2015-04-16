let
  pkgs    = import <nixpkgs> {};
  stdenv  = pkgs.stdenv;
  lib     = pkgs.lib;

  nodePackages = pkgs.nodePackages.override {
    self = nodePackages;
    generated = ./node-packages.nix;
  };

in rec {
  devEnv = stdenv.mkDerivation rec {
    name = "dev-env";
    src = ./.;
    buildInputs = with nodePackages; [
      pkgs.utillinux
      pkgs.python
      stdenv
      pkgs.nodejs
      nan
      bindings
      bits
      chai
      mocha
      node-gyp
      coffee-script
    ];
  };
}
