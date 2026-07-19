{ config, lib, pkgs, self, ... }: {
  options.rice = {
    insecureNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    unfreeNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    nixpkgs.config = {
      allowInsecurePredicate =
        p: builtins.elem (lib.getName p) config.rice.insecureNames;

      allowUnfreePredicate =
        p: builtins.elem (lib.getName p) config.rice.unfreeNames;
    };

    nix = {
      package = pkgs.lixPackageSets.latest.lix;

      registry.obscura.to = {
        type = "github";
        owner = "42LoCo42";
        repo = "obscura";
        inherit (self.inputs.obscura) rev;
      };

      settings = {
        allowed-users = [ "@wheel" ];

        auto-allocate-uids = true;
        use-cgroups = true;
        experimental-features = [ "auto-allocate-uids" "cgroups" ];
      };
    };
  };
}
