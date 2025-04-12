{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.forgejo = {
    cmd = [
      (lib.getExe (pkgs.writeShellApplication {
        name = "forgejo";
        runtimeInputs = with pkgs; [
          bash
          coreutils
          forgejo
        ];
        text = builtins.readFile ./start.sh;
      }))
      "${./config.ini}"
    ];

    environmentFiles = [ (config.aquaris.secret "@machine/forgejo") ];

    extraOptions = [ "--tmpfs=/tmp" ];

    volumes = [
      "forgejo:/data"

      # fix repo hooks
      "${lib.getExe' pkgs.coreutils "env"}:/usr/bin/env:ro"
    ];
  };
}
