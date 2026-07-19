{ config, lib, pkgs, self, ... }: {
  options.rice.desktop.mpd.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.mpd.enable {
    home-manager.sharedModules = lib.singleton (hm: {
      imports = map (x: "${self.inputs.home-manager}/modules/${x}") [
        "programs/ncmpcpp.nix"
        "services/mpd.nix"
      ];

      aquaris.persist = { "music" = { }; };

      home.packages = with pkgs; [
        ffmpeg # conversions, ffprobe, ...
        kid3-cli # setting tags manually
        moreutils # vidir the GOAT
      ];

      services.mpd = {
        enable = true;
        musicDirectory = "${hm.config.home.homeDirectory}/music";
        extraConfig = ''
          audio_output {
            type "pulse"
            name "pulse"
          }
        '';
      };

      programs.ncmpcpp = {
        enable = true;
        settings = {
          lyrics_directory = "~/.local/share/lyrics";
          media_library_albums_split_by_date = "no";
          media_library_primary_tag = "album_artist";
          startup_screen = "media_library";
        };
      };
    });
  };
}
