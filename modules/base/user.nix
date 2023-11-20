{ ... }@os: {
  users.mutableUsers = false;
  users.users.default = {
    name = "leonsch";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = os.config.age.secrets.password-hash.path;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql" ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.default = { ... }@hm: {
    home.stateVersion = "23.11";
    home.file.".ssh/id_ed25519".source =
      hm.config.lib.file.mkOutOfStoreSymlink os.config.age.secrets."id_ed25519".path;
  };
}
