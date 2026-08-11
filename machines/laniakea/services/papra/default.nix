{ config, pkgs, ... }: {
  topology.self.services.papra = {
    name = "Papra";
    icon = "services.papra";
    info = "Document archiving platform";
    details.url.text = "https://doc.laniakea";
  };

  virtualisation.pnoc.papra = {
    path = with pkgs; [
      envsubst
      papra
    ];

    script = ''
      envsubst < ${./config.yaml} > /tmp/papra.config.yaml

      export PAPRA_CONFIG_DIR=/tmp
      export SERVER_SERVE_PUBLIC_DIR=true

      papra-migrate-up
      exec papra
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/papra") ];

    volumes = [ "papra:/data" ];
  };
}
