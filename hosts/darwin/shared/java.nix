{ pkgs, ... }: {
  # Install the latest JDK, and latest LTS JDK.
  # Per https://github.com/LnL7/nix-darwin/issues/663,
  # nix-darwin only supports a few specific named activation scripts.
  # We'll leverage `extraActivation` to symlink our JDKs.
  # TODO(spotlightishere): Migrate to explicit scripts when possible
  system.activationScripts.extraActivation.text = ''
    ##############
    # Latest JDK #
    ##############
    # Regardless of version, we'd like the latest JDK available.

    # Remove the symlink if it doesn't already exist.
    rm -f /Library/Java/JavaVirtualMachines/zulu-latest.jdk

    # We should only have a single JDK present within our package,
    # but let's limit `find` regardless.
    JDK_LOCATION="$(find "${pkgs.jdk24}" -name "*.jdk" | head -n1)"

    # Symlink!
    ln -sf "$JDK_LOCATION" "/Library/Java/JavaVirtualMachines/zulu-latest.jdk"

    ##########
    # JDK 21 #
    ##########
    # We'd also like the latest LTS version of the JDK available.
    rm -f /Library/Java/JavaVirtualMachines/zulu-21.jdk
    ln -sf "${pkgs.jdk21}/zulu-21.jdk" "/Library/Java/JavaVirtualMachines/zulu-21.jdk"
  '';
}
