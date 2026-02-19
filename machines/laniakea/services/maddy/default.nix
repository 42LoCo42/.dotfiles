{ pkgs, ... }: {
  virtualisation.pnoc.maddy = {
    path = with pkgs; [ maddy ];
    script = "exec maddy run";

    extraOptions = [ "--tmpfs=/run/maddy" ];

    ports = [ "143:1143" ];

    volumes = [
      "maddy:/data"
      "${./maddy.conf}:/etc/maddy/maddy.conf:ro"
    ];
  };
}
