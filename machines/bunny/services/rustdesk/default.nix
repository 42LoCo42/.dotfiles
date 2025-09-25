{ pkgs, lib, config, ... }: {
  rice.caddy.cfg.rd = ''
    import default
    header Content-Type text/html
    respond <<HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta http-equiv='refresh' content='0; URL=https://{$DOMAIN}/foo/rustdesk--9JSPRRmaX1merRHZIpUSLlXbTx0QS1GMTZlMSdFSCBjYJd0NMRGTEl1csBDaEJiOikXZrJCLiIiOikGchJCLiIiOikXYsVmciwiI5F2ZuEmcv52blxWZiojI0N3boJye--.exe'>
      </head>
    </html>
    HTML 200
  '';

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
      apiconfig = pkgs.writeText "config.yaml" ''
        lang: en
        app:
          token-expire: 24h
        gin:
          mode: release
          api-addr: 0.0.0.0:21114
          resources-path: ${resources}
      '';
    in
    {
      path = with pkgs; [
        coreutils
        runit
        rustdesk-api
        rustdesk-server
      ];

      cmd = [
        (lib.getExe' pkgs.runit "runsvdir")
        (config.rice.mkRunit {
          api = ''
            cd /data

            # work around hardcoded bullshit
            mkdir -p data                  # DB
            ln -sfT ${resources} resources # web templates

            exec apimain -c ${apiconfig}
          '';

          hbbr = ''
            cd /data
            exec hbbr -k ${pubkey}
          '';

          hbbs = ''
            cd /data
            exec hbbs -k ${pubkey} -r localhost
          '';
        }).outPath
      ];

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
    };
}
