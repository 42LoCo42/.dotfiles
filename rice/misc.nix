{ self, pkgs, lib, ... }: {
  nixpkgs.overlays = [ self.inputs.obscura.overlay ];

  # nix-locate as command-not-found replacement
  imports = [ self.inputs.nix-index-database.nixosModules.nix-index ];
  programs.command-not-found.enable = false;

  security.pam = {
    u2f.settings.cue = true;
    services.sudo.u2fAuth = true;
  };

  services = {
    dbus.packages = [ pkgs.gcr ]; # for GPG key prompt

    # console greeter
    greetd = {
      enable = true;
      restart = true;
      vt = 7;
      settings.default_session.command =
        "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --remember-user-session";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    auto-cpufreq.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  fonts = {
    packages = with pkgs; [
      nerdfonts
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

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  users.users.leonsch.extraGroups = [ "libvirtd" ];

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
        flameshot
        grim
        keepassxc
        libnotify
        virt-manager
        xdg_utils
      ];
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-dark";
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
        pinentryPackage = pkgs.pinentry-gnome3;
      };
    };

    programs = {
      emacs = {
        enable = true;
        package = pkgs.emacs29-pgtk;
      };

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

    systemd.user.services.emacs.Service.Restart = lib.mkForce "always";
  };
}
