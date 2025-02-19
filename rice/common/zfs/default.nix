{ pkgs, lib, config, ... }: lib.mkIf config.boot.zfs.enabled {
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "zfsnaps";
      text = builtins.readFile ./zfsnaps.sh;
    })
  ];
}
