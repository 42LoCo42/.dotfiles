{
  topology.self = {
    deviceIcon = "devices.desktop";
    hardware.info = "Desktop of Ercanar";

    interfaces."enp5s0" = {
      addresses = [ "192.168.178.21" ];

      network = "lan";
      physicalConnections = [{
        node = "fritzbox";
        interface = "lan";
      }];
    };
  };
}
