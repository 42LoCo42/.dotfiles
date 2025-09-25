{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) flip getExe pipe remove;

  ncps-caches = pipe config.nix.settings [
    (x: with x; with config.rice.use-ncps; {
      urls = { val = substituters; rem = url; };
      keys = { val = trusted-public-keys; rem = key; };
    })
    (builtins.mapAttrs (_: flip pipe [
      (x: remove x.rem x.val)
      (builtins.concatStringsSep ",")
    ]))
  ];
in
{
  topology.self.services.ncps = {
    name = "ncps";
    icon = "misc.package";
    info = "Nix Cache Proxy Server";
    details.url.text = "https://laniakea.fritz.box:8501";
  };

  virtualisation.pnoc.ncps = {
    cmd = [ (getExe pkgs.ncps-db-helper) "serve" ];

    environment = {
      CACHE_DATA_PATH = "/data";
      CACHE_HOSTNAME = aquaris.name;
      CACHE_LRU_SCHEDULE = "0 0 * * *";
      CACHE_MAX_SIZE = "250G";
      CACHE_SECRET_KEY_PATH = "/key";

      UPSTREAM_CACHES = ncps-caches.urls;
      UPSTREAM_PUBLIC_KEYS = ncps-caches.keys;
    };


    secrets = [ "@machine/ncps:/key" ];

    volumes = [ "ncps:/data" ];
  };
}
