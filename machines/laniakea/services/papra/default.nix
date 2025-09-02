{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.papra = {
    cmd = [
      (lib.getExe (pkgs.writeShellApplication {
        name = "papra";
        runtimeInputs = with pkgs; [ envsubst papra ];
        text = ''
          envsubst < ${./config.yaml} > /tmp/papra.config.yaml
          export PAPRA_CONFIG_DIR=/tmp
          exec papra
        '';
      }))
    ];

    environmentFiles = [ (config.aquaris.secret "@machine/papra") ];

    volumes = [ "papra:/data" ];
  };
}
