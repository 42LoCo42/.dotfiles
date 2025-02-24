{ pkgs, lib, config, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 443 ]; # QUIC
  };

  virtualisation.pnoc.caddy = {
    cmd = [ (lib.getExe pkgs.caddy) "run" "-a" "caddyfile" "-c" "${./Caddyfile}" ];

    environment = {
      DOMAIN = config.rice.domain;
      XDG_DATA_HOME = "/";
    };

    ports = [
      "80:8080"
      "443:8443"
      "443:8443/udp"
    ];

    volumes = [
      "caddy:/caddy"
      "${config.rice.homepage}:/srv/homepage" # can't be ro due to hidden/foo subdir
      "${pkgs.chronometer}:/srv/chronometer:ro"
      "/persist/home/admin/hidden:/srv/homepage/foo:ro"
      # "${pkgs.element-web}:/srv/element:ro"
      # "${subsDomain ./element.json}:/srv/element/config.json:ro"
    ];
  };
}
