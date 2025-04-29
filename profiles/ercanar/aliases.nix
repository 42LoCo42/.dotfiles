{ ... }: {
  home-manager.sharedModules = [{
    home.shellAliases = {
      a = "vi $NIXOS_CONFIG_DIR/profiles/ercanar/aliases.nix && switch";
      bim = "vi";
      pi = "ssh pi";
      scam = "scanimage -d 'escl:http://192.168.178.24:80' -o";
    };
  }];
}
