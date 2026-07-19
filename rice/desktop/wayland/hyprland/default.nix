{ aquaris, config, lib, pkgs, self, ... }:
let
  inherit (lib)
    concatLines
    flip
    getExe
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
    replaceString
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

  secondary-enabled = replaceString "\n" "" ''
    "$(hyprctl monitors all -j | jq '.[] | select(
      .name == "${cfg.monitors.secondary.name}").disabled | not')"
  '';

  secondary-state = pkgs.writeShellScript "secondary-state" ''
    if ${secondary-enabled}; then
      if [ "$1" = disable ]; then
        hyprctl keyword monitor '${cfg.monitors.secondary.name}, disable'
      fi
    else
      if [ "$1" = enable ]; then
        hyprctl keyword monitor '${cfg.monitors.secondary.name}, 1600x900, auto-right, 1'
        hyprctl keyword monitor '${cfg.monitors.secondary.name}, ${cfg.monitors.secondary.mode}'
      fi
    fi
  '';

  secondary-goto = pkgs.writeShellScript "secondary-goto" ''
    if [ -n "$(
        hyprctl workspaces -j \
        | jq '.[] | select(.name == "secondary")'
      )" ] || ${secondary-enabled}
    then
      hyprctl dispatch workspace              "name:secondary"
      hyprctl dispatch moveworkspacetomonitor "name:secondary ${cfg.monitors.secondary.name}"
    fi
  '';

  secondary-move = pkgs.writeShellScript "secondary-move" ''
    ${secondary-state} enable
    hyprctl dispatch movetoworkspace        "name:secondary"
    hyprctl dispatch moveworkspacetomonitor "name:secondary ${cfg.monitors.secondary.name}"
  '';

  secondary-quit = pkgs.writeShellScript "secondary-quit" ''
    ${secondary-state} disable
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

    prepwr = mkOption {
      type = str;
      description = "Command to run before power actions";
      default = ":";
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
      type = attrsOf (submodule ({ config, name, ... }: {
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
            exec-once = sleep 1; ${secondary-state} disable

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
      imports = map (x: "${self.inputs.home-manager}/modules/${x}") [
        "services/window-managers/hyprland.nix"
      ];

      aquaris.persist = { ".config/qalculate" = { }; };

      home.packages = with pkgs; [
        brightnessctl
        fuzzel
        libqalculate
        mpc
        pulsemixer
      ];

      wayland.windowManager.hyprland = {
        enable = true;

        configType = "hyprlang";

        plugins = with pkgs.hyprlandPlugins; [
          hypr-dynamic-cursors
          hyprfocus
        ];

        extraConfig = pipe ./hyprland.conf [
          readFile
          (x: concatLines [ cfg.preConfig x cfg.postConfig ])
          (flip subs {
            inherit (cfg) prepwr;

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
