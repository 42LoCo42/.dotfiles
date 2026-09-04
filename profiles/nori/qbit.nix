{ config, lib, pkgs, utils, ... }: {
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  programs.ssh.knownHosts = {
    "laniakea.bunny.vpn".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWEWvH3KtMh7YStERmV+UWRL7xMV0mNlz2RYXmMKh3k";
  };

  systemd =
    let
      dst = "/home/nori/qbit/mnt";
      pfx = utils.escapeSystemdPath dst;
    in
    {
      mounts = [{
        name = "${pfx}.mount";
        what = "admin@laniakea.bunny.vpn:qbit";
        where = dst;
        type = "fuse.sshfs";
        options = lib.join "," [
          "_netdev"
          "nosuid"
          "rw"
          "allow_other"
          "default_permissions"
          "follow_symlinks"
          "identityfile=${config.aquaris.secret "user/nori/ssh/fido"}"
        ];
      }];

      automounts = [{
        name = "${pfx}.automount";
        where = dst;
        wantedBy = [ "multi-user.target" ];
      }];
    };
}
