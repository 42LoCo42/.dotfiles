{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types;

  inherit (types)
    attrsOf
    listOf
    path
    str;

  cfg = config.environment.feengold;
in
{
  options.environment.feengold = {
    persistentLocation = mkOption {
      type = path;
      default = "/persist";
      description = "The path to persistent storage";
    };

    binds = mkOption {
      type = listOf path;
      default = [ ];
      description = "Persistent directories that will be bind-mounted";
    };

    links = mkOption {
      type = listOf path;
      default = [ ];
      description = "Persistent files that will be symlinked";
    };

    users = mkOption {
      type = attrsOf (listOf str);
      default = { };
      description = "Persistent user symlinks";
    };
  };

  config = {
    fileSystems = (builtins.listToAttrs (map
      (path: {
        name = path;
        value = {
          device = "${cfg.persistentLocation}/${path}";
          options = [ "bind" "X-mount.mkdir" ];
        };
      })
      cfg.binds)) // {
      "${cfg.persistentLocation}".neededForBoot = true;
    };

    system.activationScripts.feengold-system-links.text = lib.concatMapStringsSep "\n"
      (path: ''
        mkdir -p ${cfg.persistentLocation}/${dirOf path} /${dirOf path}
        rm -rf /${path}
        ln -sT ${cfg.persistentLocation}/${path} /${path}
      '')
      cfg.links;

    home-manager.users = builtins.mapAttrs
      (_: paths:
        { ... }@hm: {
          home.file = builtins.listToAttrs (map
            (path: {
              name = path;
              value.source =
                hm.config.lib.file.mkOutOfStoreSymlink
                  "${cfg.persistentLocation}/${hm.config.home.homeDirectory}/${path}";
            })
            paths);
        })
      cfg.users;
  };
}
