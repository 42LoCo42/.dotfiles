{ pkgs, config, lib, ... }:
let
  inherit (lib)
    escapeShellArg
    mapAttrs'
    mkOption
    nameValuePair
    types;

  inherit (types)
    attrsOf
    bool
    either
    listOf
    path
    str
    submodule;

  cfg = config.environment.feengold;
in
{
  options.environment.feengold = {
    persistentLocation = mkOption {
      type = path;
      default = "/persist";
      description = "The path to persistent storage";
    };

    directories = mkOption {
      type = listOf (either path (submodule {
        options = {
          path = mkOption {
            type = path;
            description = "Where to mount this directory";
          };

          neededForBoot = mkOption {
            type = bool;
            default = false;
            description = "Whether this directory must be mounted during early boot";
          };

          mode = mkOption {
            type = str;
            default = "0755";
            description = "The mode of the persistent directory";
          };
        };
      }));

      default = [ ];
      description = "Persistent directories that will be bind-mounted";
    };

    # TODO maybe support modes and stuff for files?
    files = mkOption {
      type = listOf path;
      default = [ ];
      description = "Persistent files that will be symlinked";
    };

    users = mkOption {
      type = attrsOf (submodule {
        options = {
          links = mkOption {
            type = listOf str;
            default = [ ];
            description = "Persistent files or directories that will be symlinked";
          };
        };
      });
      default = { };
    };
  };

  config = {
    fileSystems = (builtins.listToAttrs (map
      (entry:
        let
          value = path: {
            device = "${cfg.persistentLocation}/${path}";
            options = [ "bind" "X-mount.mkdir" ];
          };
        in
        if builtins.isAttrs entry then {
          name = entry.path;
          value = value entry.path // {
            inherit (entry) neededForBoot;
          };
        } else {
          name = entry;
          value = value entry;
        })
      cfg.directories)) // {
      "${cfg.persistentLocation}".neededForBoot = true;
    };

    systemd.services.feengold = {
      description = "Create symlinks to persistent files/folders";
      before = [ "local-fs.target" ];
      wantedBy = [ "local-fs.target" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            # TODO: persistent directories need to be created earlier
            # maybe during activation?
            directory-cmds = map
              (entry:
                let path = if builtins.isAttrs entry then entry.path else entry;
                in ''mkdir -p "${cfg.persistentLocation}/${path}"'')
              cfg.directories;

            file-cmds = map
              (path: ''
                mkdir -p "${cfg.persistentLocation}/${dirOf path}" "/${dirOf path}"
                ln -sfT "${cfg.persistentLocation}/${path}" "/${path}"'')
              cfg.files;

            name = "feengold";
            text = builtins.concatStringsSep "\n" (directory-cmds ++ file-cmds);
            program = pkgs.writeShellApplication { inherit name text; };
          in
          "${program}/bin/${name}";
      };
    };

    systemd.user.services.feengold = {
      description = "Create symlinks to persistent files/folders";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            transformed = mapAttrs'
              (key: val: nameValuePair
                config.users.users.${key}.name
                val.links)
              cfg.users;

            name = "feengold";
            text = ''
              links=${escapeShellArg (builtins.toJSON transformed)}
              jq -r ".$1.[]" <<< "$links" | while read -r path; do
                path="$HOME/$path"
                dir="$(dirname "$path")"
                mkdir -p "$dir"
                ln -sfT "${cfg.persistentLocation}/$path" "$path"
              done
            '';

            program = pkgs.writeShellApplication {
              inherit name text;
              runtimeInputs = with pkgs; [ jq ];
            };
          in
          "${program}/bin/${name} %u";
      };
    };
  };
}
