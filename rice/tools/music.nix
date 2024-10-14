{
  home-manager.sharedModules = [
    (hm: {
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
        settings.startup_screen = "media_library";
      };
    })
  ];
}
