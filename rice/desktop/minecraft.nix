{ pkgs, lib, config, ... }: {
  options.rice.desktop.minecraft.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.minecraft.enable {
    home-manager.sharedModules = [{
      home.packages = with pkgs; [
        (prismlauncher.override {
          glfw3-minecraft = pkgs.glfw3-minecraft-extra;
        })
      ];
      aquaris.persist = { ".local/share/PrismLauncher" = { }; };
    }];
  };
}
