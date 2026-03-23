{
  topology.self = {
    deviceIcon = "devices.nixos";
    hardware.info = "Server of Ercanar";

    interfaces."enp2s0" = {
      addresses = [ "192.168.178.60" ];

      network = "lan";
      physicalConnections = [{
        node = "fritzbox";
        interface = "lan";
      }];
    };
  };
}
