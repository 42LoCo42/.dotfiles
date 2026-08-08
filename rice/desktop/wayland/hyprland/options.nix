{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf bool coercedTo float functionTo listOf luaInline str submodule;

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
in
{
  options.rice.desktop.wayland.hyprland = {
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
            type = float;
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
  };
}
