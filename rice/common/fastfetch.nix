{ pkgs, ... }: {
  home-manager.sharedModules = [{
    programs.fastfetch = {
      enable = true;

      package = pkgs.fastfetch.override {
        zfsSupport = true;
      };

      settings = {
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "wm"
          "theme"
          "cursor"
          "terminal"
          "cpu"
          "gpu"
          "memory"
          "swap"
          {
            type = "disk";
            folders = [
              "/"
              "/boot"
            ];
            hideFolders = [ ];
          }
          "zpool"
          "localip"
          "battery"
          "poweradapter"
          "locale"
          "break"
          "colors"
        ];
      };
    };
  }];
}
