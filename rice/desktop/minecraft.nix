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
          jdks = with pkgs; [
            # jdk8 # TODO currently broken
            jdk17
            jdk21
          ];
        })
      ];
      aquaris.persist = { ".local/share/PrismLauncher" = { }; };
    }];
  };
}
