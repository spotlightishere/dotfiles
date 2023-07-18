{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "monaco-powerline";
  version = "1.0";

  # This font is located in the same directory.
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${./monaco-for-powerline.otf} -t $out/share/fonts/opentype

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Monaco font, but patched to include powerline symbols";
    platforms = platforms.all;
  };
}
