{ stdenv, lib, go, fetchgit, git }:

stdenv.mkDerivation rec {
  version = "2017-04-05";
  name = "camlistore-${version}";

  src = fetchgit {
    url = "https://github.com/camlistore/camlistore";
    rev = "9e34d14ef5f240f35bd88d71495da0f6cbf99600";
    sha256 = "0nhjg0nkdnifzii8gjlx8vi6kn7f9v6xcnd2zw5aghxnpj8nz9r6";
    leaveDotGit = true;
  };

  buildInputs = [ go git ];

  buildPhase = ''
    go run make.go
    rm bin/README
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/* $out/bin
  '';

  meta = with stdenv.lib; {
    description = "A way of storing, syncing, sharing, modelling and backing up content";
    homepage = https://camlistore.org;
    license = licenses.asl20;
    maintainers = with maintainers; [ cstrahan ];
    platforms = platforms.unix;
  };
}
