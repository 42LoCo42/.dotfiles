{ pkgs, lib, config, ... }: {
  options.rice.desktop.hrtrack.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.hrtrack.enable {
    environment.systemPackages = lib.pipe ./main.sh [
      builtins.readFile
      (pkgs.writeShellScriptBin "hrtrack")
      (x: x.overrideAttrs (old: {
        buildCommand = old.buildCommand + ''
          install -Dm444 ${./icon.png} $out/share/icons/hrtrack.png
        '';
      }))
      lib.singleton
    ];

    rice.desktop.wayland.hyprland.prepwr = "hrtrack";
  };
}
