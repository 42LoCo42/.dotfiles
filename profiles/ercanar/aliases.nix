{
  home-manager.sharedModules = [{
    home.shellAliases = {
      a = "vi $NIXOS_CONFIG_DIR/profiles/ercanar/aliases.nix && switch";
      bim = "vi";
      pi = "ssh pi";
      scam = "scanimage -d 'airscan:e0:Brother DCP-L2530DW series' -o";
    };
  }];
}
