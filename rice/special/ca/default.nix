{ pkgs, lib, config, ... }:
let
  inherit (lib) getExe mkIf mkOption pipe;
  inherit (lib.types) bool pathInStore;

  cfg = config.rice.ca;
in
{
  options.rice.ca = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    file = mkOption {
      type = pathInStore;
      default = builtins.path { path = ./main.crt; };
    };
  };

  config = mkIf cfg.enable {
    security.pki.certificateFiles = [ cfg.file ];

    environment.variables.JAVAX_NET_SSL_TRUSTSTORE = pipe pkgs.python3 [
      (x: x.withPackages (p: with p; [ pyjks ]))
      (x: pkgs.runCommand "java-truststore" { } ''
        ${getExe x} ${./keystore.py} \
          ${config.environment.etc."ssl/certs/ca-bundle.crt".source} \
          $out
      '')
    ];
  };
}
