{ aquaris, ... }: {
  imports = aquaris.lib.importTree ./. [ "/default.nix" ];
}
