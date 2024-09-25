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

      glfw3-minecraft =
        let
          fixes = pkgs.fetchFromGitHub {
            owner = "BoyOrigin";
            repo = "glfw-wayland";
            rev = "2024-03-07";
            hash = "sha256-kvWP34rOD4HSTvnKb33nvVquTGZoqP8/l+8XQ0h3b7Y=";
          };
        in
        pkgs.glfw3-minecraft.overrideAttrs (old: {
          patches = old.patches ++ [
            "${fixes}/patches/0001-Key-Modifiers-Fix.patch"
            "${fixes}/patches/0002-Fix-duplicate-pointer-scroll-events.patch"
            # "${fixes}/patches/0003-Implement-glfwSetCursorPosWayland.patch"
            "${fixes}/patches/0004-Fix-Window-size-on-unset-fullscreen.patch"
            "${fixes}/patches/0005-Avoid-error-on-startup.patch"
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
