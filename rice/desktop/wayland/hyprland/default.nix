{ lib, pkgs, ... }:
let
  inherit (lib) attrValues flip mapAttrs' mapAttrsToList mkIf mkLuaInline
    mkMerge singleton;
in
{
  home-manager.sharedModules = singleton ({ config, ... }:
    let cfg = config.aquaris.hyprland; in {
      aquaris.hyprland = mkMerge ([
        {
          precfg = builtins.readFile ./lib.lua;
          settings.monitor = [ cfg.monitors.primary ];
        }

        (
          let
            snd = cfg.monitors.secondary;

            activate = pkgs.writeShellScript "activate-secondary-monitor" ''
              hyprctl eval 'hl.monitor({
                output = "${snd.output}",
                mode = "1600x800",
                disabled = false,
              })'

              hyprctl eval 'hl.monitor({
                output = "${snd.output}",
                mode = "${snd.mode}",
                position = "${snd.position}",
                disabled = false,
              })'
            '';
          in
          mkIf (snd != null) {
            settings.monitor = [{
              inherit (snd) output;
              disabled = mkLuaInline ''
                not state("secondary").get()
              '';
            }];

            binds = f: with f; {
              ssharp = function ''
                if hl.get_workspace("name:secondary") ~= nil then
                  hl.dispatch(hl.dsp.focus({ workspace = "name:secondary" }))
                end
              '';

              S-ssharp = function ''
                state("secondary").set(true)

                if hl.get_monitor("${snd.output}") == nil then
                   hl.dispatch(hl.dsp.exec_cmd("${activate}"))
                end

                hl.dispatch(hl.dsp.window.move({
                  workspace = "name:secondary",
                  follow = false,
                }))
              '';

              C-ssharp = function ''
                state("secondary").set(false)
                hl.monitor({output = "${snd.output}", disabled = true})
              '';
            };

            workspaceRules = [{
              workspace = "name:secondary";
              monitor = snd.output;
              default = true;
            }];
          }
        )
      ] ++ flip mapAttrsToList cfg.workspaces (_: v: {
        windowRules = flip map v.rules
          (r: { match = r; workspace = "${v.index} silent"; });

        workspaceRules = [{
          workspace = v.index;
          monitor = cfg.monitors.primary.output;
        }];

        events = f: {
          "hyprland.start" = v.autostart f;
        };
      }));

      wayland.windowManager.hyprland = {
        plugins = attrValues pkgs.hyprlandPlugins;
      };

      programs.waybar.settings.default = {
        "hyprland/workspaces".format-icons = flip mapAttrs' cfg.workspaces
          (_: v: { name = v.index; value = v.icon; });
      };
    });
}
