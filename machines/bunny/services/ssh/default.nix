{ lib, ... }:
let endless = 22; real = 18213; in {
  rice.oci-firewall.rules = [
    { desc = "Endlessh"; type = "tcp"; port = endless; }
    { desc = "OpenSSH"; type = "tcp"; port = real; }
  ];

  services = {
    endlessh = {
      enable = true;
      port = endless;
      extraOptions = [ "-v" ];
    };

    openssh.ports = lib.mkForce [ real ];
  };
}
