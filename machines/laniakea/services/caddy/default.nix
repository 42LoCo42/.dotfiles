{ pkgs, lib, config, ... }: {
  topology.self.services."00-caddy" = {
    name = "Caddy";
    icon = "services.caddy";
    info = "Primary service gateway";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
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
      "${config.rice.ca.file}:/ca.crt:ro"
      "${pkgs.cypht}/share/php/cypht:/srv/cypht:ro"
    ];
  };
}
