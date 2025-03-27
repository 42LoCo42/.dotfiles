{ pkgs, lib, config, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 443 ]; # QUIC
  };

  virtualisation.pnoc.caddy = {
    cmd = [ (lib.getExe pkgs.caddy) "run" ];

    environment = {
      DOMAIN = config.rice.domain;

      XDG_CONFIG_HOME = "/data/config";
      XDG_DATA_HOME = "/data/data";
    };

    ports = [
      "80:8080"
      "443:8443"
      "443:8443/udp"
    ];

    volumes = [
      "caddy:/data"
      "${./Caddyfile}:/Caddyfile:ro"

      "${config.rice.homepage}:/srv/homepage" # can't be ro due to hidden/foo subdir
      "/persist/home/admin/hidden:/srv/homepage/foo:ro"

      "${pkgs.chronometer}:/srv/chronometer:ro"

      # "${pkgs.element-web}:/srv/element:ro"
      # "${subsDomain ./element.json}:/srv/element/config.json:ro"
    ];
  };
}
