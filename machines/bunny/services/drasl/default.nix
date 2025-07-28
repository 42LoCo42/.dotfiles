{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.drasl = {
    cmd = [
      (lib.getExe (pkgs.writeShellApplication {
        name = "drasl";
        runtimeInputs = with pkgs; [ envsubst drasl ];
        text = builtins.readFile ./start.sh;
      }))
      "${./config.toml}"
    ];

    environmentFiles = [ (config.aquaris.secret "@machine/drasl") ];

    volumes = [ "drasl:/data" ];
  };
}
