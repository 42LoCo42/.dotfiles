{ pkgs, ... }: {
  virtualisation.pnoc.hydroxide = {
    path = with pkgs; [ hydroxide ];
    script = ''
      exec hydroxide       \
        -debug             \
        -smtp-host 0.0.0.0 \
        -imap-host 0.0.0.0 \
        -disable-carddav   \
        serve
    '';

    environment.XDG_CONFIG_HOME = "/";

    ports = [
      "1025:1025"
      "1143:1143"
    ];

    volumes = [
      "hydroxide:/hydroxide"
    ];
  };
}
