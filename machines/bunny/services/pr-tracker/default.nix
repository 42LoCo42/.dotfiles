{ pkgs, config, lib, ... }: {
  topology.nodes.bunny-public.services.pr-tracker = {
    name = "Nixpkgs Pull Request Tracker";
    icon = "devices.nixos";
    info = "A selfhosted version of https://nixpk.gs/pr-tracker.html";
    details.url.text = "https://pr-tracker.${config.rice.domain}";
  };

  rice.caddy.cfg.pr-tracker = ''
    import default
    reverse_proxy pr-tracker:8080 {
      header_up X-Real-IP {remote_host}
    }
  '';

  virtualisation.pnoc.pr-tracker = {
    path = with pkgs; [
      coreutils # sleep
      git
      pr-tracker
      systemdMinimal
    ];

    script = ''
      ${config.rice.anubis}

      cd /data

      if [ ! -e nixpkgs ]; then
        git clone https://github.com/nixos/nixpkgs --no-checkout
      fi

      (
        cd nixpkgs
        while true; do
          git fetch
          sleep 1h
        done
      ) &

      exec ${lib.getExe pkgs.docker.docker-tini} -- \
      systemd-socket-activate                       \
        -l 0.0.0.0:8081                             \
        pr-tracker                                  \
          --path       'nixpkgs'                    \
          --remote     'origin'                     \
          --source-url '${pkgs.pr-tracker.src.url}' \
          --user-agent 'pr-tracker (nori)'          \
        < /token
    '';

    secrets = [ "@machine/pr-tracker:/token" ];

    volumes = [ "pr-tracker:/data" ];
  };
}
