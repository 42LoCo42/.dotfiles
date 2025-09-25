{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.forgejo = {
    path = with pkgs; [
      bash
      coreutils
      forgejo
      tini
    ];

    script = ''
      environment-to-ini --config ${./config.ini} --out /tmp/config.ini
      chmod 400 /tmp/config.ini
      exec tini -- gitea --config /tmp/config.ini
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/forgejo") ];

    volumes = [
      "forgejo:/data"

      # fix repo hooks
      "${lib.getExe' pkgs.coreutils "env"}:/usr/bin/env:ro"
    ];
  };
}
