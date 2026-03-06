{ pkgs, config, ... }:
let
  inherit (config.rice) domain;

  volumes = "/var/lib/containers/storage/volumes";
  certs = "caddy/_data/data/caddy/certificates/acme-v02.api.letsencrypt.org-directory";

  crt = "${volumes}/${certs}/turn.${domain}/turn.${domain}.crt";
  key = "${volumes}/${certs}/turn.${domain}/turn.${domain}.key";
in
{
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

  virtualisation.pnoc.coturn = {
    path = with pkgs; [ envsubst coturn ];

    script = ''
      # shellcheck disable=SC2016
      envsubst <<< 'static-auth-secret=$SECRET' > /tmp/coturn.conf

      exec turnserver          \
        --realm turn.${domain} \
        --listening-ip 0.0.0.0 \
        --listening-ip ::      \
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
