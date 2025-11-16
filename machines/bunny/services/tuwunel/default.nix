{ pkgs, config, ... }: {
  topology.nodes.bunny-public.services.tuwunel = {
    name = "Tuwunel";
    icon = "services.matrix";
    info = "Matrix homeserver";
    details.url.text = "https://matrix.${config.rice.domain}";
  };

  rice.caddy.cfg = {
    "" = ''
      reverse_proxy /.well-known/matrix/* tuwunel:8080
    '';

    "matrix.{$DOMAIN}, matrix.{$DOMAIN}:8448" = ''
      import default

      # https://github.com/matrix-construct/tuwunel/blob/v1.4.6/src/api/router.rs#L268
      @legacy_media {
        path /_matrix/media/v1/*
        path /_matrix/media/v3/config
        path /_matrix/media/v3/download/*
        path /_matrix/media/v3/preview_url
        path /_matrix/media/r0/config
        path /_matrix/media/r0/download/*
        path /_matrix/media/r0/preview_url

        # allow thumbnail requests for matrix.to profile previews
        # path /_matrix/media/v3/thumbnail/*
        # path /_matrix/media/r0/thumbnail/*
      }

      respond @legacy_media <<JSON
      {"errcode":"M_FORBIDDEN","error":"M_FORBIDDEN: Unauthenticated media is disabled."}
      JSON 403

      reverse_proxy tuwunel:8080
    '';
  };

  networking.firewall.allowedTCPPorts = [ 8448 ];

  virtualisation.pnoc = {
    caddy.ports = [ "8448:8448" ];

    tuwunel = {
      path = with pkgs; [
        envsubst
        matrix-tuwunel
      ];

      script = ''
        envsubst < ${config.rice.subsDomain ./config.toml} > /tmp/config.toml
        exec tuwunel -c /tmp/config.toml
      '';

      environmentFiles = [ (config.aquaris.secret "@machine/tuwunel") ];

      volumes = [ "tuwunel:/data" ];
    };
  };
}
