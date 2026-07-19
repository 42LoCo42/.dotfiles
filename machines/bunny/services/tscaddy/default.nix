{ config, lib, pkgs, ... }: {
  topology.nodes.bunny-private.services."00-tscaddy" = {
    name = "Caddy (Tailscale)";
    icon = "services.caddy";
    info = "Service gateway inside the VPN";
  };

  virtualisation.pnoc.tscaddy = {
    cmd = [
      config.rice.invfork.outPath

      # parent process: caddy
      (lib.getExe pkgs.tscaddy)
      "run"

      "--" # child process: TCP proxy
      (lib.getExe pkgs.websocat)
      "--exit-on-eof"
      "--binary"
      "--set-environment"
      "--header-to-env=to"
      "ws-listen:127.0.0.1:12345"
      "exec:${pkgs.writeShellScript "connect" ''
        exec ${lib.getExe pkgs.netcat} -N "''${H_to%:*}" "''${H_to#*:}"
      ''}"
    ];

    environment = {
      HEADSCALE = "https://headscale.${config.rice.domain}";
      TSNET_FORCE_LOGIN = "1";
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
