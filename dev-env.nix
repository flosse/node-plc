let
  pkgs    = import <nixpkgs> {};
  stdenv  = pkgs.stdenv;
  lib     = pkgs.lib;

  nodePackages = import "${pkgs.path}/pkgs/top-level/node-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv nodejs fetchurl fetchgit;
    neededNatives = [
        pkgs.which
        pkgs.python
        pkgs.pkgconfig
      ] ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.utillinux;
    self = nodePackages;
    generated = ./node-packages.nix;
  };

in rec {
  devEnv = stdenv.mkDerivation rec {
    name = "dev-env";
    version = "0.1";
    src = ./.;
    buildInputs = [
      pkgs.utillinux
      pkgs.python
      stdenv
      pkgs.nodejs
      nodePackages.nan
      nodePackages.bindings
      nodePackages.bits
      nodePackages.chai
      nodePackages.mocha
      nodePackages.node-gyp
      nodePackages.coffee-script
    ];
  };
}
