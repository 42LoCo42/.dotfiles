let
  # machines
  test = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcCguBV6loAZZyJ2PCqQUxpZJy4H4YLdoZcoXkq65qY";

  # users
  leonsch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql";

  all = [ test leonsch ];
in
{
  "password-hash.age".publicKeys = all;
}
