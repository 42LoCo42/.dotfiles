{ pkgs, lib, config, ... }: {
  options.rice.desktop.pipewire = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    eq = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.rice.desktop.pipewire.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;

      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.max-quantum" = 1024;
            "default.clock.min-quantum" = 1024;
            "default.clock.quantum" = 1024;
          };
        };
      };
    };

    home-manager.sharedModules = [
      {
        aquaris.persist = { ".local/state/wireplumber" = { }; };
      }

      (lib.mkIf config.rice.desktop.pipewire.eq {
        services.easyeffects = {
          enable = true;
          preset = "default";
        };

        xdg.configFile."easyeffects/output/default.json".source = lib.pipe null [
          (_: pkgs.fetchFromGitHub {
            owner = "Digitalone1";
            repo = "EasyEffects-Presets";
            rev = "32d0f416e7867ccffdab16c7fe396f2522d04b2e";
            hash = "sha256-U9SSyHOOs8GsV6GBEqAqlBAuYONeh/4nkK8HurkEfWk=";
          })
          (x: "${x}/LoudnessEqualizer.json")
        ];
      })
    ];
  };
}
