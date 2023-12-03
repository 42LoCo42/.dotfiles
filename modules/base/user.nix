{ config, my-utils, ... }: {
  users.mutableUsers = false;
  users.users.default = {
    name = "leonsch";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.age.secrets.password-hash.path;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql" ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.default = { ... }: {
    home.stateVersion = "23.11";

    home.activation.linkSSHKey = my-utils.mkHomeLinks [{
      src = config.age.secrets."id_ed25519".path;
      dst = "$HOME/.ssh/id_ed25519";
    }];
  };
}
