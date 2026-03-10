{
  imports = [
    ./chrony.nix
    ./fastfetch.nix
    ./go-telemetry.nix
    ./nix-locate.nix
    ./nix.nix
    ./patches.nix
    ./pnoc-v2
    ./procfs.nix
    ./speechd.nix
    ./topology
    ./zsh
  ];

  # TODO upstream to aquaris (i lazy lul)
  home-manager.sharedModules = [{
    home.shellAliases = {
      "zfclean" = "zfs list -t snapshot -H -o name | grep -v frequent | sudo xargs -I% zfs destroy -v %";
    };
  }];
}
