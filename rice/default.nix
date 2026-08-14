{ aquaris, ... }: {
  imports = aquaris.lib.importTree ./. [
    "/default.nix"
    "/common/patches/gruvbox-gtk-theme.nix"
  ];
}
