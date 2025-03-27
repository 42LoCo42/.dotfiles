{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.tscaddy = {
    cmd = [ (lib.getExe pkgs.tscaddy) "run" ];

    environment = {
      XDG_CONFIG_HOME = "/data/config";
      XDG_DATA_HOME = "/data/data";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/tscaddy") ];

    extraOptions = [ "--cap-add=net_bind_service" ];

    secrets = [ "svc/ca:/ca.key" ];

    volumes = [
      "tscaddy:/data"
      "${./Caddyfile}:/Caddyfile:ro"
      "${config.rice.ca.file}:/ca.crt:ro"
    ];
  };
}
