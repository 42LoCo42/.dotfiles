{ pkgs, lib, ... }: {
  virtualisation.pnoc.immich-public-proxy = {
    cmd = [ (lib.getExe pkgs.immich-public-proxy) ];

    environment = {
      IPP_PORT = "8080";
      IPP_CONFIG = "${./config.json}";

      IMMICH_URL = "http://immich:8080";
    };
  };
}
