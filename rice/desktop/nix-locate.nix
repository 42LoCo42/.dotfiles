{ self, lib, config, ... }:
let
  inherit (lib) mkIf mkMerge mkOption;
  inherit (lib.types) bool;

  cfg = config.rice.desktop.nix-locate;
in
{
  options.rice.desktop.nix-locate.enable = mkOption {
    type = bool;
    default = false;
  };

  imports = [ self.inputs.nix-index-database.nixosModules.nix-index ];

  config = mkMerge [
    {
      programs.nix-index.enable = cfg.enable;
    }

    (mkIf cfg.enable {
      home-manager.sharedModules = [{
        home.shellAliases = {
          nl = "nix-locate";
          nlr = "nl --regex";
        };

        programs.zsh.initContent = ''
          nlb() {
            nix-locate --regex "bin/$1$"
          }
        '';
      }];
    })
  ];
}
