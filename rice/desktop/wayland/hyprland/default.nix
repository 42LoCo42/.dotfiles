{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib)
    concatLines
    flip
    getExe
    getExe'
    listToAttrs
    mapAttrs'
    mapAttrsToList
    mkBefore
    mkDefault
    mkIf
    mkMerge
    mkOption
    pipe
    range
    readFile
    toInt
    ;
  inherit (lib.types)
    attrsOf
    bool
    functionTo
    int
    lines
    listOf
    nullOr
    str
    submodule
    ;
  inherit (aquaris.lib) subsF;

  join = builtins.concatStringsSep "";

  subs = x: s: aquaris.lib.subs { text = x; subs = s; };
  script = x: subsF (x // { func = pkgs.writeScript; });

  cfg = config.rice.desktop.wayland.hyprland;

  secondary-goto = pkgs.writeShellScript "secondary-goto" ''
    if
      [ -n "$(
        hyprctl workspaces -j \
        | jq '.[] | select(.name == "secondary")'
      )" ] ||
      "$(
        hyprctl monitors all -j | jq -r '
          .[] | select(.name == "${cfg.monitors.secondary.name}")
          | .disabled | not'
      )"
    then
      hyprctl dispatch workspace              "name:secondary"
      hyprctl dispatch moveworkspacetomonitor "name:secondary ${cfg.monitors.secondary.name}"
    fi
  '';

  secondary-move = pkgs.writeShellScript "secondary-move" ''
    hyprctl keyword monitor ${cfg.monitors.secondary.name}
    hyprctl dispatch movetoworkspace        "name:secondary"
    hyprctl dispatch moveworkspacetomonitor "name:secondary ${cfg.monitors.secondary.name}"
  '';

  secondary-quit = pkgs.writeShellScript "secondary-quit" ''
    hyprctl keyword monitor ${cfg.monitors.secondary.name},disable
  '';
