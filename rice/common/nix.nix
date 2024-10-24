{ pkgs, ... }: {
  nix = {
    package = pkgs.lib.mkForce pkgs.lix;

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      keep-going = true;
      use-xdg-base-directories = true;
    };
  };
}
