{ self, pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) flip getExe mkOption pipe;
  inherit (lib.types) anything;
in
{
  imports = [
    ./hyprland.nix
    ./misc.nix
    {
      options.rice = mkOption {
        description = "Central place for various ricing options";
        type = anything;
      };

      config.rice = {
        disk-path = config.aquaris.persist.root;
        wallpaper = "${self}/machines/${aquaris.name}/wallpaper.png";
      };
    }
  ];

  nixpkgs.overlays = [
    (_: prev: {
      flameshot = prev.runCommand "flameshot"
        { nativeBuildInputs = with prev; [ makeBinaryWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper                \
          ${getExe prev.flameshot} \
          $out/bin/flameshot       \
          --set XDG_CURRENT_DESKTOP sway
      '';

      foot = self.inputs.obscura.packages.${pkgs.system}.foot-transparent;
      nerdfonts = prev.nerdfonts.override { fonts = [ "Iosevka" ]; };
      vesktop = prev.vesktop.override {
        withSystemVencord = false;
        withTTS = false;
      };

      ##### custom scripts #####

      alarm = pipe ./misc/alarm.sh [
        (flip aquaris.lib.subsT { bell = "${./misc/bell.mp3}"; })
        (pkgs.writeShellScriptBin "alarm")
      ];

      hrtrack =
        let
          src = builtins.readFile ./misc/hrtrack.sh;
          bin = pkgs.writeShellScriptBin "hrtrack" src;
          app = pkgs.makeDesktopItem {
            name = "hrtrack";
            desktopName = "HRTrack";
            icon = "${./misc/hrtrack.png}";
            exec = "${getExe bin}";
            terminal = false;
          };
        in
        pkgs.symlinkJoin {
          name = "hrtrack";
          paths = [ bin app ];
        };
    })
  ];
}
