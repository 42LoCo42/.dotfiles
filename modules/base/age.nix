{ pkgs, lib, self, ... }: {
  imports = [ self.inputs.agenix.nixosModules.default ];
  nixpkgs.overlays = [ self.inputs.agenix.overlays.default ];

  environment.systemPackages = with pkgs; [ agenix ];

  age = {
    identityPaths = [ "/etc/age.key" ];

    secrets = lib.pipe "${self}/secrets/secrets.nix" [
      import
      builtins.attrNames
      (map (path: {
        name = builtins.replaceStrings [ ".age" ] [ "" ] path;
        value.file = "${self}/secrets/${path}";
      }))
      builtins.listToAttrs
    ];
  };
}