{ pkgs, ... }: {
  networking = {
    useNetworkd = true;
    networkmanager.enable = true;
    localCommands = "${pkgs.util-linux}/bin/rfkill unblock all";
    firewall.allowedTCPPorts = [
      18213
      37812
    ];
  };

  users.users.leonsch.extraGroups = [ "networkmanager" ];
}
