{ config, lib, pkgs, utils, ... }:
let
  libraries = "/media/libraries";
  unit = "${utils.escapeSystemdPath libraries}.mount";

  uid = pkgs.writeText "uidfile" ''
    grimmory:1000
  '';

  gid = pkgs.writeText "gidfile" ''
    grimmory:100
  '';
in
{
  topology.nodes.bunny-private.services.grimmory = {
    name = "Grimmory";
    icon = "services.grimmory";
    info = "Personal library management";
    details.url.text = "https://books.bunny";
  };

  environment.systemPackages = with pkgs; [
    sshfs
  ];

  programs.ssh.knownHosts = {
    "laniakea.bunny.vpn".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWEWvH3KtMh7YStERmV+UWRL7xMV0mNlz2RYXmMKh3k";
  };

  virtualisation.pnoc.grimmory = {
    path = with pkgs; [
      grimmory
      temurin-jre-bin-25
    ];

    script = ''
      exec grimmory /data
    '';

    environment = {
      BOOKLORE_PORT = "8080";

      DATABASE_URL = "jdbc:mariadb://mariadb:3306/grimmory";
      DATABASE_USERNAME = "grimmory";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/grimmory") ];

    volumes = [
      "grimmory:/data"
      "${libraries}:/libraries"
    ];
  };

  systemd = {
    services.podman-grimmory = {
      after = [ unit ];
      requires = [ unit ];
    };

    mounts = [{
      name = unit;
      what = "admin@laniakea.bunny.vpn:/persist/home/admin/libraries";
      where = libraries;
      type = "fuse.sshfs";
      options = lib.join "," [
        "_netdev"
        "nosuid"
        "rw"
        "allow_other"
        "default_permissions"
        "idmap=file"
        "uidfile=${uid}"
        "gidfile=${gid}"
        "identityfile=${config.aquaris.secret "@machine/ssh/laniakea"}"
      ];

      after = [ "tailscaled.service" ];
      requires = [ "tailscaled.service" ];
    }];
  };
}
