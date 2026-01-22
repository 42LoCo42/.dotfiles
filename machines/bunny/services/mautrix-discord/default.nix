{ pkgs, config, ... }: {
  rice = {
    insecureNames = [ "olm" ];

    caddy.cfg.mautrix-discord = ''
      reverse_proxy mautrix-discord:8080
    '';
  };

  virtualisation.pnoc.mautrix-discord = {
    path = with pkgs; [
      envsubst
      ffmpeg-headless # for converting animated stickers
      mautrix-discord
    ];

    script = ''
      envsubst < ${config.rice.subsDomain ./config.yaml} > /tmp/config.yaml
      exec mautrix-discord -c /tmp/config.yaml
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/mautrix-discord") ];
  };
}
