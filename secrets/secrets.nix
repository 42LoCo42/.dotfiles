let
  akyuro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5x4vhIb02WC6ZbiNbpKTjKEFY+lv232vCRWoqde60T";
  test = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5m2wcBV3xzDzhLWdW7SRP74a9zgYMtn+DBXYlPbl5u";

  all = [ akyuro test ];
in
{
  "password-hash.age".publicKeys = all;
}
