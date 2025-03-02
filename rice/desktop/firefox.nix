{ lib, config, ... }: {
  options.rice.desktop.firefox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.firefox.enable {
    home-manager.sharedModules = [{
      aquaris.firefox = {
        enable = true;

        # TODO upstream this to Aquaris
        policies = {
          Certificates.Install = lib.mkIf
            (config.rice.dns.local-doh.enable)
            [ config.rice.dns.local-doh.crt ];

          DNSOverHTTPS = {
            Locked = true;
            Fallback = false;

            ExcludedDomains = lib.pipe config.rice.dns.rules [
              (x: x.cloaking // x.forwarding)
              (builtins.attrNames)
            ];
          } //
          (if config.rice.dns.enable then
            (if config.rice.dns.local-doh.enable then {
              Enabled = true;
              ProviderURL = "https://localhost:5353/dns-query";
            } else { Enabled = false; })
          else { Enabled = true; });
        };
      };
    }];
  };
}
