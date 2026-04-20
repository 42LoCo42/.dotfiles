{ pkgs, config, ... }: {
  rice.caddy.cfg."matrix-rtc" = ''
    @jwt_service {
      path /sfu/get* /healthz* /get_token*
    }

    handle @jwt_service {
      reverse_proxy lk-jwt-service:8080
    }

    reverse_proxy livekit:7880 {
      header_up Connection "upgrade"
      header_up Upgrade {http.request.header.Upgrade}
    }
  '';

  networking.firewall = {
    allowedTCPPorts = [ 7881 ];
    allowedUDPPorts = [ 3478 ];
    allowedUDPPortRanges = [
      { from = 50100; to = 50200; } # WebRTC
      { from = 50300; to = 65535; } # TURN
    ];
  };

  virtualisation.pnoc = {
    livekit = {
      path = with pkgs; [ envsubst livekit ];

      script = ''
        # shellcheck disable=SC2153
        export LIVEKIT_KEYS="$LIVEKIT_KEY: $LIVEKIT_SECRET"

        envsubst < ${./config.yaml} > /tmp/config.yaml
        exec livekit-server --config /tmp/config.yaml
      '';

      environment.DOMAIN = config.rice.domain;
      environmentFiles = [ (config.aquaris.secret "@machine/livekit") ];

      ports = [
        "7881:7881"
        "3478:3478/udp"
        "50100-50200:50100-50200/udp" # WebRTC
        "50300-65535:50300-65535/udp" # TURN
      ];
    };

    lk-jwt-service = {
      path = with pkgs; [ lk-jwt-service ];
      script = "exec lk-jwt-service";

      environment = {
        LIVEKIT_JWT_BIND = ":8080";
        LIVEKIT_URL = "wss://matrix-rtc.${config.rice.domain}";
        LIVEKIT_FULL_ACCESS_HOMESERVERS = config.rice.domain;
      };

      environmentFiles = [ (config.aquaris.secret "@machine/livekit") ];
    };
  };
}
