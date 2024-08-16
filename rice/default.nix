{ self, lib, config, aquaris, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) anything;
in
{
  options.rice = mkOption {
    description = "Central place for various ricing options";
    type = anything;
  };

  config.rice = {
    disk-path = config.aquaris.persist.root;
    wallpaper = "${self}/machines/${aquaris.name}/wallpaper.png";
  };

  imports = aquaris.lib.importDir' { dirs = false; } ./.;
}
