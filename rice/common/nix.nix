{ self, ... }: {
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
}
