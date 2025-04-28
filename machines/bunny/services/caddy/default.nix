{ pkgs, lib, config, ... }:
let
  inherit (lib)
    concatLines
    getExe
    mapAttrsToList
    mkOption
    pipe
    splitString
    ;
  inherit (lib.types)
    attrsOf
    lines
    listOf
    str
    ;

  caddyfile = pipe config.rice.caddy.cfg [
    (mapAttrsToList (k: v: pipe v [
      (splitString "\n")
      (map (x: "  " + x))
      concatLines
      (v: ''
        ${if k == "" then "" else "${k}."}{$DOMAIN} {
        ${v}}
      '')
    ]))
    concatLines
    (x: builtins.readFile ./Caddyfile + x)
    (pkgs.writeText "Caddyfile")
  ];
in
{
  options.rice.caddy = {
    cfg = mkOption {
      type = attrsOf lines;
      default = "";
    };

    volumes = mkOption {
      type = listOf str;
      default = [ ];
    };
  };

  config = {
    rice.caddy = {
      volumes = [
        "caddy:/data"
        "${caddyfile}:/Caddyfile:ro"
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

      inherit (config.rice.caddy) volumes;
    };
  };
}
