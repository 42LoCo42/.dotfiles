{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
  nixpkgs.overlays = [
    (_: pkgs: {
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
    })
  ];

  home-manager.sharedModules = [{
    home.packages = with pkgs; [ prismlauncher ];
    aquaris.persist = [ ".local/share/PrismLauncher" ];
  }];
}
