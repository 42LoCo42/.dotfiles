{ lib, config, ... }: {
  options.rice.desktop.firefox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.firefox.enable {
    home-manager.sharedModules = [
      ({ config, osConfig, ... }: {
        aquaris.firefox = {
          enable = true;

          policies = {
            DNSOverHTTPS = lib.mkIf osConfig.rice.dns.enable {
              Enabled = false; # use local dnscrypt-proxy
              Locked = true;
            };
          };
        };
      })
    ];
  };
}
