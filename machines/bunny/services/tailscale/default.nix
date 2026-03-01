{ pkgs, lib, config, ... }:
let
  inherit (lib) escapeShellArgs;

  cfg = config.services.tailscale;
in
{
  rice.tailscale.enable = true;

  services.tailscale = {
    extraUpFlags = [
      "--accept-dns=false"
      "--advertise-exit-node"
      "--hostname=exit"
      "--login-server=https://headscale.${config.rice.domain}"
    ];
  };

  systemd.services.tailscaled-autoconnect = {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "notify";
      Restart = "on-failure";
    };

    path = [
      cfg.package
      pkgs.jq
    ];

    enableStrictShellChecks = true;

    script = ''
      getState() {
        tailscale status --json --peers=false | jq -r '.BackendState'
      }

      lastState=""
      while state="$(getState)"; do
        if [[ "$state" != "$lastState" ]]; then
          # https://github.com/tailscale/tailscale/blob/v1.72.1/ipn/backend.go#L24-L32
          case "$state" in
            NeedsLogin|NeedsMachineAuth|Stopped)
              echo "Server needs authentication, sending auth key"
              tailscale up \
                --auth-key "file:${config.aquaris.secret "@machine/tailscale"}" \
                ${escapeShellArgs cfg.extraUpFlags} --reset
              ;;
            Running)
              echo "Tailscale is running"
              systemd-notify --ready
              exit 0
              ;;
            *)
              echo "Waiting for Tailscale State = Running or systemd timeout"
              ;;
          esac
          echo "State = $state"
        fi
        lastState="$state"
        sleep .5
      done
    '';
  };
}
