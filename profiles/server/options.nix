{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib)
    flatten
    getExe
    getExe'
    mkOption
    ;
  inherit (lib.types)
    functionTo
    listOf
    package
    str
    ;
in
{
  options.rice = {
    domain = mkOption {
      type = str;
    };

    subsDomain = mkOption {
      type = functionTo package;
      default = file: aquaris.lib.subsF {
        inherit file;
        func = pkgs.writeText;
        subs = { inherit (config.rice) domain; };
      };
    };

    invfork = mkOption {
      type = package;
      default = pkgs.runCommandCC "invfork"
        { nativeBuildInputs = with pkgs; [ musl ]; } ''
        cc -Wall -Wextra -Werror -O3 -static -flto ${./invfork.c} -o $out
        strip -s $out
      '';
    };

    redis = mkOption {
      type = listOf str;
      default = flatten [
        [ (getExe pkgs.docker.docker-tini) "--" ]
        config.rice.invfork.outPath
        (getExe' pkgs.redis "redis-server")
        [ "--dir" "/data" ]
        [ "--bind" "127.0.0.1" ]
        "--"
      ];
    };

    anubis = mkOption {
      type = str;
      readOnly = true;
      default = ''
        ${getExe pkgs.anubis}              \
          --bind 0.0.0.0:8080              \
          --og-passthrough                 \
          --serve-robots-txt               \
          --policy-fname ${./anubis.yaml}  \
          --target http://localhost:8081 &
      '';
    };
  };
}
