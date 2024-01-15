{ stdenv, lib, jq, nix, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "packerix";
  version = "2.7.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/{bin,core,modules,lib}
    mv bin core modules lib share $out/

    wrapProgram $out/bin/packerix-doc-json \
      --prefix PATH : ${lib.makeBinPath [ jq nix ]}
  '';

  meta = with lib; {
    description = "A NixOS like terraform-json generator";
    homepage = "https://packerix.org";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}
