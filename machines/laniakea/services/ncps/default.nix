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

    # for some reason, /etc/passwd gets mode 600
    # if the container image is not read-only
    # otherwise, it gets 644
    # ncps tries to lookup its user here, so it needs read access
    extraOptions = [ "--read-only" ];

    secrets = [ "machine/ncps:/key" ];

    volumes = [ "ncps:/data" ];
  };
}
