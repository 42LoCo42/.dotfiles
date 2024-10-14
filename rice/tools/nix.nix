{ pkgs, ... }: {
  nix = {
    package = pkgs.lib.mkForce pkgs.lix;

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings.keep-going = true;
  };
}
