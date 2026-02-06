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
    nixpkgs.overlays = [
      (_: prev: {
        rtkit = prev.rtkit.overrideAttrs (old: {
          prePatch = (old.prePatch or "") + ''
            sed -i '${builtins.concatStringsSep "|" [
              "s"
              "setgroups(0, NULL)"
              "setgroups(1, (gid_t[]) { 1 })"
              ""
            ]}' rtkit-daemon.c
          '';
        });
      })
    ];

    security.rtkit = {
      enable = true;
      args = [ "--debug" "--stderr" ];
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;

      extraConfig =
        let
          rt = {
            "module.rt.args" = {
              "rtportal.enabled" = false;
              "nice.level" = -11;
            };
          };

          quantum = 8192;
          clock = 192000;
        in
        {
          pipewire = {
            "00-realtime" = rt // {
              "context.properties" = {
                "default.clock.max-quantum" = quantum;
                "default.clock.min-quantum" = quantum;
                "default.clock.quantum" = quantum;
                "default.clock.rate" = clock;
              };
            };
          };

          pipewire-pulse = {
            "00-realtime" = rt;
          };
        };

      wireplumber.extraConfig = {
        "00-realtime" = {
          "monitor.alsa.rules" = [{
            matches = [{
              "device.name" = "~alsa_card.*";
            }];

            actions = {
              update-props = {
                "api.alsa.headroom" = 8192;
                "api.alsa.period-size" = 256;
              };
            };
          }];
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
