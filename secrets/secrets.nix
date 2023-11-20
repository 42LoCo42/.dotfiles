let
  # machines
  akyuro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjSkmdFrVrraCSwZZq7spsSMv43L8y68FflQhu2VqmP";
  test = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcCguBV6loAZZyJ2PCqQUxpZJy4H4YLdoZcoXkq65qY";

  # users
  leonsch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql";

  publicKeys = [ akyuro test leonsch ];

  # helper functions taken from nixpkgs.lib

  pipe = val: functions:
    let reverseApply = x: f: f x;
    in builtins.foldl' reverseApply val functions;

  filterAttrs = pred: set:
    builtins.listToAttrs (builtins.concatMap
      (name:
        let value = set.${name}; in
        if pred name value then [{ inherit name value; }] else [ ])
      (builtins.attrNames set));
in
pipe ./. [
  builtins.readDir
  (filterAttrs (name: _: builtins.match ".*\.age" name != null))
  (builtins.mapAttrs (name: _: { inherit publicKeys; }))
]
