{ lib, ... }:
let
  inherit (lib) genList listToAttrs mkOption pipe;
  inherit (lib.types) attrsOf bool functionTo listOf luaInline nullOr number
    oneOf str submodule;
in
{
  home-manager.sharedModules = [{
    options.aquaris.hyprland = {
      prepwr = mkOption {
        type = str;
        description = "Command to run before power actions";
        default = ":";
      };

      monitors =
        let
          monitor = submodule {
            options = {
              output = mkOption {
                type = str;
              };

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
          };
        in
        {
          primary = mkOption { type = monitor; };
          secondary = mkOption { type = nullOr monitor; default = null; };
        };

      workspaces = pipe 10 [
        (genList (x:
          let s = toString x; in {
            name = s;

            value = {
              index = mkOption {
                type = str;
                readOnly = true;
                default = toString (x + 1);
              };

              icon = mkOption {
                type = str;
                default = s;
              };

              rules = mkOption {
                type = listOf (attrsOf (oneOf [ bool number str ]));
                default = [ ];
              };

              autostart = mkOption {
                type = functionTo (listOf luaInline);
                default = _: [ ];
              };
            };
          }))
        listToAttrs
      ];
    };
  }];
}
