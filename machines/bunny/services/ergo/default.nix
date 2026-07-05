{ pkgs, lib, config, ... }:
let
  inherit (lib) imap1 join pipe;

  hosts = pipe [
    "eleonora.gay"
    "irc.eleonora.gay"
    "localhost"
  ] [
    (imap1 (i: x: "DNS.${toString i}:${x}"))
    (join ",")
  ];

  gamja = pkgs.gamja.override {
    gamjaConfig = {
      server = {
        url = "wss://irc.${config.rice.domain}";
        auth = "oauth2";
        autoconnect = true;
      };

      oauth2 = {
        url = "https://id.${config.rice.domain}";
        client_id = "7b9d0ad3-76b4-48a4-a572-a0293955e29c";
        scope = "openid profile email offline_access";
      };
    };
  };
in
{
  topology.nodes.bunny-public.services.ergo = {
    name = "Ergo";
    icon = "misc.hash";
    info = "Modern IRC server";
    details.url.text = "https://irc.${config.rice.domain}";
  };

  networking.firewall.allowedTCPPorts = [ 6697 ];

  rice.caddy = {
    cfg."irc" = ''
      import default

      @websockets {
        header Connection *Upgrade*
        header Upgrade    websocket
      }

      reverse_proxy @websockets ergo:8080

      root * /srv/gamja
      file_server
    '';

    volumes = [ "${gamja}:/srv/gamja:ro" ];
  };

  virtualisation.pnoc.ergo = {
    path = with pkgs; [
      ergochat
      openssl
      python3

      # for administration
      catgirl
      (pkgs.writeShellApplication {
        name = "admin";
        text = ''
          exec catgirl         \
            -h localhost       \
            -t /ca.crt         \
            -n admin           \
            -c /data/admin.crt \
            -v
        '';
      })
    ];

    script = ''
      openssl req                               \
        -newkey ec                              \
        -pkeyopt ec_paramgen_curve:secp521r1    \
        -noenc                                  \
        -keyout /data/ergo.key                  \
        -x509                                   \
        -days 99999                             \
        -subj '/CN=me'                          \
        -config <(:)                            \
        -addext 'extendedKeyUsage = serverAuth' \
        -addext 'subjectAltName   = ${hosts}'   \
        -CA    /ca.crt                          \
        -CAkey /ca.key                          \
        -out /data/ergo.crt

      python ${./introspect.py} &
      exec ergo run --conf ${./config.yaml}
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/ergo") ];

    ports = [ "6697:6697" ];

    secrets = [ "svc/ca:/ca.key" ];

    volumes = [
      "ergo:/data"
      "${config.rice.ca.file}:/ca.crt:ro"
    ];
  };
}
