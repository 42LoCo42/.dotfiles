{ self, pkgs, lib, ... }: {
  # nix-locate as command-not-found replacement
  imports = [ self.inputs.nix-index-database.nixosModules.nix-index ];
  programs.command-not-found.enable = false;

  # console greeter
  services.greetd = {
    enable = true;
    restart = true;
    vt = 7;
    settings.default_session.command =
      "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --remember-user-session";
  };

  # for GPG key prompt
  services.dbus.packages = [ pkgs.gcr ];

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    tlp.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
      noto-fonts
      noto-fonts-emoji
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaNerdFont" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  home-manager.users.leonsch = hm: {
    home = {
      # a cursor theme is required for virt-manager
      pointerCursor = {
        name = "Vanilla-DMZ";
        package = pkgs.vanilla-dmz;
        gtk.enable = true;
      };

      # haskek my beloved <3
      file.".ghci".text = ''
        :set -Wall
        :set -Wno-type-defaults
        :set prompt "[1;35mλ>[m "
      '';

      sessionVariables = {
        GTK_THEME = "Adwaita:dark";

        # make stuff use wayland
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";

        # apparently needed for java on tiling WMs
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      packages = with pkgs; [
        grim
        keepassxc
        libnotify
        self.inputs.obscura.packages.${system}.flameshot-fixed
        tor-browser-bundle-bin
        xdg_utils
      ];
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "Adwaita-Dark";
    };

    services = {
      emacs.enable = true;

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

      # gpg-agent GUI should use GTK3
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

    systemd.user.services.emacs.Service.Restart = lib.mkForce "always";
  };
}
