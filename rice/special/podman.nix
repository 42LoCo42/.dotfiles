{ lib, config, ... }: {
  options.rice.podman.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.podman.enable {
    virtualisation.podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;
    };

    networking.firewall.trustedInterfaces = [ "podman0" ];
  };
}
