{ pkgs, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  isoImage.isoBaseName = lib.mkForce "nixos-guanyin";
  # isoImage.squashfsCompression = "lz4";

  aquaris.standalone = true;

  boot = {
    lanzaboote.enable = lib.mkForce false;
    loader.timeout = lib.mkForce 5;
    initrd.systemd.enable = lib.mkForce false;
  };

  system.installer.channel.enable = false;

  networking.wireless.enable = false;

  services.getty.autologinUser = lib.mkForce "root";

  services.openssh.settings = {
    PermitRootLogin = lib.mkForce "yes";
    PasswordAuthentication = lib.mkForce true;
  };

  environment.systemPackages = with pkgs; [
    rsync
    sshx
  ];

  users.users.root = {
    isNormalUser = lib.mkForce false;
    password = " ";
    hashedPassword = lib.mkForce null;
    initialHashedPassword = lib.mkForce null;
    openssh.authorizedKeys.keys = lib.mkForce [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql"
    ];
  };
}
