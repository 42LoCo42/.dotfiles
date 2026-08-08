{ config, lib, pkgs, ... }:
let
  inherit (lib) attrValues defaultTo elemAt flatten flip genList length
    listToAttrs mapAttrsToList match mkIf pipe readFile replaceStrings;

  cfg = config.rice.desktop.wayland.hyprland;

  ##############################################################################

  binders = rec {
    lua = lib.mkLuaInline;
    toLua = lib.generators.toLua { };

    dsp = x: lua "hl.dsp.${x}";
    function = x: lua "function() ${x} end";
    raw = act: { inherit act; raw = true; };

    exec = cmd: execR cmd { };
    execR = cmd: rules: dsp "exec_cmd(${toLua cmd}, ${toLua rules})";

    dropdown = cmd: lua "dropdown(${toLua cmd})";
    focus = args: dsp "focus(${toLua args})";
    move = args: dsp "window.move(${toLua args})";

    prompt = text: cmd: exec ''
      echo -e 'No\nYes' \
      | fuzzel -d -p '${text}? ' --minimal-lines \
      | grep Yes && ${cmd}
    '';

    power = text: cmd: prompt text "sh -c '${cfg.prepwr}; ${cmd}'";

    fullscreen = internal: client: dsp ''
      window.fullscreen_state({
        action = "toggle",
        internal = ${toString internal},
        client = ${toString client},
      })
    '';
  };
in
{
  config = mkIf cfg.enable {
    rice.desktop.wayland = {
      hyprland = {
        settings = {
          env = mapAttrsToList (k: v: { _args = [ k v ]; }) cfg.env;

          monitor = mapAttrsToList
            (output: cfg: { inherit output; } // cfg)
            cfg.monitors;

          bind = pipe cfg.binds [
            (x: x binders)
            (mapAttrsToList (k: v: pipe k [
              (replaceStrings
                [ "A-" "C-" "S-" ]
                [ "ALT + " "CTRL + " "SHIFT + " ])
              (k: if v.raw then k else "${cfg.mod} + ${k}")
              (k: { _args = [ k v.act ]; })
            ]))
          ];

          on = pipe cfg.events [
            (mapAttrsToList (k: map (v:
              let
                parts = match "([^ ]+)( .*)?" k;
                event = elemAt parts 0;
                args = defaultTo "" (elemAt parts 1);
              in
              {
                _args = [
                  event
                  (binders.lua "function(${args}) ${v} end")
                ];
              })))
            flatten
          ];
        };
      };

      waybar.icons = pipe cfg.monitors [
        attrValues
        length
        (genList (mon: flip genList 10 (i: {
          name = toString ((i + 1) + mon * 100);
          value = toString i;
        })))
        flatten
        listToAttrs
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

      home.packages = with pkgs; [
        brightnessctl
        fuzzel
        libqalculate
        mpc
        pulsemixer
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        plugins = attrValues pkgs.hyprlandPlugins;

        extraLuaFiles.lib = {
          autoLoad = true;
          content = readFile ./lib.lua;
        };

        inherit (cfg) settings;
      };
    }];
  };
}
