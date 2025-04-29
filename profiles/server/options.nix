{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib)
    concatLines
    flatten
    flip
    getExe
    getExe'
    mapAttrsToList
    mkOption
    pipe
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
        [ (getExe pkgs.tini) "--" ]
        (config.rice.invfork.outPath)
        (getExe' pkgs.redis "redis-server")
        [ "--dir" "/data" ]
        [ "--bind" "127.0.0.1" ]
        "--"
      ];
    };

    mkRunit = mkOption {
      type = functionTo package;
      default = flip pipe [
        (mapAttrsToList (k: v: ''
          mkdir -p $out/${k}

          cat <<\EOF > $out/${k}/run
          #!${getExe pkgs.bash}
          ${v}
          EOF
          chmod +x $out/${k}/run

          ln -s /tmp/${k}.supervise $out/${k}/supervise
        ''))
        concatLines
        (pkgs.runCommand "runit-services" { })
      ];
    };
  };
}
