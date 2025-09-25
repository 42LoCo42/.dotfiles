{ pkgs, config, ... }: {
  virtualisation.pnoc.papra = {
    path = with pkgs; [
      envsubst
      papra
    ];

    script = ''
      envsubst < ${./config.yaml} > /tmp/papra.config.yaml
      export PAPRA_CONFIG_DIR=/tmp
      exec papra
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/papra") ];

    volumes = [ "papra:/data" ];
  };
}
