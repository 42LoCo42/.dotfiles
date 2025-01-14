{
  users = {
    users.nixremote = {
      isSystemUser = true;
      useDefaultShell = true;

      group = "nixremote";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEKVzQKnlm3NiBbK2l4zhJfxWZH2zuuXD46V3cWUfg5"
      ];
    };

    groups.nixremote = { };
  };

  nix.settings.trusted-users = [ "nixremote" ];
}
