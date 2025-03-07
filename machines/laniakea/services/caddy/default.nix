{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) concatLines getExe pipe;

  caddyfile = pipe [
    "laniakea.fritz.box"
    "laniakea.bunny.vpn"
  ] [
    (map (domain: aquaris.lib.subsT ./hosts.caddy {
      inherit domain;
    }))
    concatLines
    (x: builtins.readFile ./main.caddy + x)
    (pkgs.writeText "Caddyfile")
  ];
in
{
  networking.firewall.allowedTCPPorts = [
    80 # generic caddy HTTP
    443 # mympd socket-activation proxy
    8501 # ncps proxy
  ];

  virtualisation.pnoc.caddy = {
    cmd = [ (getExe pkgs.caddy) "run" "-a" "caddyfile" "-c" "${caddyfile}" ];

    environment.XDG_DATA_HOME = "/";

    ports = [
      "80:8080"
      "8443:8443"
      "8501:8501"
    ];

    secrets = [ "ca/main/key:/ca.key" ];

    volumes = [
      "caddy:/caddy"
      "${config.rice.ca.file}:/ca.crt"
    ];
  };
}
