{ pkgs, lib, config, ... }:
let
  inherit (lib)
    concatLines
    getExe
    hasInfix
    mapAttrsToList
    mkOption
    pipe
    splitString
    ;
  inherit (lib.types)
    attrsOf
    lines
    listOf
    package
    str
    ;

  cfg = config.rice.caddy;
in
{
  options.rice.caddy = {
    cfg = mkOption {
      type = attrsOf lines;
      default = "";
    };

    cfg-merged = mkOption {
      type = lines;
      readOnly = true;
      default = pipe cfg.cfg [
        (mapAttrsToList (k: v: pipe v [
          (splitString "\n")
          (map (x: "  " + x))
          concatLines
          (v:
            let
              entry =
                if k == "" then "{$DOMAIN}"
                else if hasInfix ":" k then k
                else "${k}.{$DOMAIN}";
            in
            "${entry} {\n${v}}")
        ]))
        concatLines
        (x: builtins.readFile ./Caddyfile + x)
      ];
    };

    caddyfile = mkOption {
      type = package;
      readOnly = true;
      default = pkgs.writeText "Caddyfile" cfg.cfg-merged;
    };

    volumes = mkOption {
      type = listOf str;
      default = [ ];
    };
  };

  config = {
    topology.nodes.bunny-public.services."00-caddy" = {
      name = "Caddy";
      icon = "services.caddy";
      info = "Primary service gateway";
      details.url.text = "https://${config.rice.domain}";
    };

    rice.caddy = {
      volumes = [
        "caddy:/data"
        "${cfg.caddyfile}:/Caddyfile:ro"
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ]; # QUIC
    };

    virtualisation.pnoc.caddy = {
      cmd = [ (getExe pkgs.caddy) "run" ];

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

      inherit (cfg) volumes;
    };
  };
}
