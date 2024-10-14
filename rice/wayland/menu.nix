{ config, aquaris, ... }: {
  home-manager.sharedModules = [{
    xdg.configFile."fuzzel/fuzzel.ini".text = aquaris.lib.subsT ./files/fuzzel.ini {
      inherit (config.rice) fuzzel-font-size;
    };
  }];
}
