{ pkgs, aquaris, ... }: {
  imports = [ ../../rice ];

  aquaris = {
    users = pkgs.lib.mkMerge [
      { inherit (aquaris.cfg.users) admin; }
      { admin.admin = true; }
    ];

    filesystems = { fs, ... }: {
      zpools.rpool = fs.defaultPool;
    };

    persist.enable = true;
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:42loco42/.dotfiles";
    flags = [ "--refresh" "-L" ];
  };

  nix.gc.automatic = true;

  virtualisation.podman.defaultNetwork.settings = {
    ipv6_enabled = true;
    subnets = [
      {
        subnet = "10.88.0.0/16";
        gateway = "10.88.0.1";
      }
      {
        subnet = "fd00::/80";
        gateway = "fd00::1";
      }
    ];
  };

  rice.pam-rssh.enable = true;
}
