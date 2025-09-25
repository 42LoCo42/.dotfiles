{ pkgs, lib, config, ... }: {
  topology.self.services.caddy = {
    name = "Caddy (Tailscale)";
    icon = "services.caddy";
    info = "Service gateway inside the VPN";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443

    8501 # ncps
  ];

  virtualisation.pnoc.caddy = {
    cmd = [ (lib.getExe pkgs.caddy) "run" "-a" "caddyfile" "-c" "${./Caddyfile}" ];

    environment.XDG_DATA_HOME = "/";

    ports = [
      "80:8080"
      "443:8443"
      "8501:8501"
    ];

    secrets = [ "svc/ca:/ca.key" ];

    volumes = [
      "caddy:/caddy"
      "${config.rice.ca.file}:/ca.crt"
    ];
  };
}
