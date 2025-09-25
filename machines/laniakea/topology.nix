{
  topology.self = {
    deviceIcon = "misc.hardkernel";
    hardware.info = "ODROID-M1 homeserver";

    interfaces."end0" = {
      addresses = [ "192.168.178.41" ];

      network = "lan";
      physicalConnections = [{
        node = "fritzbox";
        interface = "lan";
      }];
    };
  };
}
