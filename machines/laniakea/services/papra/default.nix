{ pkgs, config, ... }: {
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
      tsx
    ];

    script = ''
      envsubst < ${./config.yaml} > /tmp/papra.config.yaml

      export NODE_PATH=${pkgs.papra}/lib/node_modules
      export PAPRA_CONFIG_DIR=/tmp
      export SERVER_SERVE_PUBLIC_DIR=true

      tsx ${pkgs.papra}/lib/src/scripts/migrate-up.script.ts
      exec papra
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/papra") ];

    volumes = [ "papra:/data" ];
  };
}
