{ pkgs, config, lib, ... }: {
  options.rice.desktop.mail = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.rice.desktop.mail.enable {
    home-manager.sharedModules = [{
      aquaris.persist = {
        ".cache/thunderbird" = { };
        ".thunderbird" = { };
      };

      home.packages = with pkgs; [ thunderbird ];
    }];
  };
}
