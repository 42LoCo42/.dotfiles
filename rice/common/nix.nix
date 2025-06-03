{ self, pkgs, lib, config, ... }: {
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
      package = pkgs.lixPackageSets.lix_2_93.lix;

      registry.obscura.to = {
        type = "github";
        owner = "42LoCo42";
        repo = "obscura";
        inherit (self.inputs.obscura) rev;
      };
    };
  };
}
