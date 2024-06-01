{ pkgs, lib, config, my-utils, ... }:
let
  inherit (lib)
    fileContents
    ifEnable
    mkOption
    pipe
    splitString
    ;

  inherit (lib.types)
    anything
    attrsOf
    bool
    listOf
    nullOr
    path
    str
    submodule
    ;

  empty = pkgs.dockerTools.buildImage {
    name = "empty";
    tag = "latest";
  };

  container = { name, config, ... }: {
    options = {
      cmd = mkOption { type = listOf str; };

      environment = mkOption {
        type = attrsOf str;
        default = { };
      };

      environmentFiles = mkOption {
        type = listOf path;
        default = [ ];
      };

      extraOptions = mkOption {
        type = listOf str;
        default = [ ];
      };

      ports = mkOption {
        type = listOf str;
        default = [ ];
      };

      ssl = mkOption {
        type = bool;
        default = false;
      };

      volumes = mkOption {
        type = listOf str;
        default = [ ];
      };

      workdir = mkOption {
        type = nullOr str;
        default = null;
      };

      ####################

      _gen = mkOption {
        type = attrsOf anything;
        default = rec {
          inherit (config) cmd environmentFiles ports workdir;

          environment = config.environment // ifEnable config.ssl {
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          };

          extraOptions = config.extraOptions ++ [ "--hostuser" name ];

          image = "${empty.imageName}:${empty.imageTag}";
          imageFile = empty;

          user = name;

          volumes = config.volumes ++ pipe { inherit cmd environment; } [
            builtins.toJSON
            (pkgs.writeText "${name}-cmd")
            (x: pipe x [
              pkgs.writeClosure
              fileContents
              (splitString "\n")
              (builtins.filter (y: toString x != y))
            ])
            (map (x: "${x}:${x}"))
          ];
        };
      };
    };
  };

  cfg = config.virtualisation.pnoc;
in
{
  options.virtualisation.pnoc = mkOption {
    type = attrsOf (submodule container);
    default = { };
  };

  config = {
    users = pipe cfg [
      builtins.attrNames
      (map (x: {
        users.${x} = {
          group = x;
          isSystemUser = true;
        };
        groups.${x} = { };
      }))
      my-utils.recMerge
    ];

    virtualisation.oci-containers.containers =
      builtins.mapAttrs (_: x: x._gen) cfg;
  };
}
