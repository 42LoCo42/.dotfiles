{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      feh
      mpv
      yt-dlp
      zathura
    ];

    services.ssh-agent.enable = true;

    # haskek my beloved <3
    home.file.".ghci".text = ''
      :set -Wall
      :set -Wno-type-defaults
      :set prompt "[1;35mλ>[m "
    '';
  }];
}
