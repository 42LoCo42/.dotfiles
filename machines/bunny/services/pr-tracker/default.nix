{ pkgs, lib, ... }: {
  topology.nodes.bunny-private.services.pr-tracker = {
    name = "Nixpkgs Pull Request Tracker";
    icon = "devices.nixos";
    info = "A selfhosted version of https://nixpk.gs/pr-tracker.html";
    details.url.text = "https://pr-tracker.bunny";
  };

  virtualisation.pnoc.pr-tracker = {
    path = with pkgs; [
      git
      pr-tracker
      systemdMinimal
    ];

    script = ''
      cd /data

      if [ ! -e nixpkgs ]; then
        git clone https://github.com/nixos/nixpkgs --no-checkout
      fi

      exec ${lib.getExe pkgs.docker.docker-tini} -- \
      systemd-socket-activate                       \
        -l 0.0.0.0:8080                             \
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
