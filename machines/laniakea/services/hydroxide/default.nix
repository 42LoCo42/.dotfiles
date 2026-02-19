{ pkgs, ... }: {
  virtualisation.pnoc.hydroxide = {
    path = with pkgs; [ hydroxide ];
    script = "exec hydroxide -imap-host 0.0.0.0 imap";

    environment.XDG_CONFIG_HOME = "/";

    volumes = [
      "hydroxide:/hydroxide"
    ];
  };
}
