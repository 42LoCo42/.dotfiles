{ pkgs, config, ... }: {
  nix.package = pkgs.lib.mkForce pkgs.lix;

  security.pam = {
    services.sudo.u2fAuth = true;
    u2f.settings.cue = true;
  };

  services = {
    # persistent CPU temperature path
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="hwmon", ${config.rice.temp-select}, \
      RUN+="${pkgs.coreutils}/bin/ln -s /sys$devpath/temp1_input /dev/cpu_temp"
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  home-manager.sharedModules = [
    (hm: {
      home = {
        # haskek my beloved <3
        file.".ghci".text = ''
          :set -Wall
          :set -Wno-type-defaults
          :set prompt "[1;35mλ>[m "
        '';

        packages = with pkgs; [
          alarm
          flameshot
          grim
          hrtrack
          kdePackages.qtwayland
          libnotify
          qt5.qtwayland
          virt-manager
          wl-clipboard
          xdg_utils
        ];
      };

      gtk = let dark = { gtk-application-prefer-dark-theme = true; }; in {
        enable = true;
        theme.name = "Adwaita";

        gtk3.extraConfig = dark;
        gtk4.extraConfig = dark;
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
        style.name = "adwaita-dark";
      };

      services = {
        mpd = {
          enable = true;
          musicDirectory = "${hm.config.home.homeDirectory}/music";
          extraConfig = ''
            audio_output {
              type "pipewire"
              name "pipewire"
            }
          '';
        };

        ssh-agent.enable = true;
      };

      programs = {
        ncmpcpp = {
          enable = true;
          settings.startup_screen = "media_library";
        };

        feh.enable = true;
        firefox.enable = true;
        mpv.enable = true;
        yt-dlp.enable = true;
        zathura.enable = true;
      };
    })
  ];
}
