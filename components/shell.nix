{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  easyPS = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "ee8d4545c3eb14ea75b789dbfb84e4e8573941b5";
    sha256 = "16bcllaf2ra0cbgkc5vlirkh2kkf16237xp4wng6314m3fsxmmag";
  }) { inherit pkgs; };
in stdenv.mkDerivation {
  name = "env";
  buildInputs = with easyPS; [ purs spago ];
}
