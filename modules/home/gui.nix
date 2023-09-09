{ self, pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      nerdfonts
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaNerdFont" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  environment.variables.GTK_THEME = "Adwaita:dark";

  services.dbus.packages = [ pkgs.gcr ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  home-manager.users.default = { config, ... }: {
    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "Adwaita-Dark";
    };

    home.packages = with pkgs; [
      grim
      keepassxc
      libnotify
      self.inputs.obscura.packages.${system}.flameshot-fixed
      tor-browser-bundle-bin
      xdg_utils
    ];

    xdg = {
      enable = true;
      userDirs.enable = true;
      userDirs.music = "${config.home.homeDirectory}/music";
    };

    services = {
      emacs.enable = true;

      mpd = {
        enable = true;
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "pipewire"
          }
        '';
      };

      gpg-agent = {
        enable = true;
        pinentryFlavor = "gnome3";
      };
    };

    programs = {
      emacs = {
        enable = true;
        package = pkgs.emacs29-pgtk;
      };

      feh.enable = true;
      firefox.enable = true;
      mpv.enable = true;
      yt-dlp.enable = true;
      zathura.enable = true;
    };
  };
}
