{
  nix = {
    # TODO does this actually do anything?
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };
}
