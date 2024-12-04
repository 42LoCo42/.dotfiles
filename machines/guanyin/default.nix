{ pkgs, lib, modulesPath, aquaris, ... }:
let inherit (lib) mkForce; in {
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    ../../rice
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  system.stateVersion = mkForce "24.05";

  aquaris = {
    machine = {
      id = "99f7c536ac386aeb32291d4e65f549dc";
      secureboot = false;
    };

    users.root = {
      description = "System administrator";
      home = "/root";
      sshKeys = [ aquaris.cfg.mainSSHKey ];
    };
  };

  isoImage.isoBaseName = mkForce "nixos-guanyin";

  boot.initrd.systemd.enable = false;
  networking.wireless.enable = false;
  system.etc.overlay.enable = false;
  system.installer.channel.enable = false;

  services = {
    getty.autologinUser = mkForce "root";

    openssh.settings = {
      PermitRootLogin = mkForce "yes";
      PasswordAuthentication = mkForce true;
    };
  };

  environment.systemPackages = with pkgs; [
    rsync
    sbctl
    sshx
  ];

  users.users.root = {
    isNormalUser = false;

    password = " ";
    hashedPassword = null;
    initialHashedPassword = mkForce null;
  };
}
