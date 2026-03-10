{ pkgs, lib, config, ... }: {
  options.rice.desktop.wayland.foot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    alpha = lib.mkOption {
      type = lib.types.str;
      default = "0.${toString config.rice.desktop.alpha}";
    };
  };

  config = lib.mkIf config.rice.desktop.wayland.foot.enable {
    home-manager.sharedModules = [{
      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "monospace:size=10.5";
            include = "${pkgs.foot.themes}/share/foot/themes/gruvbox-dark";
          };

          colors-dark = {
            inherit (config.rice.desktop.wayland.foot) alpha;
          };
        };
      };
    }];
  };
}
