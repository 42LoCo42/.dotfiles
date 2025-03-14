{ self, lib, config, ... }: {
  options.rice.unfreeNames = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = {
    nixpkgs.config.allowUnfreePredicate =
      p: builtins.elem (lib.getName p) config.rice.unfreeNames;

    nix = {
      # TODO does this actually do anything?
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";

      registry.obscura.to = {
        type = "github";
        owner = "42LoCo42";
        repo = "obscura";
        inherit (self.inputs.obscura) rev;
      };
    };
  };
}
