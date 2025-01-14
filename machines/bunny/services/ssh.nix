{ lib, ... }: {
  services = {
    endlessh = {
      enable = true;
      port = 22;
      openFirewall = true;
      extraOptions = [ "-v" ];
    };

    openssh.ports = lib.mkForce [ 18213 ];
  };
}
