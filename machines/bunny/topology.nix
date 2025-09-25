{
  topology = {
    self = {
      deviceIcon = "misc.oracle";
      hardware.info = "Production server in the Oracle Cloud";

      interfaces."enp0s6" = {
        addresses = [
          "141.147.42.41"
          # "2603:c020:801a:e242:5acf:e04a:b565:7f83" # linebreaks don't render :/
        ];

        network = "internet";
        physicalConnections = [{
          node = "internet";
          interface = "*";
        }];
      };
    };

    nodes = {
      bunny-public = {
        name = "bunny - public services";
        parent = "bunny";
        deviceType = "nixos";
        deviceIcon = "misc.globe";
        guestType = "Reachable from anywhere";

        # interfaces."*" = {
        #   virtual = true;
        #   network = "internet";
        #   physicalConnections = [{
        #     node = "internet";
        #     interface = "*";
        #   }];
        # };
      };

      bunny-private = {
        name = "bunny - private services";
        parent = "bunny";
        deviceType = "nixos";
        deviceIcon = "misc.lock";
        guestType = "Only reachable from the VPN";

        interfaces."*" = {
          type = "wireguard";
          virtual = true;
          network = "vpn";
        };
      };
    };
  };
}
