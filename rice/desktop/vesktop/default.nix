{ pkgs, lib, config, ... }: {
  options.rice.desktop.vesktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.vesktop.enable {
    home-manager.sharedModules = [{
      aquaris.persist = { ".config/vesktop" = { }; };
      programs.vesktop = {
        enable = true;
        vencord.useSystem = true;

        package =
          let
            vencord = pkgs.vencord.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                ./add-moyai-plugin.patch
                ./add-smirk-plugin.patch
              ];

              preBuild = (old.preBuild or "") + ''
                # allow media-src for raw.githubusercontent.com
                # so that moyai and smirk can load sounds
                sed -i '${lib.replaceString "\n" "" ''
                  /"raw.githubusercontent.com"/
                  s|ImageAndCssSrc|[...ImageAndCssSrc, "media-src"]|
                ''}' src/main/csp/index.ts
              '';
            });
          in
          (pkgs.vesktop.override {
            inherit vencord;
            withSystemVencord = true;
            withTTS = false;
          }).overrideAttrs {
            # TODO https://pr-tracker.bunny/?pr=457209
            patches = [
              (pkgs.path + /pkgs/by-name/ve/vesktop/fix_read_only_settings.patch)
              (pkgs.replaceVars ./use_system_vencord.patch {
                inherit vencord;
              })
            ];
          };
      };
    }];
  };
}
