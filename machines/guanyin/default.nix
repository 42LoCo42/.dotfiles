{ pkgs, lib, modulesPath, aquaris, ... }:
let inherit (lib) mkForce; in {
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    ../../rice
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  system = {
    etc.overlay.enable = false;
    installer.channel.enable = false;
    stateVersion = mkForce "24.05";
  };

  aquaris = {
    machine = {
      id = "99f7c536ac386aeb32291d4e65f549dc";
      secureboot = false;
    };

    users.root = {
      description = "System administrator";
      home = "/root";
      sshKeys = builtins.attrValues aquaris.cfg.ssh;
    };

    secrets.enable = false;
  };

  isoImage.edition = "guanyin";

  boot.initrd.systemd.enable = false;

  security.sudo.enable = mkForce false;

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
