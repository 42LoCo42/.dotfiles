{ lib, config, ... }: lib.mkIf config.rice.desktop {
  home-manager.sharedModules = [
    (hm: {
      aquaris.persist = [ "music" ];

      services.mpd = {
        enable = true;
        musicDirectory = "${hm.config.home.homeDirectory}/music";
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "pipewire"
          }
        '';
      };

      programs.ncmpcpp = {
        enable = true;
        settings = {
          lyrics_directory = "~/.local/share/lyrics";
          startup_screen = "media_library";
        };
      };
    })
  ];
}
