{ ... }: {
  users.mutableUsers = false;
  users.users.default = {
    name = "leonsch";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialHashedPassword =
      # use hash from secret file only when it's in a known (decrypted) state
      # otherwise use " " (single space) as password
      # this is ugly
      let
        file = ./hash.secret;
        realHash = builtins.hashFile "sha256" file;
        wantHash = "e7b44e5e59594b3ee78549525167ce83d9d368df769f49a5bd1d2525aebb9d88";
        real = builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);
        space = builtins.trace
          "warning: using \" \" (single space) as password - please decrypt hash.secret!"
          "$y$j9T$rs6onrT38/cnFRJEUFnIV1$LWZcBd5R5y7iTKsPgseCaws2InrhhyJQGdULSPsrmJ6";
      in
      if realHash == wantHash then real else space;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql" ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.default = { ... }: {
    home.stateVersion = "23.11";
  };
}
