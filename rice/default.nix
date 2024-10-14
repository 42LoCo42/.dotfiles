{ self, lib, config, aquaris, ... }:
let
  inherit (lib) flatten mapAttrsToList mkOption pipe remove;
  inherit (lib.types) anything;

  allNix =
    let
      helper = dir: pipe dir [
        builtins.readDir
        (mapAttrsToList (name: type:
          if type == "directory"
          then helper "${dir}/${name}"
          else if builtins.match ".*\.nix" name != null
          then [ "${dir}/${name}" ]
          else [ ]))
        flatten
      ];
    in
    dir: pipe dir [
      helper
      (remove "${dir}/default.nix")
    ];
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

  imports = allNix ./.;
}
