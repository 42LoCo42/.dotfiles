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
      resources = "${pkgs.rustdesk-api}/resources";

      app = pkgs.writeShellApplication {
        name = "rustdesk";

        runtimeInputs = with pkgs; [
          coreutils
          rustdesk-server
          rustdesk-api
        ];

        text = aquaris.lib.subsT ./start.sh {
          inherit pubkey resources;

          config = pkgs.writeText "config.yaml" ''
            lang: en
            app:
              token-expire: 24h
            gin:
              mode: release
              api-addr: 0.0.0.0:21114
              resources-path: ${resources}
          '';
        };
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
