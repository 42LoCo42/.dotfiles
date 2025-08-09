{ pkgs, lib, config, ... }: {
  options.rice.printer.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.printer.enable {
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      disabledDefaultBackends = [ "escl" ];
      openFirewall = true;
    };

    services = {
      udev.packages = [ pkgs.sane-airscan ];

      avahi = {
        enable = true;
        openFirewall = true;
      };

      printing = {
        enable = true;

        drivers = with pkgs; [
          cups-browsed
          cups-filters
        ];
      };
    };

    aquaris.dnscrypt.rules.forwarding = {
      ${config.services.avahi.domainName} = "0.0.0.0:5354";
    };

    systemd.services.avahi-proxy = {
      serviceConfig.ExecStart = builtins.concatStringsSep " " [
        "${lib.getExe pkgs.avahi-proxy} run"
        "--baseDomain ${config.services.avahi.domainName}"
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users.users = builtins.mapAttrs
      (_: _: { extraGroups = [ "lp" "scanner" ]; })
      config.aquaris.users;
  };
}
