{ config, pkgs, ... }: {
  rice = {
    caddy.cfg."matrix-rtc" = ''
      @jwt_service {
        path /sfu/get* /healthz* /get_token*
      }

      handle @jwt_service {
        reverse_proxy livekit:8080
      }

      reverse_proxy livekit:7880 {
        header_up Connection "upgrade"
        header_up Upgrade {http.request.header.Upgrade}
      }
    '';

    oci-firewall.rules = [
      { desc = "Matrix RTC"; type = "tcp"; port = 7881; }
      { desc = "Matrix RTC"; type = "udp"; min = 50100; max = 50200; }

      { desc = "Matrix TURN"; type = "udp"; port = 3478; }
      { desc = "Matrix TURN"; type = "udp"; min = 50300; max = 65535; }
    ];
  };

  virtualisation.pnoc.livekit = {
    path = with pkgs; [
      envsubst
      livekit
      lk-jwt-service
    ];

    script = ''
      lk-jwt-service &

      # shellcheck disable=SC2153
      export LIVEKIT_KEYS="$LIVEKIT_KEY: $LIVEKIT_SECRET"

      envsubst < ${./config.yaml} > /tmp/config.yaml
      exec livekit-server --config /tmp/config.yaml
    '';

    environment = {
      DOMAIN = config.rice.domain;

      LIVEKIT_JWT_BIND = ":8080";
      LIVEKIT_URL = "wss://matrix-rtc.${config.rice.domain}";
      LIVEKIT_FULL_ACCESS_HOMESERVERS = config.rice.domain;
    };

    environmentFiles = [ (config.aquaris.secret "@machine/livekit") ];

    ports = [
      "7881:7881"
      "3478:3478/udp"
      "50100-50200:50100-50200/udp" # WebRTC
      "50300-65535:50300-65535/udp" # TURN
    ];
  };
}
