{ self, lib, config, aquaris, ... }:
let
  inherit (aquaris.lib) merge;
  inherit (lib) mkForce;
in
{
  imports = [
    ../../rice
    self.inputs.nixos-router.nixosModules.default
  ];

  aquaris = {
    machine = {
      id = "5965b9540d6ce5bb06e850ad671c840a";
      key = "age1592y83f2sd2n4y5cxq7zd68mwtx70kyrfq435ue6re3mnpwve30qn7e5xr";
    };

    users = merge [
      { inherit (aquaris.cfg.users) admin; }
      { admin.admin = true; }
    ];

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/TODO".partitions = [
        fs.defaultBoot
        { content = fs.zpool (p: p.rpool); }
      ];

      zpools.rpool = fs.defaultPool;
    };

    persist.enable = true;
  };

  rice.tailscale = true;

  networking.networkmanager.enable = mkForce false;

  services.router = {
    enable = true;

    lanIF = "TODO_lan";
    wanIF = "TODO_wan";

    wlan = {
      ssid = "Ratatoskr";
      passwordFile = config.aquaris.secrets."machine/sae-password";
    };
  };
}
