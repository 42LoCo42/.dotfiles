{ self, lib, aquaris, ... }:
let
  inherit (lib) flip getExe pipe;
in
{
  nixpkgs.overlays = [
    (_: pkgs: {
      flameshot = pkgs.writeShellApplication {
        name = "flameshot";
        text = ''
          export XDG_CURRENT_DESKTOP=sway
          ${getExe pkgs.flameshot} gui -r | wl-copy
        '';
      };

      foot = self.inputs.obscura.packages.${pkgs.system}.foot-transparent;

      glfw3-minecraft = pkgs.glfw3-minecraft.overrideAttrs (old: {
        patches = old.patches ++ [
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/BoyOrigin/glfw-wayland/f62b4ae8f93149fd754cadecd51d8b1a07d20522/patches/0005-Avoid-error-on-startup.patch";
            hash = "sha256-oF+mTNOXPq/yr+y58tTeRkLJE67QzJJSleKFZ85+Uys=";
          })
        ];
      });

      mypaint = pkgs.mypaint.overrideAttrs { installCheckPhase = ""; };

      nerdfonts = pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; };

      vesktop = pkgs.vesktop.override {
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
