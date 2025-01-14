{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.authelia = {
    cmd = [ (lib.getExe pkgs.authelia) "-c" "${config.rice.subsDomain ./config.yaml}" ];
    environmentFiles = [ config.aquaris.secrets."machine/authelia" ];
    ssl = true;
    volumes = [ "authelia:/data" ];
  };
}
