{ aquaris, lib, ... }:
let
  inherit (aquaris.lib) adt;
  inherit (lib) mkOption;
  inherit (lib.types) anything attrsOf bool coercedTo functionTo listOf luaInline nullOr number str submodule;

  # https://github.com/nix-community/home-manager/blob/c30c7955cec30d664a9baced6bc0112e263d4647/modules/services/window-managers/hyprland/default.nix#L18
  settingValueType =
    with lib.types;
    nullOr
      (oneOf [
        bool
        int
        float
        str
        path
        (attrsOf settingValueType)
        (listOf settingValueType)
      ])
    // {
      description = "Hyprland configuration value";
    };

  curveRef = adt {
    bezier.options.name = mkOption { type = str; };
    spring.options.name = mkOption { type = str; };
  };

  curveDef = adt {
    bezier.options = {
      points = mkOption { type = listOf (listOf number); };
    };

    spring.options = {
      mass = mkOption { type = number; };
      stiffness = mkOption { type = number; };
      dampening = mkOption { type = number; };
    };
  };
in
{
  options.rice.desktop.wayland.hyprland = {
    _util = mkOption {
      type = anything;
      readOnly = true;
      default = { inherit curveDef curveRef; };
    };

    enable = mkOption {
      type = bool;
      default = false;
    };

    settings = mkOption {
      type = settingValueType;
      default = { };
    };

    env = mkOption {
      type = attrsOf str;
      default = { };
    };

    monitors = mkOption {
      type = attrsOf (submodule {
        options = {
          mode = mkOption {
            type = str;
            default = "preferred";
          };

          position = mkOption {
            type = str;
            default = "auto";
          };

          scale = mkOption {
            type = number;
            default = 1.0;
          };
        };
      });

      default = { "" = { }; };
    };

    mod = mkOption {
      type = str;
      default = "SUPER";
    };

    binds = mkOption {
      type = functionTo (attrsOf
        (coercedTo luaInline (act: { inherit act; }) (submodule {
          options = {
            act = mkOption { type = luaInline; };
            raw = mkOption { type = bool; default = false; };
          };
        })));

      default = { };
    };

    prepwr = mkOption {
      type = str;
      description = "Command to run before power actions";
      default = ":";
    };

    events = mkOption {
      type = attrsOf (coercedTo str (x: [ x ]) (listOf str));
      default = { };
    };

    animations = mkOption {
      type = functionTo (attrsOf (submodule {
        options = {
          enabled = mkOption { type = bool; default = true; };
          speed = mkOption { type = number; };
          curve = mkOption { inherit (curveRef) type; default = curveRef.mk.bezier { name = "default"; }; };
          style = mkOption { type = nullOr str; default = null; };
        };
      }));

      default = _: { };
    };

    curves = mkOption {
      type = functionTo (attrsOf curveDef.type);
      default = _: { };
    };

    windowRules = mkOption {
      type = listOf settingValueType;
      default = [ ];
    };

    workspaceRules = mkOption {
      type = listOf settingValueType;
      default = [ ];
    };
  };
}
