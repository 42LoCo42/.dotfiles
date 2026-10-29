{ lib, pkgs, ... }: {
  topology.nodes.bunny-private.services.syncthing = {
    name = "Syncthing";
    icon = "services.syncthing";
    info = "Central file synchronization hub";
    details.url.text = "https://sync.bunny";
  };

  rice.oci-firewall.rules = [
    { desc = "Syncthing TCP"; type = "tcp"; port = 22000; }
    { desc = "Syncthing UDP"; type = "udp"; port = 22000; }
  ];

  virtualisation.pnoc.syncthing = {
    cmd = [ (lib.getExe pkgs.syncthing) "--home=/data" "--gui-address=http://0.0.0.0:8080" ];
    environment.HOME = "/sync";
    ports = [
      "22000:22000"
      "22000:22000/udp"
    ];
    volumes = [
      "syncthing:/data"
      "/persist/sync:/sync"
    ];
  };
}
