{ pkgs, lib, config, aquaris, ... }@top:
let
  inherit (lib)
    ifEnable
    mkOption
    pipe
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
        default =
          let
            environment = config.environment // ifEnable config.ssl {
              SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            };

            info = pipe { inherit (config) cmd; inherit environment; } [
              builtins.toJSON
              (pkgs.writeText "${name}-info")
            ];

            volumes = pkgs.runCommand "${name}-volumes"
              {
                __structuredAttrs = true;
                exportReferencesGraph.graph = info;
                nativeBuildInputs = with pkgs; [ jq ];
              } ''
              jq -r '
                .graph
                | map(.path)
                | sort
                | .[]
              ' "$NIX_ATTRS_JSON_FILE" \
              | grep -v "${info}" \
              | sed -E 's|(.*)|\1:\1:ro|' > $out

              jq -r '
                .graph[]
                | select(.path == "${info}")
                | .references[]
              ' "$NIX_ATTRS_JSON_FILE" \
              | while read -r i; do
                if test -d "$i/bin"; then
                  find "$i/bin" -mindepth 1 -maxdepth 1 -type f -executable \
                  | sed -E 's|(.+)/([^/]+)$|\1/\2:/bin/\2:ro|'
                fi
              done >> $out
            '';
          in
          {
            inherit (config) cmd environmentFiles ports workdir;
            inherit environment;

            extraOptions = config.extraOptions ++
              [ "--hostuser" name "--tz" top.config.time.timeZone ];

            image = "${empty.imageName}:${empty.imageTag}";
            imageFile = empty;

            user = name;

            volumes = config.volumes ++ aquaris.lib.readLines volumes;
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
      aquaris.lib.merge
    ];

    virtualisation.oci-containers.containers =
      builtins.mapAttrs (_: x: x._gen) cfg;
  };
}
