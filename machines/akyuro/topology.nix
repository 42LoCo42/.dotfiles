{
  topology.self = {
    deviceIcon = "devices.laptop";
    hardware.info = "Laptop";

    interfaces."wlp2s0" = {
      addresses = [ "192.168.178.35" ];

      network = "lan";
      physicalConnections = [{
        node = "fritzbox";
        interface = "lan";
      }];
    };
  };
}
