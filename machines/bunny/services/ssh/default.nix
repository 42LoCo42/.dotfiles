{ lib, pkgs, ... }:
let endless = 22; real = 18213; in {
  rice.oci-firewall.rules = [
    { desc = "Endlessh"; type = "tcp"; port = endless; }
    { desc = "OpenSSH"; type = "tcp"; port = real; }
  ];

  services.openssh.ports = lib.mkForce [ real ];

  virtualisation.pnoc.endlessh = {
    path = with pkgs; [ endlessh-go ];

    script = ''
      exec endlessh-go         \
        -logtostderr           \
        -v 1                   \
        -port 2222             \
        -geoip_supplier ip-api \
        -enable_prometheus     \
        -prometheus_port 9090  \
    '';

    ports = [ "${toString endless}:2222" ];
  };
}
