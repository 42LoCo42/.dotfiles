let
  # machines
  akyuro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjSkmdFrVrraCSwZZq7spsSMv43L8y68FflQhu2VqmP";
  test = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcCguBV6loAZZyJ2PCqQUxpZJy4H4YLdoZcoXkq65qY";

  # users
  leonsch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql";

  all = [ akyuro test leonsch ];
in
{
  "password-hash.age".publicKeys = all;
  "id_ed25519.age".publicKeys = all;
}
