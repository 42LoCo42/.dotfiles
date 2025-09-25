{
  topology.self = {
    deviceIcon = "devices.desktop";
    hardware.info = "Desktop";

    interfaces."enp6s0" = {
      addresses = [ "192.168.178.20" ];

      network = "lan";
      physicalConnections = [{
        node = "fritzbox";
        interface = "lan";
      }];
    };
  };
}
