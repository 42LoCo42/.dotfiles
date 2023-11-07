{ self, ... }: {
  imports = [ self.inputs.agenix.nixosModules.default ];

  age.secrets = builtins.listToAttrs (map
    (name: {
      inherit name;
      value.file = "${self}/secrets/${name}.age";
    }) [
    "password-hash"
  ]);
}
