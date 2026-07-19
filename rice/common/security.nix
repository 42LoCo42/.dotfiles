{ lib, pkgs, ... }:
let
  inherit (lib)
    escapeShellArgs
    mkForce
    mkMerge
    pipe
    ;
in
{
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "hidepid=invisible" "gid=1" ]; # GID 1 is wheel
  };

  security.polkit.enablePkexecWrapper = false;

  systemd.services = {
    polkit.enable = false;

    libvirtd.environment.LIBVIRTD_ARGS = mkForce (escapeShellArgs [
      "--config"
      (pkgs.writeText "libvirtd.conf" ''
        unix_sock_group    = "libvirtd"
        unix_sock_ro_perms = "0770"
        unix_sock_rw_perms = "0770"
        auth_unix_ro       = "none"
        auth_unix_rw       = "none"
      '').outPath

      "--timeout=120"
    ]);
  };

  security = {
    sudo-rs.extraRules = [{
      groups = [ "wheel" ];
      commands = (map (x: {
        command = "/run/current-system/sw/bin/systemctl ${x}";
        options = [ "NOPASSWD" ];
      })) [
        "poweroff"
        "reboot"
        "suspend"
      ];
    }];

    wrappers = pipe [
      "Hyprland"
      "fusermount"
      "fusermount3"
      "mount"
      "newgidmap"
      "newgrp"
      "newuidmap"
      "pkexec"
      "sg"
      "su"
      "sudoedit"
      "umount"
    ] [
      (map (x: { ${x}.enable = false; }))
      mkMerge
    ];
  };
}
