{ pkgs, config, ... }: {
  rice.caddy.cfg.emailproxy = ''
    import default
    reverse_proxy email-oauth2-proxy:8080
  '';

  virtualisation.pnoc.email-oauth2-proxy = {
    path = with pkgs; [
      email-oauth2-proxy
      envsubst
    ];

    script = ''
      umask 0077
      envsubst                   \
        < ${./emailproxy.config} \
        > /tmp/emailproxy.config

      exec emailproxy                        \
        --no-gui                             \
        --local-server-auth                  \
        --config-file /tmp/emailproxy.config \
        --cache-store /data/emailproxy.cache
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/email-oauth2-proxy") ];

    volumes = [ "email-oauth2-proxy:/data" ];
  };
}
