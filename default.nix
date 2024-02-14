let
  users = {
    leonsch = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql";
      git = {
        name = "Eleonora";
        email = "leonsch@protonmail.com";
        key = "C743EE077172986F860FC0FE2F6FE1420970404C";
      };
    };
  };

  machines = {
    akyuro = {
      id = "86b0e292e1fc27eb4168defa65cb41fd";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdZDuw+7O6+pV13ObPR/H4P8UCc1FzPmkufeaiJUc75";
      admins = { inherit (users) leonsch; };
    };
  };
in
{ inherit users machines; }
