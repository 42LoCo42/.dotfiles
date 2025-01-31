{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.firefox-sync = {
    cmd = [ (lib.getExe pkgs.syncstorage-rs) "--config" "${./config.toml}" ];
    environmentFiles = [ (config.aquaris.secret "machine/firefox-sync") ];
  };
}
