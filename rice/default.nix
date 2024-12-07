{ self, lib, config, aquaris, ... }:
let
  inherit (aquaris.lib) importDir;
  inherit (lib) mkDefault mkOption pipe;
  inherit (lib.types) anything;
in
{
  options.rice = mkOption {
    description = "Central place for various ricing options";
    type = anything;
  };

  config.rice = {
    disk-path = config.aquaris.persist.root;
    wallpaper =
      let path = "${self}/machines/${aquaris.name}/wallpaper.png"; in
      if builtins.pathExists path then builtins.path { inherit path; } else null;

    desktop = mkDefault false;

    dns = mkDefault false;
    syncthing = mkDefault false;
    tailscale = mkDefault false;
  };

  imports = pipe [
    ./common # always enabled
    ./desktop # config.rice.desktop
    ./special # config.rice.<entry>
  ] [
    (map importDir)
    builtins.concatLists
  ];
}
