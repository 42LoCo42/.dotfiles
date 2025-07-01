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

        package = pkgs.vesktop.override {
          vencord = pkgs.vencord.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./add-smirk-plugin.patch
            ];

            preBuild = (old.preBuild or "") + ''
              # restore moyai plugin
              patch -p1 --reverse --input ${pkgs.fetchurl {
                url = "https://github.com/Vendicated/Vencord/commit/600a95f751c5977f47d64aaa97fdbfd3f324504e.patch";
                hash = "sha256-8GcZub1Ot1rSXqMxRBgsL2zIy0hr2I1J1iOxHaNIVpA=";
              }}
            '';
          });

          withSystemVencord = true;
          withTTS = false;
        };
      };
    }];
  };
}