in
{
  options.rice.desktop.wayland.hyprland = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    mod = mkOption {
      type = str;
      default = "SUPER";
    };

    preConfig = mkOption {
      type = lines;
      default = "";
    };

    postConfig = mkOption {
      type = lines;
      default = "";
    };

    monitors = {
      primary = {
        name = mkOption { type = str; };
        mode = mkOption { type = str; };
      };

      secondary = mkOption {
        type = nullOr (submodule {
          options = {
            name = mkOption { type = str; };
            mode = mkOption { type = str; };
          };
        });

        default = null;
      };
    };

    workspaces = mkOption {
      type = attrsOf (submodule ({ name, config, ... }: {
        options = {
          indexN = mkOption {
            type = int;
            description = "Parsed index of this workspace";
            default = toInt name;
          };

          indexS = mkOption {
            type = str;
            description = "Parsed index of this workspace ";
            default = toString config.indexN;
          };

          internalN = mkOption {
            type = int;
            description = "Actual index of the workspace (internal to Hyprland)";
            default = config.indexN + 1;
          };

          internalS = mkOption {
            type = str;
            description = "Actual index of the workspace (internal to Hyprland)";
            default = toString config.internalN;
          };

          icon = mkOption {
            type = str;
            description = "Icon of the workspace (shown by waybar)";
            default = name;
          };

          autostart = mkOption {
            type = listOf str;
            description = "List of commands to autostart in this workspace";
            default = [ ];
          };

          rules = mkOption {
            type = listOf str;
            description = "Window rules bound to this workspace";
            default = [ ];
          };

          extra = mkOption {
            type = functionTo lines;
            description = ''
              Any extra configuration for this workspace.
              Gets passed this submodule; must return lines.
            '';
            default = _: "";
          };
        };
      }));
      default = { };
    };
  };

  config = mkIf cfg.enable {
    rice.desktop.wayland = {
      hyprland = {
        workspaces = mkMerge [
          (pipe (range 0 9) [
            (map (x:
              let name = toString x; in {
                inherit name;
                value = {
                  icon = mkDefault name;
                  extra = x: ''
                    bind = $mod,       ${x.indexS}, workspace,              ${x.internalS}
                    bind = $mod,       ${x.indexS}, moveworkspacetomonitor, ${x.internalS} ${cfg.monitors.primary.name}
                    bind = $mod SHIFT, ${x.indexS}, movetoworkspace,        ${x.internalS}
                    bind = $mod SHIFT, ${x.indexS}, moveworkspacetomonitor, ${x.internalS} ${cfg.monitors.primary.name}
                  '';
                };
              }))
            listToAttrs
          ])

          {
            "0" = {
              icon = "";
              extra = x: ''
                bind = $mod,       dead_circumflex, workspace,              ${x.internalS}
                bind = $mod,       dead_circumflex, moveworkspacetomonitor, ${x.internalS} ${cfg.monitors.primary.name}
                bind = $mod SHIFT, dead_circumflex, movetoworkspace,        ${x.internalS}
                bind = $mod SHIFT, dead_circumflex, moveworkspacetomonitor, ${x.internalS} ${cfg.monitors.primary.name}
              '';
            };
          }
        ];

        preConfig = mkMerge [
          (mkBefore ''
            env = GDK_BACKEND,wayland
            env = QT_QPA_PLATFORM,wayland
            env = SDL_VIDEODRIVER,wayland

            env = NIXOS_OZONE_WL,1
            env = _JAVA_AWT_WM_NONREPARENTING,1

            $mod = ${cfg.mod}
          '')

          ''
            monitor = ${cfg.monitors.primary.name}, ${cfg.monitors.primary.mode}
            workspace = n[false], monitor:${cfg.monitors.primary.name}
          ''

          (mkIf (cfg.monitors.secondary != null) ''
            monitor = ${cfg.monitors.secondary.name}, ${cfg.monitors.secondary.mode}
            workspace = name:secondary, monitor:${cfg.monitors.secondary.name}, default
            exec-once = hyprctl keyword monitor '${cfg.monitors.secondary.name}, disable'

            bind = $mod      , ssharp, exec, ${secondary-goto}
            bind = $mod SHIFT, ssharp, exec, ${secondary-move}
            bind = $mod CTRL , ssharp, exec, ${secondary-quit}
          '')
        ];

        postConfig = pipe cfg.workspaces [
          (mapAttrsToList (_: x: pipe [
            (flip map x.rules (y:
              "windowrule = match:${y}, workspace ${x.internalS}"))
            (flip map x.autostart (y:
              "exec-once = [workspace ${x.internalS} silent] ${y}"))
            [ (x.extra x) ]
          ] [ (map concatLines) join ]
          ))
          join
        ];
      };

      waybar.icons = pipe cfg.workspaces [
        (mapAttrs' (_: x: {
          name = x.internalS;
          value = x.icon;
        }))
      ];
    };

    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };

      uwsm.package = pkgs.uwsm.override {
        uuctlSupport = false; # would pull in dmenu
      };
    };

    home-manager.sharedModules = [{
      aquaris.persist = { ".config/qalculate" = { }; };

      wayland.windowManager.hyprland = {
        enable = true;

        plugins = with pkgs.hyprlandPlugins; [
          hypr-dynamic-cursors
          hyprfocus
        ];

        extraConfig = pipe ./hyprland.conf [
          readFile
          (x: concatLines [ cfg.preConfig x cfg.postConfig ])
          (flip subs {
            fuzzel = getExe pkgs.fuzzel;
            ipython = getExe' pkgs.python3Packages.ipython "ipython";
            pulsemixer = getExe pkgs.pulsemixer;
            qalc = getExe pkgs.libqalculate;

            audio-helper = script {
              file = ./scripts/audio-helper.sh;
              subs = {
                pulsemixer = getExe pkgs.pulsemixer;
                mpc = getExe pkgs.mpc;
              };
            };

            brightness-helper = script {
              file = ./scripts/brightness-helper.sh;
              subs = {
                brightnessctl = getExe pkgs.brightnessctl;
              };
            };

            dropdown = script {
              file = ./scripts/dropdown.sh;
            };

            idle-toggle = script {
              file = ./scripts/idle-toggle.sh;
            };

            prompt = script {
              file = ./scripts/prompt.sh;
              subs = {
                fuzzel = getExe pkgs.fuzzel;
              };
            };

            safekill = script {
              file = ./scripts/safekill.sh;
            };

            terminal = script {
              file = ./scripts/terminal.sh;
            };
          })
        ];
      };
    }];
  };
}
