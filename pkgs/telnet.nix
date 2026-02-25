{ pkgs, lib, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "telnet";
  version = pkgs.inetutils.version;

  dontUnpack = true;

  postBuild = ''
    mkdir -p $out/bin
    ln -sf "${pkgs.inetutils}/bin/telnet" $out/bin/telnet
  '';

  meta = with lib; {
    description = "telnet from inetutils as a standalone derivation";
    platforms = pkgs.inetutils.meta.platforms;
  };
}
