{ aquaris, pkgs, ... }: {
  imports = [ ../../profiles/common ];

  aquaris = {
    users = pkgs.lib.mkMerge [
      { inherit (aquaris.cfg.users) ercanar; }
      { ercanar.admin = true; }
    ];

    machine = {
      id = "b208c4d88d4977648e55f78569c14ccd";
      secureboot = false;
    };

    secrets.pub = "zEcOcgtuF8h8wEw3a3ubXRyB0_2DUpPn7MAUTDDRJzs";

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/nvme-eui.00000000000000000026b73844efec35".partitions = [
        fs.defaultBoot
        { content = fs.zpool (p: p.rpool); }
      ];
    };
  };

  nix.gc.dates = "05:00";

  rice = {
    ca.enable = true;
    dns.enable = true;
    nixremote.use = true;
    pam-rssh.enable = true;
    tailscale.enable = true;
  };

  environment.systemPackages = with pkgs; [
    (runCommand "javas" { } ''
      mkdir -p $out/bin
      ln -s ${temurin-bin-25}/bin/java $out/bin/java25
      ln -s ${temurin-bin-21}/bin/java $out/bin/java21
      ln -s ${temurin-bin-17}/bin/java $out/bin/java17
      ln -s ${temurin-bin-8}/bin/java $out/bin/java8
    '')
  ];

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 24454 ];
  };
}
