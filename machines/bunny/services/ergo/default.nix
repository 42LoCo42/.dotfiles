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
in
{
  networking.firewall.allowedTCPPorts = [ 6697 ];

  rice.caddy.cfg."irc" = ''
    reverse_proxy ergo:8080
  '';

  virtualisation.pnoc.ergo = {
    path = with pkgs; [
      ergochat
      openssl

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
