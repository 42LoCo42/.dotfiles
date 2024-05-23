{ self, pkgs, lib, my-utils, ... }: {
  imports = [ self.inputs.stylix.nixosModules.stylix ];

  nixpkgs.overlays = [
    (_: super: {
      foot = self.inputs.obscura.packages.${super.system}.foot-transparent;
      nerdfonts = super.nerdfonts.override { fonts = [ "Iosevka" ]; };
    })
  ];

  stylix = {
    autoEnable = false;

    image = "${self}/rice/misc/wallpaper.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    fonts = {
      emoji = { package = pkgs.noto-fonts-emoji; name = "Noto Color Emoji"; };
      monospace = { package = pkgs.nerdfonts; name = "Iosevka NFM"; };
      sansSerif = { package = pkgs.noto-fonts; name = "Noto Sans"; };
      serif = { package = pkgs.noto-fonts; name = "Noto Serif"; };
    };

    targets = {
      # console.enable = true;
      # gtk.enable = true;
    };
  };

  aquaris = {
    filesystem = { filesystem, zpool, ... }: {
      disks."/dev/disk/by-id/virtio-root".partitions = [
        {
          type = "uefi";
          size = "512M";
          content = filesystem {
            type = "vfat";
            mountpoint = "/boot";
          };
        }
        { content = zpool (p: p.rpool); }
      ];

      zpools.rpool.datasets = {
        "nixos/nix" = { };
        "nixos/persist/home/admin" = { };
      };
    };
  };

  services = {
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
  };

  programs.hyprland.enable = true;

  home-manager.sharedModules = [{
    stylix.targets = {
      firefox.enable = true;
      foot.enable = true;
      fuzzel.enable = true;
      gtk.enable = true;
      # hyprland.enable = true;
      mako.enable = true;
      tmux.enable = true;
      vesktop.enable = true;
    };
  }];

  home-manager.users.leonsch = hm: {
    qt = {
      enable = true;
      platformTheme.name = "gtk3";
    };

    programs = {
      bat.config.theme = lib.mkForce "base16-stylix";

      firefox = {
        enable = true;
        package = pkgs.firefox.override
          { cfg.speechSynthesisSupport = false; };
      };

      foot = {
        enable = true;
        settings = {
          main.font = lib.mkForce "monospace:size=10.5";
          colors.alpha = lib.mkForce "0.5";
        };
      };

      fuzzel.enable = true;
    };

    services = {
      mako.enable = true;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = ''
        monitor = Virtual-1,1920x1080@60,auto,1
        cursor {
          no_hardware_cursors = true
        }
      '' + (my-utils.subsT "${self}/rice/misc/hyprland.conf" {
        fuzzel = lib.getExe pkgs.fuzzel;
        pulsemixer = lib.getExe pkgs.pulsemixer;
      });
    };
  };
}
