{ config, ... }: {
  rice.tailscale.enable = true;

  services.tailscale = {
    authKeyFile = config.aquaris.secret "@machine/tailscale";
    extraUpFlags = [
      "--accept-dns=false"
      "--advertise-exit-node"
      "--hostname=exit"
      "--login-server=https://headscale.${config.rice.domain}"
    ];
  };
}
