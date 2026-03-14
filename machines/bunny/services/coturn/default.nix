{ pkgs, config, ... }:
let
  inherit (config.rice) domain;

  volumes = "/var/lib/containers/storage/volumes";
  certs = "caddy/_data/data/caddy/certificates/acme-v02.api.letsencrypt.org-directory";

  crt = "${volumes}/${certs}/turn.${domain}/turn.${domain}.crt";
  key = "${volumes}/${certs}/turn.${domain}/turn.${domain}.key";
in
{
  topology.nodes.bunny-public.services.coturn = {
    name = "Coturn";
    icon = "misc.phone";
    info = "TURN & STUN server";
    details.url.text = "turn.eleonora.gay:5349";
  };

  rice.caddy.cfg."turn" = "abort";

  systemd = {
    paths."coturn-cert" = {
      pathConfig = {
        PathModified = [ crt key ];
      };

      wantedBy = [ "default.target" ];
    };

    services."coturn-cert" = {
      serviceConfig = {
        Type = "oneshot";

        ExecStart = [
          "${pkgs.coreutils}/bin/install -o coturn ${crt} ${volumes}/coturn/_data/turn.crt"
          "${pkgs.coreutils}/bin/install -o coturn ${key} ${volumes}/coturn/_data/turn.key"
          "systemctl restart podman-coturn"
        ];
      };
    };
  };

  networking.firewall.allowedUDPPortRanges = [{ from = 50201; to = 65535; }];

  virtualisation.pnoc.coturn = {
    path = with pkgs; [ coreutils coturn ];

    script = ''
      cat << EOF > /tmp/coturn.conf
      static-auth-secret=$MATRIX_SECRET
      static-auth-secret=$LIVEKIT_SECRET
      EOF

      exec turnserver          \
        --realm turn.${domain} \
        --listening-ip 0.0.0.0 \
        --listening-ip ::      \
        --min-port 50201       \
        --max-port 65535       \
        --cert /data/turn.crt  \
        --pkey /data/turn.key  \
        --use-auth-secret      \
        -c /tmp/coturn.conf
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/coturn") ];

    ports = [
      "5349:5349"
      "5349:5349/udp"
    ];

    volumes = [ "coturn:/data" ];
  };
}
