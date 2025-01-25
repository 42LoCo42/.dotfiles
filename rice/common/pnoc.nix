{ pkgs, lib, config, aquaris, ... }@top:
let
  inherit (lib) flip mkOption pipe;

  inherit (lib.types)
    attrsOf
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

      volumes = mkOption {
        type = listOf str;
        default = [ ];
      };

      workdir = mkOption {
        type = nullOr str;
        default = null;
      };
    };

    config = {
      environment = {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };

      extraOptions = [ "--hostuser" name "--tz" top.config.time.timeZone ];
    };
  };

  deps = name: cfg:
    let
      info = pipe { inherit (cfg) cmd environment; } [
        builtins.toJSON
        (pkgs.writeText "${name}-info")
      ];
    in
    (pkgs.runCommand "${name}-volumes" {
      __structuredAttrs = true;
      exportReferencesGraph.graph = info;
      nativeBuildInputs = with pkgs; [ jq ];
    }) ''
      jq -r '
        .graph
        | map(.path)
        | sort
        | .[]
      ' "$NIX_ATTRS_JSON_FILE" \
      | grep -v "${info}" \
      | sed -E 's|(.*)|-v \1:\1:ro|' > $out

      jq -r '
        .graph[]
        | select(.path == "${info}")
        | .references[]
      ' "$NIX_ATTRS_JSON_FILE" \
      | while read -r i; do
        if test -d "$i/bin"; then
          find "$i/bin" -mindepth 1 -maxdepth 1 -type f -executable \
          | sed -E 's|(.+)/([^/]+)$|-v \1/\2:/bin/\2:ro|'
        fi
      done >> $out
    '';

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


    virtualisation = {
      podman = {
        package = pkgs.podman // { override = _: pkgs.podman; };
        defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers.containers = flip builtins.mapAttrs cfg
        (name: cfg: cfg // {
          image = "$(< ${deps name cfg}) ${empty.imageName}:${empty.imageTag}";
          imageFile = empty;

          user = name;
        });
    };
  };
}
