{ pkgs, lib, aquaris, ... }: {
  networking.firewall = {
    allowedTCPPorts = [
      21115
      21116
      21117
      21118
      21119
    ];

    allowedUDPPorts = [ 21116 ];
  };

  virtualisation.pnoc.rustdesk =
    let
      pubkey = "Dh0lsYDLdL7GIb0BHWR2VS0mRCLSmyKIJHdtkzmWjdQ=";

      app = pkgs.writeShellApplication {
        name = "rustdesk";
        text = aquaris.lib.subsT ./start.sh { inherit pubkey; };
        runtimeInputs = with pkgs; [ rustdesk-server ];
      };
    in
    {
      cmd = [ (lib.getExe app) ];

      ports = [
        "21115:21115"
        "21116:21116"
        "21116:21116/udp"
        "21117:21117"
        "21118:21118"
        "21119:21119"
      ];

      secrets = [ "@machine/rustdesk:/data/id_ed25519" ];

      volumes = [ "rustdesk:/data" ];

      workdir = "/data";
    };
}
