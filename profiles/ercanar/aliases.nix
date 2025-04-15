{ ... }: {
  home-manager.sharedModules = [{
    home.shellAliases = {
      a = "vi $NIXOS_CONFIG_DIR/profiles/ercanar/aliases.nix && switch";
      bim = "vi";
      pi = "ssh pi";
    };
  }];
}
