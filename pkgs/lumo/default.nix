{ stdenv, fetchzip }:

let
  rpath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc.lib ];
in
  stdenv.mkDerivation {
    name = "lumo-1.6.0";

    src = fetchzip {
      url = "https://github.com/anmonteiro/lumo/releases/download/1.6.0/lumo_linux64.zip";
      sha256 = "048iwi9gyzhw9870qimrgvv12rwagvwvjyqhhfflw72sn1amyj1y";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp lumo $out/bin
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/lumo
      #patchelf --set-rpath "${rpath}" $out/bin/lumo
    '';
  }
