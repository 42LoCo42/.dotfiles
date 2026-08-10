{ config, lib, pkgs, ... }: {
  options.rice.desktop.zathura.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.zathura.enable {
    home-manager.sharedModules = [{
      aquaris.persist = {
        ".local/share/zathura" = { };
      };

      programs.zathura = {
        enable = true;

        package = pkgs.aqwrap pkgs.zathura {
          cmd.pre = "--mode=fullscreen";
        };

        options = {
          selection-clipboard = "clipboard";
          guioptions = "";

          recolor = true;
          recolor-keephue = true;
          recolor-lightcolor = "#282828";
          recolor-darkcolor = "#ebdbb2";

          scroll-page-aware = true;
          vertical-center = true;
        };
      };
    }];
  };
}
