{ pkgs, lib, config, ... }: {
  options.rice.printer.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.printer.enable {
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      openFirewall = true;
    };

    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      printing.enable = true;
    };

    users.users = builtins.mapAttrs
      (_: _: { extraGroups = [ "lp" "scanner" ]; })
      config.aquaris.users;
  };
}
