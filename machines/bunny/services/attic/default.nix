{ pkgs, config, ... }: {
  rice.caddy = {
    cfg = {
      attic = ''
        import default
        reverse_proxy attic:8080
      '';

      attic-default = ''
        import default
        reverse_proxy {
          to attic:8080
          rewrite /default{path}
        }
      '';
    };
  };

  virtualisation.pnoc.attic = {
    path = with pkgs; [ attic-server ];

    script = "exec atticd";

    environmentFiles = [ (config.aquaris.secret "@machine/attic") ];

    volumes = [
      "attic:/data"
      "${config.rice.subsDomain ./config.toml}:/.config/attic/server.toml:ro"
    ];
  };
}
